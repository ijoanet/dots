-- Main features:
-- * uses vim.pack to handle plugins
-- * does not use mason, so, install lsp manually
-- * tmux integration:
--    * Delegates some features to other windows (ie: lazygit)
--    * Move between panes and windows
--    * Handle resize and swapping
-- * folke/picker as the main picker
-- * custom bufferline
-- * custom status line
-- * custom completion

--
-- BASE: Non-plugin related setup
--
require("base.autocommands")
require("base.options")
require("base.mappings")
require("base.commands")

--
-- UI: Nvim styling
--
require("ui.colorscheme")
require("ui.colorizer")

--
-- CORE: Core plugins
--
require("core.picker")
require("core.bufferline")
require("core.gitsigns")
require("core.statusline")
require("core.tmux")

--
-- EDITING: Editing related plugins
--
require("editing.surround")

--
-- LSP: LSP clients, completion, treesitter,...
--
require("lsp.client")
require("lsp.treesitter")

--
-- AI: AI related
--
require("ai.opencode")
