local new_autocmd = Config.new_autocmd

if vim.g.auto_save_enabled == nil then vim.g.auto_save_enabled = true end

local auto_format_file_max_lines = 5000
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

local autosave_group = vim.api.nvim_create_augroup("AutoSaveGroup", { clear = true })

-- 2. Create the Autocommand
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = autosave_group,
  nested = true,
  pattern = "*",
  desc = "AutoSave on modification with Conform formatting",
  callback = function()
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

    -- 5. Format and Save (with Error Handling)
    local bufnr = vim.api.nvim_get_current_buf()

    local line_count = vim.api.nvim_buf_line_count(bufnr)

    if line_count > auto_format_file_max_lines then
      -- Notify the user that we are skipping this file
      vim.notify(
        string.format("AutoSave Skipped: File too large (%d lines > %d limit)", line_count, auto_format_file_max_lines),
        vim.log.levels.WARN,
        { title = "Performance Guard" }
      )
      return -- Do not format this buffer
    end

    vim.cmd("silent! update")
    vim.notify("AutoSave: saved " .. filename .. " at " .. vim.fn.strftime("%H:%M:%S"), vim.log.levels.INFO, {
      title = "AutoSave",
      timeout = 1000,
    })
    -- conform.format({ bufnr = bufnr, async = true }, function(err)
    --   if err then
    --     vim.notify("AutoSave Format Failed: " .. tostring(err), vim.log.levels.ERROR, {
    --       title = "Conform Error",
    --       timeout = 3000,
    --     })
    --   else
    --     vim.notify("AutoSave: saved " .. filename .. " at " .. vim.fn.strftime("%H:%M:%S"), vim.log.levels.INFO, {
    --
    --       title = "AutoSave",
    --       timeout = 1000,
    --     })
    --   end
    -- end)
  end,
})

vim.api.nvim_create_user_command("ToggleAutoSave", function()
  vim.g.auto_save_enabled = not vim.g.auto_save_enabled

  local status = vim.g.auto_save_enabled and "Enabled" or "Disabled"
  vim.notify("AutoSave is now " .. status, vim.log.levels.INFO, {
    title = "System",
  })
end, {})
