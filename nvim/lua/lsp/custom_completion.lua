-- Auto trigger completion
local auto_trigger_completion = function()
  if vim.snippet and vim.snippet.active() then
    return
  end

  -- Get current buffer context
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local char_before = col > 0 and line:sub(col, col) or ""

  -- Define trigger characters
  local trigger_chars = { ".", ":" }

  -- Check what type of completion to trigger
  local is_trigger_char = vim.tbl_contains(trigger_chars, char_before)
  local is_identifier_char = char_before:match("[%w_]") ~= nil

  -- Skip if neither trigger char nor identifier char
  if not is_trigger_char and not is_identifier_char then
    return
  end

  -- For identifier completion, check if we're in the middle of typing a word
  if is_identifier_char then
    -- Get the word being typed to avoid triggering on every character
    local before_cursor = line:sub(1, col)
    local word_start = before_cursor:find("[%w_]*$")
    local current_word = before_cursor:sub(word_start or col)

    -- Only trigger if we have at least 2 characters to avoid too many triggers
    if #current_word < 2 then
      return
    end
  end

  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client:supports_method("textDocument/completion") then
      local server_trigger_chars = client.server_capabilities.completionProvider
          and client.server_capabilities.completionProvider.triggerCharacters
          or {}

      local trigger_kind = vim.lsp.protocol.CompletionTriggerKind.Invoked
      local trigger_character = nil

      if is_trigger_char and server_trigger_chars and vim.tbl_contains(server_trigger_chars, char_before) then
        trigger_kind = vim.lsp.protocol.CompletionTriggerKind.TriggerCharacter
        trigger_character = char_before
      end

      vim.lsp.completion.get({
        context = {
          triggerKind = trigger_kind,
          triggerCharacter = trigger_character,
        },
      })
      break
    end
  end
end

-- Show documentation in completion popup (pum) using LSP
local show_docs = function(client)
  -- Get current completion state
  if vim.fn.pumvisible() == 0 then
    return
  end

  local complete_info = vim.fn.complete_info({ 'items', 'selected' })
  if complete_info.selected == -1 or not complete_info.items then
    return
  end

  local current_item = complete_info.items[complete_info.selected + 1] -- Lua 1-indexed
  if not current_item then
    return
  end

  -- Extract LSP completion item
  local completion_item = vim.tbl_get(current_item, "user_data", "nvim", "lsp", "completion_item")
  if not completion_item then
    return
  end

  -- Check if this item already has documentation
  if completion_item.documentation then
    -- Convert documentation to string if needed
    local doc_content = completion_item.documentation
    if type(doc_content) == "table" and doc_content.value then
      doc_content = doc_content.value
    end

    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(doc_content)
    local info_text = type(markdown_lines) == "table" and table.concat(markdown_lines, "\n") or tostring(markdown_lines)
    local win_data = vim.api.nvim__complete_set(complete_info.selected, {
      info = info_text,
    })
    if win_data and win_data.winid and vim.api.nvim_win_is_valid(win_data.winid) then
      vim.api.nvim_win_set_config(win_data.winid, { border = "rounded" })
      pcall(vim.treesitter.start, win_data.bufnr, "markdown")
      vim.wo[win_data.winid].conceallevel = 3
    end
    return
  end

  -- Resolve async for full docs only if no immediate docs
  client:request(vim.lsp.protocol.Methods.completionItem_resolve, completion_item, function(err, result)
    if err or not result or not result.documentation then
      return
    end

    -- Convert documentation to string if needed
    local doc_content = result.documentation
    if type(doc_content) == "table" and doc_content.value then
      doc_content = doc_content.value
    end

    -- Inject docs into pum's info column (uses built-in popup win—no manual window mgmt)
    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(doc_content)
    local info_text = type(markdown_lines) == "table" and table.concat(markdown_lines, "\n") or tostring(markdown_lines)

    -- Need to get current selection again since this is async
    local current_complete_info = vim.fn.complete_info({ 'selected' })
    if current_complete_info.selected == -1 then
      return
    end

    local win_data = vim.api.nvim__complete_set(current_complete_info.selected, {
      info = info_text,
    })
    if win_data and win_data.winid and vim.api.nvim_win_is_valid(win_data.winid) then
      -- Polish: Rounded border, Markdown highlighting
      vim.api.nvim_win_set_config(win_data.winid, { border = "rounded" })
      pcall(vim.treesitter.start, win_data.bufnr, "markdown") -- Graceful if TS unavailable
      vim.wo[win_data.winid].conceallevel = 3                 -- Hide Markdown syntax chars
    end
  end)
end

