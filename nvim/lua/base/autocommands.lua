-- General autocommands
------------------------

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  --group = vim.api.nvim_create_augroup("checktime"),
  command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = "500" })
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Autosave
vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  pattern = "*", -- All buffers
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.filereadable(vim.fn.bufname("%")) ~= 0 then
      vim.cmd("silent update")
    end
  end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

--
-- Settings for filetypes:
--
-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  --group = vim.api.nvim_create_augroup("close_with_q"),
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

--
-- Terminal
--
-- Auto-close terminal when process exits
vim.api.nvim_create_autocmd("TermClose", {
  callback = function()
    if vim.v.event.status == 0 then
      vim.api.nvim_buf_delete(0, {})
    end
  end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})
