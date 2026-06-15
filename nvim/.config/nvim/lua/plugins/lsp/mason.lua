-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- enable mason
mason.setup({
	providers = {
		"mason.providers.client",
		"mason.providers.registry-api",
	},
})

mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		"ast_grep",
		"tsgo",
		"oxlint",
		"oxfmt",
		"html",
		"cssls",
		"tailwindcss",
		"lua_ls",
		"emmet_ls",
	},
	automatic_enable = false,
})
