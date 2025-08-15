-- neovim.lua for kaspa theme

-- Define the kaspa color palette
local colors = {
  black = "#231F20",       -- KASPA_BLACK
  white = "#FFFFFF",       -- KASPA_WHITE
  grey = "#B6B6B6",        -- KASPA_GREY
  teal_primary = "#70C7BA", -- KASPA_PRIMARY_TEAL
  teal_accent = "#49EACB",  -- KASPA_ACCENT_TEAL
  red = "#f7768e",
  green = "#9ece6a",
  yellow = "#e0af68",
  blue = "#7aa2f7",
  magenta = "#bb9af7",
  cyan = "#7dcfff"
}

-- Apply the colors to Neovim highlight groups
vim.api.nvim_set_hl(0, "Normal", { bg = colors.black, fg = colors.white })
vim.api.nvim_set_hl(0, "Visual", { bg = colors.teal_primary, fg = colors.black })
vim.api.nvim_set_hl(0, "Comment", { fg = colors.grey, italic = true })
vim.api.nvim_set_hl(0, "Keyword", { fg = colors.teal_primary, bold = true })
vim.api.nvim_set_hl(0, "String", { fg = colors.teal_accent })
vim.api.nvim_set_hl(0, "Number", { fg = colors.magenta })
vim.api.nvim_set_hl(0, "Boolean", { fg = colors.magenta })
vim.api.nvim_set_hl(0, "Function", { fg = colors.blue })
vim.api.nvim_set_hl(0, "Type", { fg = colors.green })
vim.api.nvim_set_hl(0, "Special", { fg = colors.cyan })
vim.api.nvim_set_hl(0, "Error", { fg = colors.red, bold = true })
vim.api.nvim_set_hl(0, "Warning", { fg = colors.yellow })
vim.api.nvim_set_hl(0, "Info", { fg = colors.blue })

-- Status line colors
vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.teal_primary, fg = colors.black })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.grey, fg = colors.black })

-- Line numbers
vim.api.nvim_set_hl(0, "LineNr", { fg = colors.grey })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.teal_accent, bold = true })

-- Search highlights
vim.api.nvim_set_hl(0, "Search", { bg = colors.teal_accent, fg = colors.black })
vim.api.nvim_set_hl(0, "IncSearch", { bg = colors.teal_primary, fg = colors.black })

print("Kaspa theme loaded for Neovim!")