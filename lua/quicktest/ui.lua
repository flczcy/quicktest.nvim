local event = require("nui.utils.autocmd").event
local Popup = require("nui.popup")
local Split = require("nui.split")

local M = {}

local api = vim.api

local split_buf = api.nvim_create_buf(false, true)
local popup_buf = api.nvim_create_buf(false, true)

vim.api.nvim_set_option_value("undolevels", -1, { buf = split_buf })
vim.api.nvim_set_option_value("undolevels", -1, { buf = popup_buf })

vim.api.nvim_set_option_value("filetype", "quicktest-output", { buf = split_buf })
vim.api.nvim_set_option_value("filetype", "quicktest-output", { buf = popup_buf })

--- @type NuiSplit | nil
local split
--- @type NuiPopup | nil
local popup

M.buffers = { split_buf, popup_buf }
M.is_split_opened = false
M.is_popup_opened = false

---@param opts WinOpts
local function open_popup(opts)
  opts = opts or {}
  opts.text = opts.text or {}
  popup = Popup({
    enter = true,
    zindex = 50,
    bufnr = popup_buf,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = opts.title or opts.text.title,
        top_align = opts.text.top_align or "center",
        bottom = opts.text.bottom,
        bottom_align = opts.text.bottom_align or "left",
      },
    },
    position = {
      row = "40%",
      col = "50%",
    },
    size = {
      width = "70%",
      height = "67%",
    },
    buf_options = {
      readonly = false,
      modifiable = true,
    },
    win_options = {
      -- 这是设置 > 0 透明度,会导致光标下面显示弹窗背后的字符
      winblend = 0,
      winhighlight = table.concat({
        'Normal:AdaptiveFloatNormal_',
        'NormalFloat:AdaptiveFloatNormal_',
        'FloatTitle:AdaptiveFloatTitle_',
        'FloatBorder:AdaptiveFloatBorder_',
      }, ','),
      -- winhighlight = "Normal:Normal_,NormalFloat:NormalFloat_,FloatBorder:FloatBorder_,FloatTitle:FloatTitle_",
    },
  })

  vim.api.nvim_set_option_value("wrap", true, { win = popup.winid })

  popup:on(event.WinClosed, function()
    M.is_popup_opened = false

    popup = nil
  end, { once = true })

  popup:mount()

  M.is_popup_opened = true

  return popup
end

---@param mode WinModeWithoutAuto
local function open_split(mode)
  local position = ({ split = 'bottom', split_right = 'right' })[mode]
  local size = ({ bottom = '30%', right = 80 })
  split = Split({
    relative = "editor",
    position = position,
    size = size,
    enter = false,
    win_options = {
      -- 这是设置 > 0 透明度,会导致光标下面显示弹窗背后的字符
      winblend = 0,
      winhighlight = table.concat({
        'Normal:AdaptiveFloatNormal_',
        'NormalFloat:AdaptiveFloatNormal_',
        'FloatTitle:AdaptiveFloatTitle_',
        'FloatBorder:AdaptiveFloatBorder_',
      }, ','),
      -- winhighlight = "Normal:Normal_,NormalFloat:NormalFloat_,FloatBorder:FloatBorder_,FloatTitle:FloatTitle_",
    },
  })
  split.bufnr = split_buf

  if position == 'right' then
    vim.api.nvim_set_option_value("wrap", true, { win = split.winid })
  else
    vim.api.nvim_set_option_value("wrap", false, { win = split.winid })
  end

  split:on(event.WinClosed, function()
    M.is_split_opened = false
  end, { once = true })

  -- mount/open the component
  split:mount()

  M.is_split_opened = true

  return split
end

---@param mode WinModeWithoutAuto
local function try_open_split(mode)
  if not M.is_split_opened then
    open_split(mode)
  end
end

---@param opts WinOpts
local function try_open_popup(opts)
  if not M.is_popup_opened then
    open_popup(opts)
  end
end

---@param mode WinModeWithoutAuto
---@param opts WinOpts
function M.try_open_win(mode, opts)
  if mode == "popup" then
    try_open_popup(opts)
  else
    try_open_split(mode)
  end
end

---@param mode WinModeWithoutAuto
function M.try_close_win(mode)
  if mode == "popup" then
    if popup then
      popup:hide()
    end
  else
    if split then
      split:hide()
    end
  end
end

---@param buf number
---@param last number | nil
function M.scroll_down(buf, last)
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    local win_bufnr = vim.api.nvim_win_get_buf(win)
    if win_bufnr == buf then
      local line_count = vim.api.nvim_buf_line_count(buf)

      if line_count < 3 then
        return
      end
      if last == -1 then
        vim.api.nvim_win_set_cursor(win, { line_count, 0 })
      else
        vim.api.nvim_win_set_cursor(win, { line_count - 2, 0 })
      end
    end
  end
end

---@param buf number
function M.should_continue_scroll(buf)
  local windows = vim.api.nvim_list_wins()
  for _, win in ipairs(windows) do
    local win_bufnr = vim.api.nvim_win_get_buf(win)
    if win_bufnr == buf then
      local current_pos = vim.api.nvim_win_get_cursor(win)
      local line_count = vim.api.nvim_buf_line_count(buf)

      return current_pos[1] >= line_count - 2
    end
  end
end

return M
