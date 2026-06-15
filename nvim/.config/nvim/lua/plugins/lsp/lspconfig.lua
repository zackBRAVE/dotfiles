-- lspconfig is now integrated into vim.lsp.config (Neovim 0.11+)
-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

local keymap = vim.keymap -- for conciseness
local ts_server = vim.fn.executable("tsgo") == 1 and "tsgo" or "ts_ls"

vim.diagnostic.config({
	severity_sort = true,
	float = {
		border = "rounded",
		source = "if_many",
	},
	virtual_text = {
		source = "if_many",
		spacing = 2,
	},
})

local function apply_code_action(kind, title_pattern)
	return function()
		vim.lsp.buf.code_action({
			apply = true,
			context = {
				only = { kind },
			},
			filter = title_pattern and function(action)
				return action.title:match(title_pattern) ~= nil
			end or nil,
		})
	end
end

local function goto_references()
	vim.lsp.buf.references(nil, { loclist = true })
end

local function next_diagnostic()
	vim.diagnostic.jump({ count = 1, float = true })
end

local function prev_diagnostic()
	vim.diagnostic.jump({ count = -1, float = true })
end

local function rename_current_file()
	local bufnr = vim.api.nvim_get_current_buf()
	local old_name = vim.api.nvim_buf_get_name(bufnr)
	if old_name == "" then
		vim.notify("Current buffer has no file name", vim.log.levels.WARN)
		return
	end

	if vim.bo[bufnr].modified then
		vim.cmd.write()
	end

	vim.ui.input({
		prompt = "New file path: ",
		default = old_name,
	}, function(input)
		if not input or input == "" or input == old_name then
			return
		end

		local new_name = vim.fn.fnamemodify(input, ":p")
		if vim.uv.fs_stat(new_name) then
			vim.notify("Target already exists: " .. new_name, vim.log.levels.ERROR)
			return
		end

		local parent = vim.fs.dirname(new_name)
		if parent and vim.fn.isdirectory(parent) == 0 then
			vim.fn.mkdir(parent, "p")
		end

		local params = {
			files = {
				{
					oldUri = vim.uri_from_fname(old_name),
					newUri = vim.uri_from_fname(new_name),
				},
			},
		}

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("workspace/willRenameFiles") then
				local response = client:request_sync("workspace/willRenameFiles", params, 2000, bufnr)
				if response and response.result then
					vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
				end
			end
		end

		local ok, err = pcall(vim.lsp.util.rename, old_name, new_name)
		if not ok then
			vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
			return
		end

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("workspace/didRenameFiles") then
				client:notify("workspace/didRenameFiles", params)
			end
		end

		vim.notify("Renamed to " .. new_name, vim.log.levels.INFO)
	end)
end

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	keymap.set("n", "gf", goto_references, opts)
	keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
	keymap.set("n", "[d", prev_diagnostic, opts)
	keymap.set("n", "]d", next_diagnostic, opts)
	keymap.set("n", "<leader>k", vim.lsp.buf.hover, opts)
	keymap.set("n", "<leader>i", vim.lsp.buf.document_symbol, opts)

	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	if client:supports_method("textDocument/documentColor") then
		vim.lsp.document_color.enable(true, { bufnr = bufnr })
	end

	if client.name == ts_server then
		keymap.set("n", "<leader>rf", rename_current_file, opts)
		keymap.set("n", "<leader>oi", apply_code_action("source.organizeImports.ts", "Organize Imports"), opts)
		keymap.set("n", "<leader>ru", apply_code_action("source.removeUnused.ts", "Remove Unused"), opts)
		keymap.set("n", "<leader>fa", apply_code_action("source.fixAll.ts", "Fix all"), opts)
	end

	if client.name == "oxlint" and vim.fn.exists(":LspOxlintFixAll") > 0 then
		keymap.set("n", "<leader>xf", ":LspOxlintFixAll<CR>", opts)
	end
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Configure LSP servers using vim.lsp.config (Neovim 0.11+)
vim.lsp.config("tsgo", {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		typescript = {
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = {
					enabled = "literals",
					suppressWhenArgumentMatchesName = true,
				},
				parameterTypes = { enabled = true },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = true },
			},
		},
	},
})

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		javascript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "literals",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
			},
		},
		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "literals",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
			},
		},
	},
})

vim.lsp.config("html", {
	capabilities = capabilities,
	on_attach = on_attach,
})

vim.lsp.config("cssls", {
	capabilities = capabilities,
	on_attach = on_attach,
})

vim.lsp.config("tailwindcss", {
	capabilities = capabilities,
	on_attach = on_attach,
})

vim.lsp.config("emmet_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})

vim.lsp.config("clangd", {})

-- Enable the language servers
vim.lsp.enable({ ts_server, "oxlint", "html", "cssls", "tailwindcss", "emmet_ls", "lua_ls", "clangd" })
if ts_server == "tsgo" then
	vim.lsp.enable("ts_ls", false)
end

-- grammarly-languageserver is archived upstream (znck/grammarly, May 2024) and
-- broken on Node 24+ (web-tree-sitter's fetch() can't parse local paths).
-- Explicitly disabled in case mason or another plugin tries to enable it.
vim.lsp.enable("grammarly_ls", false)
