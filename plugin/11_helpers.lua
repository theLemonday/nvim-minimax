local new_autocmd = Config.new_autocmd

if vim.g.auto_save_enabled == nil then vim.g.auto_save_enabled = true end

local excluded_filetypes = {
  "gitcommit",
  "NvimTree",
  "Outline",
  "TelescopePrompt",
  "alpha",
  "dashboard",
  "lazygit",
  "neo-tree",
  "oil",
  "prompt",
  "toggleterm",
  "ministarter",
}

local excluded_filenames = {
  ".env",
  "COMMIT_EDITMSG",
  "do-not-autosave-me.lua",
}

new_autocmd({ "InsertLeave", "TextChanged" }, "*", function()
  if not vim.g.auto_save_enabled then return end
  -- 1. Check if the buffer is actually modified
  if not vim.bo.modified then return end

  -- 2. Check for excluded filetypes
  local ft = vim.bo.filetype
  if vim.tbl_contains(excluded_filetypes, ft) then return end

  -- 3. Check for excluded filenames
  local filename = vim.fn.expand("%:t") -- Get only the tail (filename.ext)
  if vim.tbl_contains(excluded_filenames, filename) then return end

  -- 4. Check if the buffer has a name (don't save [No Name] buffers)
  if vim.fn.expand("%") == "" then return end

  -- 5. Save the file
  vim.cmd("silent! update")

  -- 6. Notify the user
  vim.notify("AutoSave: saved " .. filename .. " at " .. vim.fn.strftime("%H:%M:%S"), vim.log.levels.INFO, {
    title = "AutoSave",
    timeout = 1000, -- Hide after 1 second
  })
end, "Notify auto-save")

vim.api.nvim_create_user_command("ToggleAutoSave", function()
  vim.g.auto_save_enabled = not vim.g.auto_save_enabled

  local status = vim.g.auto_save_enabled and "Enabled" or "Disabled"
  vim.notify("AutoSave is now " .. status, vim.log.levels.INFO, {
    title = "System",
  })
end, {})
