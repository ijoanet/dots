--
-- IMPORT
--
vim.pack.add({
  { src = "https://github.com/aserowy/tmux.nvim" },
})
local present, tmux = pcall(require, "tmux")
if not present then
  vim.notify("[tmux] not loaded")
  return
end

--
-- SETUP
--
tmux.setup({
  navigation = {
    -- cycles to opposite pane while navigating into the border
    cycle_navigation = true,
    -- enables default keybindings (C-hjkl) for normal mode
    enable_default_keybindings = false,
    -- prevents unzoom tmux when navigating beyond vim border
    persist_zoom = true,
  },
  resize = {
    -- enables default keybindings (A-hjkl) for normal mode
    enable_default_keybindings = false,
    -- sets resize steps for x axis
    resize_step_x = 5,
    -- sets resize steps for y axis
    resize_step_y = 5,
  },
  swap = {
    -- cycles to opposite pane while navigating into the border
    cycle_navigation = true,
    -- enables default keybindings (C-A-hjkl) for normal mode
    enable_default_keybindings = false,
  },
})

--
-- KEYMAPS
--
-- Navigate between vim and tmux splits using Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<cmd>lua require('tmux').move_left()<CR>")
vim.keymap.set("n", "<C-j>", "<cmd>lua require('tmux').move_bottom()<CR>")
vim.keymap.set("n", "<C-k>", "<cmd>lua require('tmux').move_top()<CR>")
vim.keymap.set("n", "<C-l>", "<cmd>lua require('tmux').move_right()<CR>")
-- Resize vim splits using Ctrl + arrow keys
vim.keymap.set("n", "<C-Left>", "<cmd>lua require('tmux').resize_left()<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>lua require('tmux').resize_bottom()<CR>")
vim.keymap.set("n", "<C-Up>", "<cmd>lua require('tmux').resize_top()<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>lua require('tmux').resize_right()<CR>")

-- Swap vim splits using prefix + arrow keys
vim.keymap.set("n", "<C-Space><Left>", "<cmd>lua require('tmux').swap_left()<CR>")
vim.keymap.set("n", "<C-Space><Down>", "<cmd>lua require('tmux').swap_bottom()<CR>")
vim.keymap.set("n", "<C-Space><Up>", "<cmd>lua require('tmux').swap_top()<CR>")
vim.keymap.set("n", "<C-Space><Right>", "<cmd>lua require('tmux').swap_right()<CR>")
