-- Pure vim.api statusline implementation
-- Based on lualine configuration but using only vim.api

local M = {}

-- Configuration
M.config = {
  enabled = true,
  left_separator = "",
  right_separator = "",
  git_diff_min_width = 7,
  max_filename_length = 0.6, -- 40% of window width
}

local colors = require("ui.colors")

-- Setup highlight groups
local function setup_highlights()
  local highlights = {
    StatuslineGitDiff = { fg = colors.bg, bg = colors.red },
    StatuslineLeftSep = { fg = colors.red, bg = colors.bg },
    StatuslineFilename = { fg = colors.light_gray, bg = colors.bg },
    StatuslineDiagnosticError = { fg = colors.red, bg = colors.bg },
    StatuslineDiagnosticWarn = { fg = colors.yellow, bg = colors.bg },
    StatuslineDiagnosticInfo = { fg = colors.cyan, bg = colors.bg },
    StatuslineLsp = { fg = colors.light_gray, bg = colors.bg },
    StatuslineRightSep = { fg = colors.red, bg = colors.bg },
    StatuslineMode = { fg = colors.bg, bg = colors.red, bold = true },
    StatuslineNormal = { fg = colors.fg, bg = colors.bg },
  }

  for name, opts in pairs(highlights) do
    local cmd = "highlight " .. name
    if opts.fg then
      cmd = cmd .. " guifg=" .. opts.fg
    end
    if opts.bg then
      cmd = cmd .. " guibg=" .. opts.bg
    end
    if opts.bold then
      cmd = cmd .. " gui=bold"
    end
    vim.cmd(cmd)
  end
end

-- Get gitsigns status display
local function get_git_diff_display()
  -- Use gitsigns status integration
  local gitsigns_status = vim.b.gitsigns_status
  local gitsigns_status_dict = vim.b.gitsigns_status_dict

  if gitsigns_status and gitsigns_status ~= "" then
    return string.format("%-" .. M.config.git_diff_min_width .. "s", gitsigns_status)
  end

  -- Fallback: manually format from gitsigns_status_dict if available
  if gitsigns_status_dict then
    local parts = {}
    if gitsigns_status_dict.added and gitsigns_status_dict.added > 0 then
      table.insert(parts, "+" .. gitsigns_status_dict.added)
    end
    if gitsigns_status_dict.changed and gitsigns_status_dict.changed > 0 then
      table.insert(parts, "~" .. gitsigns_status_dict.changed)
    end
    if gitsigns_status_dict.removed and gitsigns_status_dict.removed > 0 then
      table.insert(parts, "-" .. gitsigns_status_dict.removed)
    end
    local formatted = table.concat(parts, " ")
    if formatted ~= "" then
      return string.format("%-" .. M.config.git_diff_min_width .. "s", formatted)
    end
  end

  -- Return padded empty string to maintain consistent spacing
  return string.format("%-" .. M.config.git_diff_min_width .. "s", "")
end

