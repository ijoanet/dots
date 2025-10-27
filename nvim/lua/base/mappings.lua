-- Defines custom key mappings for Neovim using a utility function.
-- General
-- copy whole file content
vim.keymap.set("n", "<C-c>", "<cmd> %y+ <CR>", { desc = "Copy whole file content" })
-- select whole file content
vim.keymap.set("n", "<C-a>", "ggVG <CR>", { desc = "Select all" })
-- save file
-- vim.keymap.set("n", "<C-s>", "<cmd> wqa! <CR>")
-- toggle numbers
vim.keymap.set("n", "<leader>n", ":set nu!<CR>", { desc = "Toggle line numbers" })
-- Don't copy the replaced text after pasting in visual mode
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without yanking" })
-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Comments
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comments", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comments", remap = true })

-- Center after C-u and C-d
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("v", "<C-d>", "<C-d>zz")
vim.keymap.set("v", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
-- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- empty mode is same as using :map
vim.keymap.set("", "j", 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set("", "k", 'v:count ? "k" : "gk"', { expr = true })
vim.keymap.set("", "<Down>", 'v:count ? "j" : "gj"', { expr = true })
vim.keymap.set("", "<Up>", 'v:count ? "k" : "gk"', { expr = true })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Move current line / block with Alt-j/k ala vscode.
vim.keymap.set("n", "<A-k>", "<cmd> m .-2 <CR>==")
vim.keymap.set("n", "<A-j>", "<cmd> m .+1 <CR>==")
vim.keymap.set("i", "<A-j>", "<Esc><cmd> m .+1 <CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc><cmd> m .-2 <CR>==gi")
vim.keymap.set("x", "<A-j>", "<cmd> m '>+1 <CR> gv-gv")
vim.keymap.set("x", "<A-k>", "<cmd> m '<-2 <CR> gv-gv")

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- use ESC to turn off search highlighting
vim.keymap.set("n", "<Esc>", ":noh<CR>")

-- close buffer
vim.keymap.set("n", "<S-x>", "<cmd> bd! <CR>")

-- move between tabs
vim.keymap.set("n", "<TAB>", ":bnext <CR>")
vim.keymap.set("n", "<S-TAB>", ":bprev <CR>")


vim.keymap.set("n", "<C-Space>y", function()
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  vim.fn.system("tmux new-window -c " .. vim.fn.shellescape(current_dir) .. " yazi")
end, { desc = "Open yazi in current buffer directory" })
