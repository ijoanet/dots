-- Tmux-based opencode integration
-- Sends prompts to a tmux window named 'opencode'

local M = {}

-- Configuration
local opencode_config = {
  tmux_window_name = "opencode",
  keys = {
    -- Default keymaps - can be overridden in setup()
    { "<leader>oc", "goto_opencode", "Go to opencode tmux window", mode = "n" },
    { "<leader>oa", "ask", "Ask opencode", mode = "n" },
    { "<leader>oa", "ask_selection", "Ask opencode about selection", mode = "v" },
    { "<leader>oe", "explain_cursor", "Explain code near cursor", mode = "n" },
  },
  -- Context configuration
  context_settings = {
    enabled = true,
    max_file_size = 10000, -- Max lines for file contexts
    max_dir_files = 50, -- Max files to include in @dir
  },
  -- Context definitions - will be populated after config initialization
  contexts = {},
}

-- Helper: Check if tmux window exists
local function tmux_window_exists(window_name)
  local result = vim.fn.system(string.format('tmux list-windows -F "#{window_name}" | grep -q "^%s$"', window_name))
  return vim.v.shell_error == 0
end

-- Helper: Create or switch to opencode tmux window
local function ensure_opencode_window()
  if not tmux_window_exists(opencode_config.tmux_window_name) then
    -- Call tmux_goto_opencode zsh function to create the window
    local result = vim.fn.system('zsh -c "source ~/.zshrc && tmux_goto_opencode"')
    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to create opencode tmux window", vim.log.levels.ERROR)
      return false, false
    end
    return true, true -- window exists, was newly created
  end
  return true, false -- window exists, was not newly created
end

-- Helper: Switch to opencode tmux window
local function goto_opencode_window()
  local exists, newly_created = ensure_opencode_window()
  if not exists then
    return
  end

  local result = vim.fn.system(string.format("tmux select-window -t %s", opencode_config.tmux_window_name))
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to switch to opencode window", vim.log.levels.ERROR)
  end
end

-- Helper: Capture current directory context
local function capture_current_directory()
  local current_file = vim.fn.expand("%:p")
  if current_file and current_file ~= "" and vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "terminal" then
    return vim.fn.fnamemodify(current_file, ":h")
  else
    -- Look for the most recent file buffer
    local buffers = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(buffers) do
      if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "" then
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname and bufname ~= "" then
          return vim.fn.fnamemodify(bufname, ":h")
        end
      end
    end
    -- Final fallback
    return vim.fn.getcwd()
  end
end

