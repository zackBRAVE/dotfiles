vim.g.lazygit_floating_window_winblend = 5
vim.g.lazygit_floating_window_scaling_factor = 0.85
vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local ok, utils = pcall(require, "lazygit.utils")
		if ok then
			pcall(utils.project_root_dir)
		end
	end,
})
