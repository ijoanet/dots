--
-- IMPORT
--
vim.pack.add({
  { src = 'https://github.com/olimorris/onedarkpro.nvim' },
})
local present, onedarkpro = pcall(require, "onedarkpro")
if not present then
  vim.notify("[onedarkpro] not loaded")
  return
end

--
-- SETUP
--
local colors = require('ui.colors')

onedarkpro.setup({
  theme = 'onedark_dark',                                                -- The default dark theme
  caching = false,                                                       -- Use caching for the theme?
  cache_path = vim.fn.expand(vim.fn.stdpath('cache') .. '/onedarkpro/'), -- The path to the cache directory
  colors = colors,                                                       -- Override default colors by specifying colors for 'onelight' or 'onedark' themes
  highlights = {
    VertSplit = {
      fg = '${black}',
      bg = '${black}',
    },
    WinSeparator = {
      fg = '${black}',
      bg = '${black}',
    },

    MsgArea = {
      bg = '${bg}',
    },

    Float = {
      bg = '${bg}',
    },
    NormalFloat = {
      link = 'Float',
    },
    FloatBorder = {
      fg = '${green}',
      bg = '${bg}',
    },

    CursorLine = {
      bg = '${light_black}',
    },
    CursorLineNr = {
      fg = '${purple}',
      bg = '${light_black}',
    },
    LineNr = {
      fg = '${gray}',
    },

    -- Telescope
    TelescopeNormal = {
      bg = '${bg}',
    },
    TelescopeTitle = {
      bg = '${bg}',
    },
    TelescopePrompt = {
      bg = '${bg}',
    },
    TelescopePromptBorder = {
      fg = '${light_black}',
      bg = '${bg}',
    },
    TelescopeBorder = {
      bg = '${bg}',
    },
    TelescopeResultsNormal = {
      bg = '${bg}',
    },
    TelescopeResultsBorder = {
      fg = '${light_black}',
      bg = '${bg}',
    },
    TelescopePreviewNormal = {
      bg = '${bg}',
    },
    TelescopePreviewBorder = {
      fg = '${light_black}',
    },
    TelescopeMultiSelection = {
      fg = '${purple}',
      bg = '${light_black}',
    },
    TelescopeMultipleSelection = {
      fg = '${purple}',
      bg = '${light_black}',
    },

    -- Cmp
    Pmenu = {
      bg = '${light_black}',
    },
    PmenuSbar = {
      fg = '${light_black}',
      bg = '${light_black}',
    },
    PmenuSel = {
      fg = '${purple}',
      bg = '${light_gray}',
    },

    -- LSP
    LspFloatWinBorder = {
      link = 'FloatBorder',
    },
    LspSagaDiagnosticSource = {
      fg = '${comment}',
    },
    TSDefinitionUsage = {
      bg = '${gray}',
    },
    TroubleNormal = {
      bg = '${black}',
    },
    TroubleIndent = {
      fg = '${light_black}',
      bg = '${black}',
    },
    LspSagaLightBulb = {
      fg = '${yellow}',
    },

    -- Indent Lines
    IndentBlanklineIndent1 = {
      fg = '${gray}',
    },
    IndentBlanklineIndent2 = {
      fg = '${light_black}',
    },

    -- NvimTree
    NvimTreeNormal = {
      bg = '${black}',
    },
    NvimTreeNormalNC = {
      link = 'NvimTreeNormal',
    },

    -- Git
    GitSignsCurrentLineBlame = {
      fg = '${comment}',
    },
    GitSignsAdd = {
      fg = '${green}',
    },

    -- Diffview
    DiffviewStatusAdded = {
      fg = '${green}',
    },
    DiffviewStatusCopied = {
      fg = '${green}',
    },
    DiffviewStatusRenamed = {
      fg = '${green}',
    },
    DiffviewStatusModified = {
      fg = '${green}',
    },
    DiffviewStatusUnmerged = {
      fg = '${green}',
    },
    DiffviewStatusUntracked = {
      fg = '${green}',
    },
    DiffviewStatusTypeChange = {
      fg = '${green}',
    },
    DiffviewFilePanelInsertions = {
      fg = '${green}',
    },

    -- Copilot
    CopilotSuggestion = {
      fg = '${comment}',
    },
  },            -- Override default highlight and/or filetype groups
  filetypes = { -- Override which filetype highlight groups are loaded
  },
  plugins = {   -- Override which plugin highlight groups are loaded
    -- See the Supported Plugins section for a list of available plugins
  },
  styles = { -- Choose from "bold,italic,underline"
    types = 'bold',
    numbers = 'NONE',
    strings = 'NONE',
    comments = 'italic',
    keywords = 'bold,italic',
    constants = 'NONE',
    functions = 'italic',
    operators = 'NONE',
    variables = 'NONE',
    conditionals = 'italic',
    virtual_text = 'italic',
  },
  options = {
    bold = true,                    -- Use bold styles?
    italic = true,                  -- Use italic styles?
    underline = true,               -- Use underline styles?
    undercurl = true,               -- Use undercurl styles?

    cursorline = true,              -- Use cursorline highlighting?
    transparency = false,           -- Use a transparent background?
    terminal_colors = true,         -- Use the theme's colors for Neovim's :terminal?
    window_unfocused_color = false, -- When the window is out of focus, change the normal background?
  },
})

vim.cmd('colorscheme onedark')
