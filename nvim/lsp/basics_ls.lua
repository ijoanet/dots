---@brief
---
--- https://github.com/antonk52/basics-language-server/
---
--- Buffer, path, and snippet completion
---
--- ```sh
--- npm install -g basics-language-server
--- ```

---@type vim.lsp.Config
return {
  cmd = { "basics-language-server" },
  settings = {
    buffer = {
      enable = true,
      minCompletionLength = 4,
      matchStrategy = "exact", -- or 'fuzzy'
    },
    path = {
      enable = true,
    },
    snippet = {
      enable = true,
      sources = { vim.fn.expand("~/dots/nvim/snippets") },
      matchStrategy = "exact", -- or 'fuzzy'
    },
  },
}