-- Context substitution function
local function substitute_contexts(text)
  if not opencode_config.context_settings.enabled then
    return text
  end

  -- Debug: Check if contexts are available
  if not opencode_config.contexts or vim.tbl_isempty(opencode_config.contexts) then
    vim.notify("Warning: No contexts available for substitution", vim.log.levels.DEBUG)
    return text
  end

  -- Use the contexts from config
  for pattern, context_def in pairs(opencode_config.contexts) do
    if text:find(pattern, 1, true) then
      local success, content = pcall(context_def.value)
      if success and content then
        text = text:gsub(vim.pesc(pattern), content)
        vim.notify(string.format("Substituted %s with %d chars", pattern, #content), vim.log.levels.DEBUG)
      else
        local error_msg = success and "No content available" or tostring(content)
        local replacement = string.format("Error getting %s: %s", pattern, error_msg)
        text = text:gsub(vim.pesc(pattern), replacement)
        vim.notify(string.format("Error substituting %s: %s", pattern, error_msg), vim.log.levels.WARN)
      end
    end
  end

  return text
end

-- Function to initialize default contexts
local function init_default_contexts()
  opencode_config.contexts = {
    ["@buffer"] = {
      description = "Current buffer file path",
      value = function()
        local filepath = vim.fn.expand("%:p")
        if filepath and filepath ~= "" then
          return filepath
        else
          return "[No file - unsaved buffer]"
        end
      end,
    },
    ["@file"] = {
      description = "Current buffer content with filename and path",
      value = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local filename = vim.fn.expand("%:t")
        local filepath = vim.fn.expand("%:p")

        if #lines > opencode_config.context_settings.max_file_size then
          return string.format(
            "File '%s' (%s) - Content truncated (showing first %d lines):\n```\n%s\n```",
            filename,
            filepath,
            opencode_config.context_settings.max_file_size,
            table.concat(vim.list_slice(lines, 1, opencode_config.context_settings.max_file_size), "\n")
          )
        else
          return string.format("File '%s' (%s):\n```\n%s\n```", filename, filepath, table.concat(lines, "\n"))
        end
      end,
    },
    ["@selection"] = {
      description = "Currently selected text",
      value = function()
        -- Save current register
        local saved_reg = vim.fn.getreg('"')
        local saved_regtype = vim.fn.getregtype('"')

        -- Yank current selection
        vim.cmd('normal! "vy')
        local selected_text = vim.fn.getreg("v")

        -- Restore register
        vim.fn.setreg('"', saved_reg, saved_regtype)

        if selected_text and selected_text ~= "" then
          return string.format("Selected text:\n```\n%s\n```", selected_text)
        else
          return "No text currently selected"
        end
      end,
    },
    ["@cursor"] = {
      description = "Context around cursor position with line numbers",
      value = function()
        local pos = vim.api.nvim_win_get_cursor(0)
        local line_num = pos[1]
        local col_num = pos[2] + 1
        local filename = vim.fn.expand("%:t")
        local total_lines = vim.api.nvim_buf_line_count(0)

        -- Get context around cursor (5 lines before and after)
        local start_line = math.max(1, line_num - 5)
        local end_line = math.min(total_lines, line_num + 5)
        local context_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

        -- Add line numbers and highlight current line
        local numbered_lines = {}
        for i, line in ipairs(context_lines) do
          local actual_line_num = start_line + i - 1
          local prefix = actual_line_num == line_num and ">>> " or "    "
          table.insert(numbered_lines, string.format("%s%d: %s", prefix, actual_line_num, line))
        end

        return string.format(
          "Cursor position in '%s' at line %d, column %d:\n```\n%s\n```",
          filename,
          line_num,
          col_num,
          table.concat(numbered_lines, "\n")
        )
      end,
    },
    ["@dir"] = {
      description = "Files and directories in current buffer's directory",
      value = function()
        local dir_path = capture_current_directory()

        -- Get all files in directory
        local handle = vim.loop.fs_scandir(dir_path)
        if not handle then
          return string.format("Could not read directory: %s", dir_path)
        end

        local files = {}
        local dirs = {}
        local count = 0

        while count < opencode_config.context_settings.max_dir_files do
          local name, type = vim.loop.fs_scandir_next(handle)
          if not name then
            break
          end

          -- Skip hidden files and common ignored directories
          if not name:match("^%.") and name ~= "node_modules" and name ~= ".git" then
            if type == "directory" then
              table.insert(dirs, name .. "/")
            else
              table.insert(files, name)
            end
            count = count + 1
          end
        end

        -- Sort files and directories
        table.sort(dirs)
        table.sort(files)

        local all_items = {}
        for _, dir in ipairs(dirs) do
          table.insert(all_items, dir)
        end
        for _, file in ipairs(files) do
          table.insert(all_items, file)
        end

        local result = string.format("Directory contents of '%s':\n", dir_path)
        if count >= opencode_config.context_settings.max_dir_files then
          result = result .. string.format("(showing first %d items)\n", opencode_config.context_settings.max_dir_files)
        end
        result = result .. "```\n" .. table.concat(all_items, "\n") .. "\n```"

        return result
      end,
    },
    ["@diagnostics"] = {
      description = "List of diagnostics for the current buffer",
      value = function()
        local diags = vim.diagnostic.get(0)
        if not diags or #diags == 0 then
          return "No diagnostics found."
        end
        local severities = { [1] = "ERROR", [2] = "WARN", [3] = "INFO", [4] = "HINT" }
        local lines = {}
        for _, d in ipairs(diags) do
          local sev = severities[d.severity] or tostring(d.severity)
          table.insert(lines, string.format("%d:%d [%s] %s", d.lnum + 1, d.col + 1, sev, d.message))
        end
        return table.concat(lines, "\n")
      end,
    },
  }
  -- Debug: Confirm contexts were initialized
  -- vim.notify(
  --   string.format(
  --     "Initialized %d contexts: %s",
  --     vim.tbl_count(opencode_config.contexts),
  --     table.concat(vim.tbl_keys(opencode_config.contexts), ", ")
  --   ),
  --   vim.log.levels.DEBUG
  -- )
end

-- Helper: Send text to opencode tmux window
local function send_to_opencode_tmux(text)
  local exists, newly_created = ensure_opencode_window()
  if not exists then
    return
  end

  -- Apply context substitution
  text = substitute_contexts(text)

  -- Escape single quotes and backslashes for tmux send-keys
  text = text:gsub("'", "'\"'\"'"):gsub("\\", "\\\\")

  -- If window was newly created, wait for opencode to initialize
  if newly_created then
    vim.notify("Waiting for opencode to initialize...", vim.log.levels.INFO)
    vim.defer_fn(function()
      -- Send the text to the opencode tmux window
      local cmd = string.format("tmux send-keys -t %s '%s' C-m", opencode_config.tmux_window_name, text)
      local result = vim.fn.system(cmd)

      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to send prompt to opencode window", vim.log.levels.ERROR)
        return
      end

      -- Switch to opencode window after sending
      goto_opencode_window()
    end, 2000) -- Wait 2 seconds for opencode to start
  else
    -- Send immediately if window already existed
    local cmd = string.format("tmux send-keys -t %s '%s' C-m", opencode_config.tmux_window_name, text)
    local result = vim.fn.system(cmd)

    if vim.v.shell_error ~= 0 then
      vim.notify("Failed to send prompt to opencode window", vim.log.levels.ERROR)
      return
    end

    -- Switch to opencode window after sending
    goto_opencode_window()
  end
end

-- Function to prompt for input and send to opencode (normal mode)
local function ask_opencode()
  vim.ui.input({
    prompt = "OpenCode prompt: ",
    default = "",
  }, function(input)
    if not input or not input:match("%S") then
      return
    end

    send_to_opencode_tmux(input)
  end)
end

-- Function to prompt for input and send selection to opencode (visual mode)
local function ask_opencode_selection()
  -- Save the selection by yanking to a temporary register
  vim.cmd('normal! "zy')
  local selected_text = vim.fn.getreg("z")

  -- Exit visual mode
  vim.cmd("normal! \\<Esc>")

  vim.ui.input({
    prompt = "OpenCode prompt (+ selection): ",
    default = "",
  }, function(input)
    if not input or not input:match("%S") then
      return
    end

    local final_text
    if selected_text and selected_text ~= "" then
      final_text = input .. "\n\n```\n" .. selected_text .. "\n```"
    else
      final_text = input
    end

    send_to_opencode_tmux(final_text)
  end)
end

-- Function to explain code near cursor
local function explain_cursor()
  local selected_text = nil
  local mode = vim.fn.mode()

  -- Check if we're already in visual mode with a selection
  if mode == "v" or mode == "V" or mode == "\22" then
    -- Save the existing selection
    vim.cmd('normal! "zy')
    selected_text = vim.fn.getreg("z")
    vim.cmd("normal! \\<Esc>")
  else
    -- No existing selection, try to select a paragraph
    local original_pos = vim.api.nvim_win_get_cursor(0)

    -- Try to select a paragraph (vap)
    vim.cmd("normal! vap")

    -- Check if we actually selected something meaningful
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    if start_pos[2] ~= end_pos[2] or math.abs(end_pos[3] - start_pos[3]) > 10 then
      -- Good paragraph selection, use it
      vim.cmd('normal! "zy')
      selected_text = vim.fn.getreg("z")
      vim.cmd("normal! \\<Esc>")
    else
      -- Paragraph selection was too small or failed, use 20 surrounding lines
      vim.api.nvim_win_set_cursor(0, original_pos)
      vim.cmd("normal! \\<Esc>")

      local line_num = original_pos[1]
      local start_line = math.max(1, line_num - 10)
      local end_line = math.min(vim.api.nvim_buf_line_count(0), line_num + 10)
      local context_lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
      selected_text = table.concat(context_lines, "\n")
    end
  end

  if not selected_text or selected_text == "" then
    vim.notify("No code to explain", vim.log.levels.WARN)
    return
  end

  local prompt = "Explain this code and its context:\n\n```\n" .. selected_text .. "\n```"
  send_to_opencode_tmux(prompt)
end

-- Key mappings for opencode
local function setup_keymaps()
  -- Action mapping
  local actions = {
    goto_opencode = goto_opencode_window,
    ask = ask_opencode,
    ask_selection = ask_opencode_selection,
    explain_cursor = explain_cursor,
  }

  -- Setup keymaps from config
  for _, keymap in ipairs(opencode_config.keys) do
    local key, action, desc, mode = keymap[1], keymap[2], keymap[3], keymap.mode or keymap[4] or "n"

    if actions[action] then
      vim.keymap.set(mode, key, actions[action], {
        noremap = true,
        silent = true,
        desc = desc,
      })
    else
      vim.notify(string.format("Unknown action: %s for keymap %s", action, key), vim.log.levels.WARN)
    end
  end
end

-- Setup function
function M.setup(opts)
  opts = opts or {}

  -- Merge user config
  if opts.tmux_window_name then
    opencode_config.tmux_window_name = opts.tmux_window_name
  end

  -- Merge user keymaps with defaults
  if opts.keys then
    opencode_config.keys = opts.keys
  end

  -- Merge context settings
  if opts.context_settings then
    opencode_config.context_settings =
      vim.tbl_deep_extend("force", opencode_config.context_settings, opts.context_settings)
  end

  -- Initialize default contexts
  init_default_contexts()

  -- Merge user contexts with defaults
  if opts.contexts then
    opencode_config.contexts = vim.tbl_deep_extend("force", opencode_config.contexts, opts.contexts)
  end

  -- Setup keymaps
  setup_keymaps()
end

-- Auto-setup with default config
M.setup()

return M
