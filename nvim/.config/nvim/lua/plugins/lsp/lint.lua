-- import nvim-lint plugin safely
local setup, lint = pcall(require, "lint")
if not setup then
	return
end

local lsp_util = require("plugins.lsp.util")

local function pick_linter(bufnr)
	if lsp_util.is_ox_project(bufnr) then
		return nil
	end

	if vim.fn.executable("eslint_d") == 1 and lsp_util.is_eslint_project(bufnr) then
		return { "eslint_d" }
	end

	return nil
end

-- run linters on save
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		if not lsp_util.is_js_filetype(ft) then
			return
		end

		local linters = pick_linter(args.buf)
		if linters then
			require("lint").try_lint(linters)
		end
	end,
})