-- Get current file name with smart truncation
local function get_current_file_name()
  local relative_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
  local full_path = project_name .. "/" .. relative_path
  local win_width = vim.fn.winwidth(0)

  if win_width < 50 then
    -- Show only filename
    return vim.fn.expand("%:t")
  elseif win_width > 150 then
    -- Show full path
    return full_path
  else
    -- Smart shortening: keep last two directories intact
    local path_parts = vim.split(full_path, "/", { plain = true })
    local max_length = math.floor(win_width * M.config.max_filename_length)

    if #path_parts <= 2 then
      return full_path
    else
      -- Keep the last two parts (parent dir + filename)
      local filename = path_parts[#path_parts]
      local parent_dir = path_parts[#path_parts - 1]
      local last_two = parent_dir .. "/" .. filename

      -- Start with the last two parts
      local result_parts = { parent_dir, filename }
      local current_length = #last_two

      -- Add directories from the end, shortening from the beginning if needed
      for i = #path_parts - 2, 1, -1 do
        local part = path_parts[i]
        local test_length = current_length + #part + 1 -- +1 for separator

        if test_length <= max_length then
          -- Add full directory name
          table.insert(result_parts, 1, part)
          current_length = test_length
        else
          -- Shorten this directory and stop
          local available_space = max_length - current_length - 1 -- -1 for separator
          if available_space > 1 then
            local shortened = string.sub(part, 1, math.max(1, available_space)) .. "…"
            table.insert(result_parts, 1, shortened)
          else
            table.insert(result_parts, 1, "…")
          end
          break
        end
      end

      return table.concat(result_parts, "/")
    end
  end
end

-- Get diagnostics display
local function get_diagnostics_display()
  local symbols = {
    error = " ",
    warn = " ",
    info = " ",
  }

  local counts = vim.diagnostic.count(0)
  local display = ""

  if counts[vim.diagnostic.severity.ERROR] and counts[vim.diagnostic.severity.ERROR] > 0 then
    display = display .. "%#StatuslineDiagnosticError#" .. symbols.error .. counts[vim.diagnostic.severity.ERROR]
  end

  if counts[vim.diagnostic.severity.WARN] and counts[vim.diagnostic.severity.WARN] > 0 then
    display = display .. "%#StatuslineDiagnosticWarn#" .. symbols.warn .. counts[vim.diagnostic.severity.WARN]
  end

  if counts[vim.diagnostic.severity.INFO] and counts[vim.diagnostic.severity.INFO] > 0 then
    display = display .. "%#StatuslineDiagnosticInfo#" .. symbols.info .. counts[vim.diagnostic.severity.INFO]
  end

  return display
end

-- Get LSP status
local function get_lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    local names = {}
    for _, client in pairs(clients) do
      table.insert(names, client.name)
    end
    return " " .. table.concat(names, " ") .. " "
  end
  return ""
end

-- Mode color mapping
local mode_colors = {
  n = colors.red,
  i = colors.green,
  v = colors.purple,
  V = colors.purple,
  ["V-BLOCK"] = colors.purple,
  c = colors.light_black,
  s = colors.yellow,
  S = colors.yellow,
  ["S-BLOCK"] = colors.yellow,
  r = colors.blue,
  R = colors.blue,
  ["!"] = colors.light_black,
  t = colors.light_black,
}

-- Mode name mapping
local mode_names = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["^V"] = "V-BLOCK", -- Ctrl-V
  c = "COMMAND",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK", -- Ctrl-S
  r = "REPLACE",
  R = "REPLACE",
  ["!"] = "SHELL",
  t = "TERMINAL",
}

-- Update highlight groups based on current mode
local function update_mode_highlights()
  local current_mode = vim.fn.mode()
  local mode_color = mode_colors[current_mode] or colors.red

  local bg_color = colors.bg
  if current_mode == "t" or current_mode == "t" or current_mode == "c" then
    bg_color = colors.fg
  end

  -- Update git diff background to match mode
  vim.cmd("highlight StatuslineGitDiff guifg=" .. bg_color .. " guibg=" .. mode_color .. " gui=bold")
  vim.cmd("highlight StatuslineLeftSep guifg=" .. mode_color .. " guibg=" .. colors.bg)

  -- Update mode separator and background
  vim.cmd("highlight StatuslineRightSep guifg=" .. mode_color .. " guibg=" .. colors.bg)
  vim.cmd("highlight StatuslineMode guifg=" .. bg_color .. " guibg=" .. mode_color .. " gui=bold")
end

-- Build the statusline
local function build_statusline()
  if not M.config.enabled then
    return ""
  end

  update_mode_highlights()

  local current_mode = vim.fn.mode()
  local mode_name = mode_names[current_mode] or current_mode:upper()

  local parts = {}

  -- Left section: Git diff with mode-colored background
  local git_diff = get_git_diff_display()
  table.insert(parts, "%#StatuslineGitDiff#" .. " " .. git_diff .. " ")
  table.insert(parts, "%#StatuslineLeftSep#" .. M.config.left_separator)

  -- Middle section: Filename
  table.insert(parts, "%#StatuslineFilename#" .. " " .. get_current_file_name())

  -- Separator to push right section to the right
  table.insert(parts, "%#StatuslineNormal#%=")

  -- Right section: Diagnostics, LSP, Mode
  local diagnostics = get_diagnostics_display()
  if diagnostics ~= "" then
    table.insert(parts, diagnostics)
  end

  local lsp_status = get_lsp_status()
  if lsp_status ~= "" then
    table.insert(parts, "%#StatuslineLsp#" .. lsp_status)
  end

  -- Mode with separator
  table.insert(parts, "%#StatuslineRightSep#" .. M.config.right_separator)
  table.insert(parts, "%#StatuslineMode# " .. mode_name .. " ")

  return table.concat(parts, "")
end

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  if not M.config.enabled then
    return
  end

  setup_highlights()

  -- Set the statusline function
  vim.opt.statusline = '%!v:lua.require("core.statusline").render()'

  -- Update on mode change and other events
  local group = vim.api.nvim_create_augroup("StatuslineEvents", { clear = true })

  vim.api.nvim_create_autocmd({
    "ModeChanged",
    "BufEnter",
    "BufWritePost",
    "DiagnosticChanged",
    "LspAttach",
    "LspDetach",
    "User",
  }, {
    group = group,
    pattern = "*",
    callback = function(args)
      -- Update on gitsigns events
      if
          args.event == "User"
          and (args.match == "GitSignsUpdate" or args.match == "GitSignsChanged" or args.data and args.data.gitsigns)
      then
        vim.cmd("redrawstatus")
      elseif args.event ~= "User" then
        vim.cmd("redrawstatus")
      end
    end,
  })

  -- Additional autocmd specifically for gitsigns updates
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
    group = group,
    callback = function()
      -- Delay the redraw to allow gitsigns to update
      vim.schedule(function()
        vim.cmd("redrawstatus")
      end)
    end,
  })
end

-- Render function (called by statusline)
function M.render()
  return build_statusline()
end

-- Export get_gitsigns_status for testing
function M.get_gitsigns_status()
  return vim.b.gitsigns_status
end

-- Toggle function
function M.toggle()
  M.config.enabled = not M.config.enabled
  if M.config.enabled then
    vim.opt.statusline = '%!v:lua.require("core.statusline").render()'
  else
    vim.opt.statusline = ""
  end
  vim.cmd("redrawstatus")
end

-- Auto-setup
M.setup()

return M
