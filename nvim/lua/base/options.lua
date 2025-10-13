-- Sets core Neovim options, UI preferences, and disables built-in plugins.
-- Sign column
vim.opt.number = true          -- Line numbers
vim.opt.relativenumber = false -- Relative line numbers
vim.opt.cursorline = true      -- Highlight current line
vim.opt.wrap = false           -- Don't wrap lines
vim.opt.scrolloff = 10         -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor
vim.opt.ruler = false          -- Show the line and column number of the cursor position, separated by a comma

-- Indentation
vim.opt.tabstop = 2        -- Tab width
vim.opt.shiftwidth = 2     -- Indent width
vim.opt.softtabstop = 2    -- Soft tab stop
vim.opt.expandtab = true   -- Use spaces instead of tabs
vim.opt.smartindent = true -- Smart auto-indenting
vim.opt.autoindent = true  -- Copy indent from current line

-- Search settings
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true  -- Case sensitive if uppercase in search
vim.opt.hlsearch = true   -- Don't highlight search results
vim.opt.incsearch = true  -- Show

-- Visual settings
vim.opt.termguicolors = true                         -- Enable 24-bit colors
vim.opt.signcolumn = "auto"                          -- Always show sign column
vim.opt.colorcolumn = "0"                            -- Show max column highlight at n characters
vim.opt.showmatch = true                             -- Highlight matching brackets
vim.opt.matchtime = 2                                -- How long to show matching bracket
vim.opt.cmdheight = 0                                -- Command line height
vim.opt.completeopt = "menuone,noinsert,popup,fuzzy" -- Completion options
vim.opt.showmode = false                             -- Don't show mode in command line
vim.opt.pumheight = 10                               -- Popup menu height
vim.opt.pumblend = 0                                 -- Popup menu transparency
vim.opt.winblend = 0                                 -- Floating window transparency
vim.opt.conceallevel = 0                             -- Don't hide markup
vim.opt.concealcursor = ""                           -- Don't hide cursor line markup
vim.opt.lazyredraw = true                            -- Don't redraw during macros
vim.opt.synmaxcol = 3000                             -- Syntax highlighting limit

-- File handling
vim.opt.backup = false                            -- Don't create backup files
vim.opt.writebackup = false                       -- Don't create backup before writing
vim.opt.swapfile = false                          -- Don't create swap files
vim.opt.undofile = true                           -- Persistent undo
vim.opt.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
vim.opt.updatetime = 300                          -- Faster completion
vim.opt.timeoutlen = 500                          -- Key timeout duration
vim.opt.ttimeoutlen = 0                           -- Key code timeout
vim.opt.autoread = true                           -- Auto reload files changed outside vim
vim.opt.autowrite = false                         -- Don't auto save

-- Behavior settings
vim.opt.hidden = true                   -- Allow hidden buffers
vim.opt.errorbells = false              -- No error bells
vim.opt.backspace = "indent,eol,start"  -- Better backspace behavior
vim.opt.autochdir = false               -- Don't auto change directory
vim.opt.iskeyword:append("-")           -- Treat dash as part of word
vim.opt.path:append("**")               -- include subdirectories in search
vim.opt.selection = "exclusive"         -- Selection behavior
vim.opt.mouse = "a"                     -- Enable mouse support
vim.opt.clipboard:append("unnamedplus") -- Use system clipboard
vim.opt.modifiable = true               -- Allow buffer modifications
vim.opt.encoding = "UTF-8"              -- Set encoding
vim.opt.shortmess:append("sI")          -- Don't show intro message

-- Folding settings
vim.opt.foldmethod = "indent" -- The kind of folding used for the current window
-- vim.opt.foldmethod = "expr"                         -- Use expression for folding
-- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use treesitter for folding
vim.opt.foldlevel = 99   -- Start with all folds open
vim.opt.foldcolumn = "0" -- When and how to draw the foldcolumn

-- Split behavior
vim.opt.splitbelow = true -- Horizontal splits go below
vim.opt.splitright = true -- Vertical splits go right

-- Key mappings
vim.g.mapleader = " "            -- Set leader key to space
vim.g.maplocalleader = " "       -- Set local leader key (NEW)
vim.opt.whichwrap:append("<>hl") -- go to previous/next line with h,l,left arrow and right arrow when cursor reaches end/beginning of line

-- UI
vim.opt.laststatus = 3            -- Show the status line in the bottom of the screen globally (independently of the buffer)
vim.o.winborder = "rounded"       -- Float window borders
vim.opt.fillchars = { eob = " " } -- remove ~ on empty lines

-- Sessions
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Better diff options
vim.opt.diffopt:append("linematch:60")

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Misc
-- Cool snippet from siduck76 to disable builtin vim plugins
local disabled_built_ins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
  "tutor",
  "rplugin",
  "syntax",
  "synmenu",
  "optwin",
  "compiler",
  "bugreport",
  "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

local default_providers = {
  "node",
  "perl",
  "python3",
  "ruby",
}

for _, provider in ipairs(default_providers) do
  vim.g["loaded_" .. provider .. "_provider"] = 0
end


-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

