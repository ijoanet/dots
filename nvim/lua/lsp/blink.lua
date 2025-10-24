-- Configures blink.cmp completion plugin for Neovim.
vim.pack.add({
  { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range('*') }
})

local present, blink = pcall(require, 'blink.cmp')
if not present then
  vim.notify('[blink.cmp] not loaded', vim.log.levels.ERROR)
  return
end

blink.setup({
  keymap = {
    ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
    ['<C-e>'] = { 'hide', 'fallback' },
    ['<CR>'] = { 'accept', 'fallback' },

    ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },

    ['<Up>'] = { 'select_prev', 'fallback' },
    ['<Down>'] = { 'select_next', 'fallback' },
    ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

    ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
    ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

    -- ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
  },
  -- Appearance configuration
  appearance = {
    nerd_font_variant = 'mono',
  },
  -- Completion configuration
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
      window = {
        border = 'single',
      },
    },
    menu = {
      border = 'none',
      draw = {
        treesitter = { 'lsp' },
      },
    },
    list = {
      selection = {
        preselect = false,
        auto_insert = true, -- Auto insert like your Tab behavior
      },
    },
    ghost_text = { enabled = false }, -- Disabled like in your config
  },
  -- Sources configuration - equivalent to your nvim-cmp sources
  sources = {
    default = { 'lsp', 'buffer', 'snippets', 'path' },
    per_filetype = {
      -- Add specific sources for specific filetypes if needed
    },
    providers = {
      -- Built-in providers are automatically configured
      -- You can customize them here if needed
      buffer = {
        opts = {
          -- get all buffers, even ones like neo-tree
          -- get_bufnrs = vim.api.nvim_list_bufs
          -- or (recommended) filter to only "normal" buffers
          get_bufnrs = function()
            return vim.tbl_filter(function(bufnr)
              return vim.bo[bufnr].buftype == ''
            end, vim.api.nvim_list_bufs())
          end
        }
      },
      snippets = {
        opts = {
          friendly_snippets = true, -- default
        }
      }
    }
  },
  -- Signature help configuration
  signature = {
    enabled = true,
    window = {
      border = 'rounded',
    },
  },

  -- Fuzzy matching configuration
  fuzzy = {
    -- NOTE: Since we are using vim.pack, we use lua (no build directive yet)
    implementation = 'prefer_rust_with_warning', -- Use Rust implementation for better performance
    sorts = {
      'exact',
      -- defaults
      'score',
      'sort_text',
    },
  },

  -- snippets = { preset = 'luasnip' },
})

-- Handle Copilot integration (equivalent to your copilot event handlers)
-- local copilot_present, _ = pcall(require, 'copilot')
-- if copilot_present then
--   vim.api.nvim_create_autocmd('User', {
--     pattern = 'BlinkCmpMenuOpen',
--     callback = function()
--       vim.b.copilot_suggestion_hidden = false
--     end,
--   })
--
--   vim.api.nvim_create_autocmd('User', {
--     pattern = 'BlinkCmpMenuClose',
--     callback = function()
--       vim.b.copilot_suggestion_hidden = false
--     end,
--   })
-- end
