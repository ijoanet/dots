-- Synth colorscheme
local colors = require("ui.colors")

local function set_hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Clear existing highlights
vim.cmd.hi("clear")
if vim.fn.exists("syntax_on") then
  vim.cmd.syntax("reset")
end

-- Core
set_hl("Normal", { fg = colors.fg, bg = colors.bg })
set_hl("NormalFloat", { fg = colors.fg, bg = colors.bg })
set_hl("FloatBorder", { fg = colors.magenta, bg = colors.bg })
set_hl("Comment", { fg = colors.bright_black })
set_hl("NonText", { fg = colors.bright_black })
set_hl("LineNr", { fg = colors.bright_black })
set_hl("CursorLineNr", { fg = colors.fg, bg = colors.bright_black })
set_hl("SignColumn", { bg = nil })
set_hl("EndOfBuffer", { fg = colors.bg })
set_hl("WinSeparator", { fg = colors.bg_muted })

-- Cursor
set_hl("Cursor", { fg = colors.cursor_text, bg = colors.cursor })
set_hl("lCursor", { fg = colors.cursor_text, bg = "none" })
set_hl("CursorLine", { bg = "none" })
set_hl("TermCursor", { fg = colors.cursor_text, bg = colors.cursor })
set_hl("TermCursorNC", { fg = colors.cursor_text, bg = colors.cursor })

-- Selection/Visual
set_hl("Visual", { fg = colors.sel_fg, bg = colors.sel_bg })
set_hl("Search", { fg = colors.yellow, bg = colors.bright_black })
set_hl("IncSearch", { fg = colors.yellow, bg = colors.bright_black })
set_hl("VisualNOS", { fg = colors.sel_fg, bg = colors.sel_bg })

-- Terminal
set_hl("TermCursor", { bg = colors.green, fg = colors.bg })

-- Statusline/Tabs
set_hl("StatusLine", { fg = colors.fg, bg = colors.bg })
set_hl("StatusLineNC", { fg = colors.bright_black, bg = colors.bg })
set_hl("TabLine", { fg = colors.bright_black, bg = colors.bg })
set_hl("TabLineSel", { fg = colors.fg, bg = colors.bg })
set_hl("TabLineFill", { bg = colors.bg })

-- Folds
set_hl("Folded", { fg = colors.bright_black, bg = colors.bg })
set_hl("FoldColumn", { fg = colors.bright_black, bg = nil })

-- Diff
-- Needed to be done in gitsigns :/

set_hl("DiffText", { bg = "NONE" })
set_hl("DiffAdd", { bg = "NONE", fg = colors.green })
set_hl("DiffChange", { bg = "NONE", fg = colors.magenta })
set_hl("DiffDelete", { bg = "NONE", fg = colors.red })

-- Popup/Menu
set_hl("Pmenu", { fg = colors.fg, bg = colors.bg_muted })
set_hl("PmenuSel", { fg = colors.bright_black, bg = colors.magenta })
set_hl("PmenuSbar", { bg = colors.bg_muted })
set_hl("PmenuThumb", { bg = colors.green })

-- Syntax highlighting (basic)
set_hl("Constant", { fg = colors.red })
set_hl("String", { fg = colors.green })
set_hl("Character", { fg = colors.green })
set_hl("Number", { fg = colors.yellow })
set_hl("Boolean", { fg = colors.yellow })
set_hl("Float", { fg = colors.yellow })

set_hl("Identifier", { fg = colors.red })
set_hl("Function", { fg = colors.bright_blue })

set_hl("Statement", { fg = colors.magenta })
set_hl("Conditional", { fg = colors.magenta })
set_hl("Repeat", { fg = colors.magenta })
set_hl("Label", { fg = colors.bright_magenta })
set_hl("Operator", { fg = colors.fg })
set_hl("Keyword", { fg = colors.magenta })
set_hl("Exception", { fg = colors.magenta })

set_hl("PreProc", { fg = colors.bright_cyan })
set_hl("Include", { fg = colors.magenta })
set_hl("Define", { fg = colors.magenta })
set_hl("Macro", { fg = colors.bright_red })
set_hl("PreCondit", { fg = colors.bright_red })

set_hl("Type", { fg = colors.bright_blue })
set_hl("StorageClass", { fg = colors.bright_magenta })
set_hl("Structure", { fg = colors.bright_blue })
set_hl("Typedef", { fg = colors.bright_blue })

set_hl("Special", { fg = colors.bright_magenta })
set_hl("SpecialChar", { fg = colors.magenta })
set_hl("Tag", { fg = colors.magenta })
set_hl("Delimiter", { fg = colors.fg })
set_hl("SpecialComment", { fg = colors.bright_black })
set_hl("Debug", { fg = colors.bright_cyan })

set_hl("Underlined", { underline = true })
set_hl("Ignore", { fg = colors.bg })
set_hl("Error", { fg = colors.red, bold = true })
set_hl("Todo", { fg = colors.yellow, bold = true, underline = true })

set_hl("Title", { fg = colors.bright_white, bold = true })
set_hl("Directory", { fg = colors.bright_magenta })

-- LSP/Diagnostics
set_hl("DiagnosticError", { fg = colors.red })
set_hl("DiagnosticWarn", { fg = colors.yellow })
set_hl("DiagnosticInfo", { fg = colors.magenta })
set_hl("DiagnosticHint", { fg = colors.cyan })

set_hl("DiagnosticSignError", { fg = colors.red })
set_hl("DiagnosticSignWarn", { fg = colors.yellow })
set_hl("DiagnosticSignInfo", { fg = colors.magenta })
set_hl("DiagnosticSignHint", { fg = colors.cyan })

-- Links
set_hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.yellow })
set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.magenta })
set_hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.cyan })

-- GitSigns
set_hl("GitSignsAdd", { fg = colors.green })
set_hl("GitSignsChange", { fg = colors.magenta })
set_hl("GitSignsDelete", { fg = colors.red })
set_hl("DiffText", { bg = "NONE" })
set_hl("DiffAdd", { bg = "NONE", fg = colors.green })
set_hl("DiffChange", { bg = "NONE", fg = colors.magenta })
set_hl("DiffDelete", { bg = "NONE", fg = colors.red })

-- WinBar
set_hl("WinBar", { bg = colors.bg })
set_hl("WinBarNC", { bg = colors.bg })

-- Terminal
vim.g.terminal_color_0 = colors.black
vim.g.terminal_color_1 = colors.red
vim.g.terminal_color_2 = colors.green
vim.g.terminal_color_3 = colors.yellow
vim.g.terminal_color_4 = colors.blue
vim.g.terminal_color_5 = colors.magenta
vim.g.terminal_color_6 = colors.cyan
vim.g.terminal_color_7 = colors.white
vim.g.terminal_color_8 = colors.bright_black
vim.g.terminal_color_9 = colors.bright_red
vim.g.terminal_color_10 = colors.bright_green
vim.g.terminal_color_11 = colors.bright_yellow
vim.g.terminal_color_12 = colors.bright_blue
vim.g.terminal_color_13 = colors.bright_magenta
vim.g.terminal_color_14 = colors.bright_cyan
vim.g.terminal_color_15 = colors.bright_white

-- Enable true colors
vim.opt.termguicolors = true
