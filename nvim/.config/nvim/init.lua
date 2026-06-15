if vim.g.vscode then
	vim.opt.clipboard:append("unnamedplus")
	require("plugins-setup").setup_vscode()

	require("core.keymaps")
else
	vim.g.loaded_netrw = 1
	vim.g.loaded_netrwPlugin = 1
	require("plugins-setup").setup()
	require("core.options")
	require("plugins.comment")
	require("plugins.lualine")
	require("plugins.nvim-cmp")
	require("plugins.lsp.mason")
	require("plugins.lsp.lspconfig")
	require("plugins.lsp.conform")
	require("plugins.lsp.lint")
	require("plugins.autopairs")
	require("plugins.treesitter")
	require("plugins.gitsigns")
	require("plugins.auto-dark-mode")
	require("core.keymaps")
end
