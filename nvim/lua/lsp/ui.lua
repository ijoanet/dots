-- Configures LSP UI handlers and diagnostic signs for Neovim.
-- Updated for Neovim 0.10+: borders are configured via vim.lsp.config or client setup
vim.diagnostic.config({
  update_in_insert = true,
  underline = false,
  severity_sort = true,
  signs = false,
  virtual_text = {
    -- Severity filter (optional: show warnings and above)
    -- severity = { min = vim.diagnostic.severity.WARN },
    -- Custom prefix function for severity signs
    -- prefix = function(diagnostic)
    --   if diagnostic.severity == vim.diagnostic.severity.ERROR then
    --     return " "
    --   elseif diagnostic.severity == vim.diagnostic.severity.WARN then
    --     return " "
    --   elseif diagnostic.severity == vim.diagnostic.severity.INFO then
    --     return " "
    --   else -- HINT
    --     return " "
    --   end
    -- end,
    prefix = "",
    -- Show diagnostics as icons
    format = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return " "
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        return " "
      elseif diagnostic.severity == vim.diagnostic.severity.INFO then
        return " "
      else -- HINT
        return " "
      end
    end,
    -- Suppress the full message, showing only the prefix icon
    -- format = function() return nil end,
    -- Optional: spacing before the text
    spacing = 0,
    -- Optional: source name if multiple LSPs
    -- source = "if_many",
  },
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
    source = true,
    header = "",
    prefix = "",
    suffix = "",
  },
})

-- Improve LSP icons
local icons = {
  Class = " ",
  Color = " ",
  Constant = " ",
  Constructor = " ",
  Enum = " ",
  EnumMember = " ",
  Event = " ",
  Field = " ",
  File = " ",
  Folder = " ",
  Function = "󰊕 ",
  Interface = " ",
  Keyword = " ",
  Method = "ƒ ",
  Module = "󰏗 ",
  Property = " ",
  Snippet = " ",
  Struct = " ",
  Text = " ",
  Unit = " ",
  Value = " ",
  Variable = " ",
}

local completion_kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(completion_kinds) do
  completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
end