-- Open documentation in a separate persistent window
local open_docs_window = function(client)
  if vim.fn.pumvisible() == 0 then
    return
  end

  local complete_info = vim.fn.complete_info({ 'items', 'selected' })
  if complete_info.selected == -1 or not complete_info.items then
    return
  end

  local current_item = complete_info.items[complete_info.selected + 1]
  if not current_item then
    return
  end

  local completion_item = vim.tbl_get(current_item, "user_data", "nvim", "lsp", "completion_item")
  if not completion_item then
    return
  end

  local function show_in_window(doc_content)
    if not doc_content then
      return
    end

    -- Convert documentation to string if needed
    if type(doc_content) == "table" and doc_content.value then
      doc_content = doc_content.value
    end

    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(doc_content)
    local content = type(markdown_lines) == "table" and markdown_lines or { tostring(markdown_lines) }

    -- Create a new buffer for the documentation
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Calculate window size and position
    local width = math.min(80, vim.o.columns - 10)
    local height = math.min(20, vim.o.lines - 10)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    -- Open the window
    local win = vim.api.nvim_open_win(buf, true, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      border = 'rounded',
      title = ' Documentation ',
      title_pos = 'center',
    })

    -- Set window options
    vim.wo[win].conceallevel = 3
    vim.wo[win].wrap = true

    -- Key mapping to close the window
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
    vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
  end

  -- Try immediate documentation first
  if completion_item.documentation then
    show_in_window(completion_item.documentation)
    return
  end

  -- Resolve for full documentation
  client:request(vim.lsp.protocol.Methods.completionItem_resolve, completion_item, function(err, result)
    if err or not result or not result.documentation then
      vim.notify("No documentation available", vim.log.levels.INFO)
      return
    end
    show_in_window(result.documentation)
  end)
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom.lsp.completion", { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Completion
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(
        true,
        client.id,
        args.buf,
        {
          autotrigger = true,
          trigger_characters = { ".", ":", "(", "[", '"', "'", "/" },
          convert = function(item)
            -- LSP kind to icon mapping
            local kind_icons = {
              [1] = "󰉿", -- Text
              [2] = "󰊕", -- Method
              [3] = "󰊕", -- Function
              [4] = "󰊕", -- Constructor
              [5] = "󰀫", -- Field
              [6] = "󰀫", -- Variable
              [7] = "󰠱", -- Class
              [8] = "󰜰", -- Interface
              [9] = "󰏗", -- Module
              [10] = "󰀫", -- Property
              [11] = "󰎠", -- Unit
              [12] = "󰌋", -- Value
              [13] = "󰌋", -- Enum
              [14] = "󰌉", -- Keyword
              [15] = "󰘦", -- Snippet
              [16] = "󰉿", -- Color
              [17] = "󰈙", -- File
              [18] = "󰈙", -- Reference
              [19] = "󰉋", -- Folder
              [20] = "󰀫", -- EnumMember
              [21] = "󰘧", -- Constant
              [22] = "󰠱", -- Struct
              [23] = "󰆧", -- Event
              [24] = "󰘧", -- Operator
              [25] = "󰎅", -- TypeParameter
            }

            -- Truncate word to max 15 characters
            local word = item.word or item.insertText or item.label or ""
            if #word > 25 then
              word = word:sub(1, 22) .. "..."
            end

            -- Truncate abbr (abbreviation) to max 15 characters
            local abbr = item.abbr or item.label or word
            if #abbr > 25 then
              abbr = abbr:sub(1, 22) .. "..."
            end

            -- Convert LSP kind number to icon
            local kind_icon = kind_icons[item.kind] or "󰘦"

            return {
              word = word,
              abbr = abbr,
              kind = kind_icon,
              menu = "", -- Hide file path/menu
              info = item.info,
              icase = item.icase,
              dup = item.dup,
              empty = item.empty,
              user_data = item.user_data,
            }
          end
        }
      )

      -- When using basics_ls snippets, using Enter does not expand the snippet
      vim.keymap.set("i", "<CR>", function()
        return vim.fn.pumvisible() == 1 and "<C-Y>" or "<CR>"
      end, { expr = true, desc = "Accept completion or insert newline" })

      vim.keymap.set("i", "<Tab>", function()
        if vim.snippet.active() then
          return "<Cmd>lua vim.snippet.jump(1)<CR>"
        elseif vim.fn.pumvisible() == 1 then
          return "<C-N>"
        else
          return "<Tab>"
        end
      end, { expr = true })

      -- Ctrl+Tab for previous completion
      vim.keymap.set("i", "<C-Tab>", function()
        if vim.snippet.active() then
          return "<Cmd>lua vim.snippet.jump(-1)<CR>"
        elseif vim.fn.pumvisible() == 1 then
          return "<C-P>"
        else
          return "<C-Tab>"
        end
      end, { expr = true, desc = "Previous completion" })

      -- Docs in completion popup on selection change
      vim.api.nvim_create_autocmd("CompleteChanged", {
        buffer = args.buf,
        callback = function()
          vim.schedule(function()
            show_docs(client)
          end)
        end,
      })

      -- Open documentation in a separate focusable window
      vim.keymap.set("i", "<C-b>", function()
        if vim.fn.pumvisible() == 1 then
          open_docs_window(client)
          return ""
        end
        return "<C-k>"
      end, { expr = true, buffer = args.buf, desc = "Open completion docs in window" })

      -- Trigger completion on text changes in insert mode
      vim.api.nvim_create_autocmd("TextChangedI", {
        buffer = args.buf,
        callback = function()
          auto_trigger_completion()
        end,
      })
    end
  end,
})
