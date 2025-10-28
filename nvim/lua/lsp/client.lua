-- LSP client setup
require("lsp.ui")
-- require("lsp.custom_completion")
require('lsp.blink')
require("lsp.commands")

vim.lsp.enable({
  -- shell
  "bashls",
  -- path, buffer and snippets (useful when not using blink.cmp)
  -- "basics_ls",
  -- lua
  "lua_ls",
  -- "stylua", -- IDK but likes to breat my code lol
  -- JS/TS
  "html",
  "cssls",
  "cssmodules_ls",
  "css_variables",
  "ts_ls",
  -- configs
  "jsonls",
  "yamlls",
  -- go
  "golangci_lint_ls",
  "gopls",
  -- rust
  "rust_analyzer",
  -- infra
  "docker_language_server",
  -- "terraformls",
  "terraform_lsp",
  "tflint",
  -- linters/formatters
  "efm",
  -- ai
  "copilot",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom.lsp.client", { clear = true }),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- Inlay Hints
    if client.server_capabilities.inlayHintProvider then
      -- vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })

      vim.keymap.set("n", "<leader>ti", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }), { bufnr = args.buf })
      end, { buffer = args.buf, desc = "LSP: Toggle inlay hints", silent = true })
    end

    -- Formatting
    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ bufnr = args.buf })
      end, { buffer = args.buf, desc = "LSP: Format current buffer", silent = true })
    end

    -- Hover information
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = args.buf, desc = 'Hover', silent = true })

    -- Signature help (Insert mode)
    vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, { buffer = args.buf, desc = 'Signature help', silent = true })

    -- Rename symbol
    if client:supports_method('textDocument/rename') then
      vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, { buffer = args.buf, desc = 'Rename', silent = true })
    end

    -- Code actions
    if client:supports_method('textDocument/codeAction') then
      vim.keymap.set({ 'n', 'v' }, '<leader>ga', vim.lsp.buf.code_action, { buffer = args.buf, desc = 'Code action', silent = true })
    end

    -- Go to definition
    if client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', ':lua Snacks.picker.lsp_definitions()<CR>',
        { buffer = args.buf, desc = 'Peek definition', silent = true })
      -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = args.buf, desc = 'Go to definition' })
    end

    -- Go to declaration
    if client:supports_method('textDocument/declaration') then
      vim.keymap.set('n', '<leader>gd', ":lua Snacks.picker.lsp_declarations()<CR>",
        { buffer = args.buf, desc = 'Peek declaration', silent = true })
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = args.buf, desc = 'Go to declaration', silent = true })
    end

    -- References
    if client:supports_method('textDocument/references') then
      vim.keymap.set('n', 'gr', ":lua Snacks.picker.lsp_references()<CR>",
        { buffer = args.buf, desc = 'Peek references', silent = true })
      -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = args.buf, desc = 'References' })
    end

    -- Document symbols
    if client:supports_method('textDocument/documentSymbol') then
      vim.keymap.set('n', '<leader>ds', ":lua Snacks.picker.lsp_symbols()<CR>",
        { buffer = args.buf, desc = 'Peek document symbols', silent = true })
      -- vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, { buffer = args.buf, desc = 'Document symbols' })
    end

    -- Workspace symbols
    if client:supports_method('workspace/symbol') then
      vim.keymap.set('n', '<leader>ws', ":lua Snacks.picker.lsp_workspace_symbols()<CR>",
        { buffer = args.buf, desc = 'Peek workspace symbols', silent = true })
      -- vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol,
      --   { buffer = args.buf, desc = 'Workspace symbols' })
    end

    if client:supports_method('workspace/diagnostic') then
      vim.keymap.set('n', '<leader>ws', ":lua Snacks.picker.lsp_workspace_symbols()<CR>",
        { buffer = args.buf, desc = 'Peek workspace symbols', silent = true })
      -- vim.keymap.set('n', '<leader>wd', vim.lsp.buf.workspace_diagnostics,
      --   { buffer = args.buf, desc = 'Workspace diagnostics' })
    end


    -- Type definition
    if client:supports_method('textDocument/typeDefinition') then
      vim.keymap.set('n', 'gt', ":lua Snacks.picker.lsp_type_definitions()<CR>",
        { buffer = args.buf, desc = 'Peek type definition', silent = true })
      -- vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = args.buf, desc = 'Type definition' })
    end

    -- Implementation
    if client:supports_method('textDocument/implementation') then
      vim.keymap.set('n', 'gi', ":lua Snacks.picker.lsp_implementations()<CR>",
        { buffer = args.buf, desc = 'Peek implementation', silent = true })
      -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = args.buf, desc = 'Implementation' })
    end

    -- Diagnostic navigation (using vim.diagnostic.jump; buffer-local for LSP buffers)
    vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, wrap = true }) end,
      { buffer = args.buf, desc = 'Previous diagnostic', silent = true })
    vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, wrap = true }) end,
      { buffer = args.buf, desc = 'Next diagnostic', silent = true })

    -- Other diagnostic keymaps (unchanged, as they don't use deprecated funcs)
    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { buffer = args.buf, desc = 'Float diagnostic', silent = true })
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { buffer = args.buf, desc = 'Location list', silent = true })
  end,
})
