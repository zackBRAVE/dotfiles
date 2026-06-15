local M = {}

M.js_filetypes = {
	"javascript",
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

M.eslint_roots = {
	"eslint.config.js",
	"eslint.config.cjs",
	"eslint.config.mjs",
	"eslint.config.ts",
	".eslintrc",
	".eslintrc.js",
	".eslintrc.cjs",
	".eslintrc.json",
	".eslintrc.yaml",
	".eslintrc.yml",
}

M.ox_roots = {
	".oxlintrc.json",
	".oxlintrc.jsonc",
	"oxlint.config.ts",
}

local function buf_dir(bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end

	return vim.fs.dirname(path)
end

function M.has_marker(bufnr, markers)
	local path = buf_dir(bufnr)
	if not path then
		return false
	end

	return vim.fs.find(markers, {
		path = path,
		upward = true,
	})[1] ~= nil
end

function M.is_js_filetype(ft)
	return vim.tbl_contains(M.js_filetypes, ft)
end

function M.is_ox_project(bufnr)
	return M.has_marker(bufnr, M.ox_roots)
end

function M.is_eslint_project(bufnr)
	return M.has_marker(bufnr, M.eslint_roots)
end

return M
