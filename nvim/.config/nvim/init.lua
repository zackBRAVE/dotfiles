vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("plugins-setup").setup()
require("core.options")
require("plugins.telescope")
require("plugins.barbaric")
require("plugins.auto-dark-mode")
require("plugins.comment")
require("plugins.lualine")
require("plugins.blink-cmp")
require("plugins.lsp.mason")
require("plugins.lsp.lspconfig")
require("plugins.lsp.conform")
require("plugins.lsp.lint")
require("plugins.autopairs")
require("plugins.treesitter")
require("plugins.gitsigns")
require("core.compile")
require("core.keymaps")
