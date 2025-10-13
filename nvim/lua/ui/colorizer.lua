--
-- IMPORT
--
vim.pack.add({
  { src = "https://github.com/catgoose/nvim-colorizer.lua" },
})
local present, colorizer = pcall(require, "colorizer")
if not present then
  vim.notify("[colorizer] not loaded")
  return
end

--
-- SETUP
--
colorizer.setup()
