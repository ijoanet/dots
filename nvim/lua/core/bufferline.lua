local M = {}

local colors = require("ui.colors")

M.config = {
  max_name_length = 22,
  modified_icon = "",
  close_icon = "",
  separator = "",
}

local function setup_highlights()
  local function get_highlight_or_custom(config)
    if config.hl_group then
      return vim.api.nvim_get_hl(0, { name = config.hl_group })
    else
      return { fg = config.fg, bg = config.bg }
    end
  end

  vim.api.nvim_set_hl(0, "BufferlineActive", {
    fg = colors.fg,
    bg = colors.bg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "BufferlineInactive", {
    fg = colors.bright_black,
    bg = colors.bg,
  })
  vim.api.nvim_set_hl(0, "BufferlineModified", {
    fg = colors.green,
    bg = colors.bg,
  })
  vim.api.nvim_set_hl(0, "BufferlineActiveModified", {
    fg = colors.green,
    bg = colors.bg,
    bold = true,
  })
  vim.api.nvim_set_hl(0, "BufferlineSeparator", {
    fg = colors.bg_muted,
  })
end

local function get_valid_buffers()
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    -- Skip invalid buffers (deleted with bd!)
    if not vim.api.nvim_buf_is_valid(buf) then
      goto continue
    end

    local is_loaded = vim.api.nvim_buf_is_loaded(buf)
    local is_listed = vim.api.nvim_buf_get_option(buf, "buflisted")
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")

    -- Include buffers that are listed and are normal files
    if is_listed and buftype == "" then
      table.insert(buffers, buf)
    end

    ::continue::
  end
  return buffers
end

local function get_buffer_name(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return "[No Name]"
  end

  name = vim.fn.fnamemodify(name, ":t")

  if #name > M.config.max_name_length then
    name = "..." .. string.sub(name, #name - M.config.max_name_length + 4)
  end

  return name
end

local function is_buffer_modified(buf)
  return vim.api.nvim_buf_get_option(buf, "modified")
end

local function calculate_buffer_width(buf)
  local name = get_buffer_name(buf)
  local width = 4 + #name -- 4 for padding (2 spaces on each side)

  if is_buffer_modified(buf) and M.config.modified_icon ~= "" then
    width = width + #M.config.modified_icon + 1 -- +1 for space
  else
    width = width + 1 -- space instead of icon
  end

  if M.config.close_icon ~= "" then
    width = width + 1 + #M.config.close_icon -- space + icon
  end

  width = width + 1 -- final space

  -- Add separator width (except for last buffer, but we'll handle that separately)
  if M.config.separator ~= "" then
    width = width + #M.config.separator
  end

  return width
end

local function get_visible_buffer_range(buffers, current_buf_index, available_width)
  if #buffers == 0 then
    return 1, 0, false, false
  end

  -- Reserve space for scroll indicators
  local scroll_indicator_width = 3 -- " < " or " > "
  local working_width = available_width

  -- Calculate all buffer widths
  local buffer_widths = {}
  local total_width = 0
  for i, buf in ipairs(buffers) do
    local width = calculate_buffer_width(buf)
    buffer_widths[i] = width
    total_width = total_width + width
  end

  -- Remove separator from last buffer
  if #buffers > 0 and M.config.separator ~= "" then
    total_width = total_width - #M.config.separator
  end

  -- If all buffers fit, show them all
  if total_width <= available_width then
    return 1, #buffers, false, false
  end

  -- Need to scroll - reserve space for indicators
  working_width = working_width - (2 * scroll_indicator_width)

  -- Find the range that includes the current buffer and fits in available space
  local start_idx = current_buf_index
  local end_idx = current_buf_index
  local current_width = buffer_widths[current_buf_index]

  -- Remove separator from current buffer if it's the only one
  if M.config.separator ~= "" then
    current_width = current_width - #M.config.separator
  end

  -- Expand range while we have space
  while current_width <= working_width do
    local expanded = false

    -- Try to add buffer to the right
    if end_idx < #buffers then
      local next_width = buffer_widths[end_idx + 1]
      if end_idx + 1 == #buffers and M.config.separator ~= "" then
        next_width = next_width - #M.config.separator
      end
      if current_width + next_width <= working_width then
        end_idx = end_idx + 1
        current_width = current_width + next_width
        expanded = true
      end
    end

    -- Try to add buffer to the left
    if start_idx > 1 then
      local prev_width = buffer_widths[start_idx - 1]
      if current_width + prev_width <= working_width then
        start_idx = start_idx - 1
        current_width = current_width + prev_width
        expanded = true
      end
    end

    -- If we couldn't expand in either direction, break
    if not expanded then
      break
    end
  end

  -- Determine if we need scroll indicators
  local has_left = start_idx > 1
  local has_right = end_idx < #buffers

  return start_idx, end_idx, has_left, has_right
end

local function render_buffer(buf, is_current)
  local name = get_buffer_name(buf)
  local modified = is_buffer_modified(buf)

  local base_hl_group = is_current and "BufferlineActive" or "BufferlineInactive"
  local name_hl_group

  if modified then
    name_hl_group = is_current and "BufferlineActiveModified" or "BufferlineModified"
  else
    name_hl_group = base_hl_group
  end

  local content = "  %#" .. name_hl_group .. "#" .. name .. "%#" .. base_hl_group .. "#"

  if modified and M.config.modified_icon ~= "" then
    local icon_hl = is_current and "BufferlineActiveModified" or "BufferlineModified"
    content = content .. "%#" .. icon_hl .. "#" .. M.config.modified_icon .. "%#" .. base_hl_group .. "#"
  else
    content = content .. " "
  end

  if M.config.close_icon ~= "" then
    content = content .. " " .. M.config.close_icon
  end

  content = content .. " "

  return "%#" .. base_hl_group .. "#" .. content .. "%#Normal#"
end

function M.render()
  local buffers = get_valid_buffers()
  if #buffers == 0 then
    return ""
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_buf_index = 1

  -- Find current buffer index
  for i, buf in ipairs(buffers) do
    if buf == current_buf then
      current_buf_index = i
      break
    end
  end

  -- Get available width (use most of the terminal width)
  local available_width = vim.o.columns * 1.15

  -- Get visible buffer range
  local start_idx, end_idx, has_left, has_right = get_visible_buffer_range(buffers, current_buf_index, available_width)

  local tabline = ""

  -- Add left scroll indicator
  if has_left then
    tabline = tabline .. "%#BufferlineInactive#.. "
  end

  -- Render visible buffers
  for i = start_idx, end_idx do
    local buf = buffers[i]
    local is_current = buf == current_buf
    local buffer_content = render_buffer(buf, is_current)
    tabline = tabline .. buffer_content

    -- Add separator (except for last visible buffer)
    if i < end_idx then
      tabline = tabline .. "%#BufferlineSeparator#" .. M.config.separator
    end
  end

  -- Add right scroll indicator
  if has_right then
    tabline = tabline .. "%#BufferlineInactive# .."
  end

  tabline = tabline .. "%="

  return tabline
end

function M.close_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.cmd("bdelete " .. buf)
  end
end

function M.next_buffer()
  local buffers = get_valid_buffers()
  if #buffers <= 1 then
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_index = 1

  for i, buf in ipairs(buffers) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  local next_index = current_index < #buffers and current_index + 1 or 1
  vim.api.nvim_set_current_buf(buffers[next_index])
end

function M.prev_buffer()
  local buffers = get_valid_buffers()
  if #buffers <= 1 then
    return
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local current_index = 1

  for i, buf in ipairs(buffers) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  local prev_index = current_index > 1 and current_index - 1 or #buffers
  vim.api.nvim_set_current_buf(buffers[prev_index])
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  setup_highlights()

  vim.o.tabline = '%!v:lua.require("core.bufferline").render()'
  vim.o.showtabline = 2

  local augroup = vim.api.nvim_create_augroup("Bufferline", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufAdd",
    "BufDelete",
    "BufUnload",
    "BufWipeout",
    "BufFilePost",
    "BufWritePost",
  }, {
    group = augroup,
    callback = function()
      vim.schedule(function()
        vim.cmd("redrawtabline")
      end)
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    callback = function()
      vim.cmd("redrawtabline")
    end,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = function()
      setup_highlights()
    end,
  })

  -- Force initial redraw
  vim.schedule(function()
    vim.cmd("redrawtabline")
  end)
end

M.setup()

return M
