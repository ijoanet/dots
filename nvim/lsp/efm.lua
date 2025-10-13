--- @brief
---
--- https://github.com/mattn/efm-langserver
---
--- General purpose Language Server that can use specified error message format generated from specified command.
---
--- Requires at minimum EFM version [v0.0.38](https://github.com/mattn/efm-langserver/releases/tag/v0.0.38) to support
--- launching the language server on single files.
---
--- Note: In order for neovim's built-in language server client to send the appropriate `languageId` to EFM, **you must
--- specify `filetypes` in your call to `vim.lsp.config`**. Otherwise the server will be launch on the `BufEnter` instead
--- of the `FileType` autocommand, and the `filetype` variable used to populate the `languageId` will not yet be set.
---
--- ```lua
--- vim.lsp.config('efm', {
---   filetypes = { 'python','cpp','lua' }
---   settings = ..., -- You must populate this according to the EFM readme
--- })
--- ```

---@type vim.lsp.Config
return {
  cmd = { "efm-langserver" },
  init_options = { documentFormatting = true },
  filetypes = { "go", "json", "tf", "hcl", "rust" },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      json = {
        {
          formatCommand = "jq .",
          formatStdin = true,
        },
      },
      tf = {
        {
          formatCommand = "terraform fmt -",
          formatStdin = true,
        },
        {
          lintCommand = "terraform validate -json",
          lintStdin = true,
          lintFormats = { "%f:%l:%c: %m" },
        },
      },
      hcl = {
        {
          formatCommand = "terraform fmt -",
          formatStdin = true,
        },
        {
          lintCommand = "terraform validate -json",
          lintStdin = true,
          lintFormats = { "%f:%l:%c: %m" },
        },
      },
      go = {
        {
          formatSource = "goimports",
          formatCommand = "goimports",
          formatStdin = true,
          rootMarkers = { "go.mod", "go.work" },
        },
      },
      rust = {
        {
          formatCommand = "rustfmt",
          formatStdin = true,
        },
      },
    },
  },
}
