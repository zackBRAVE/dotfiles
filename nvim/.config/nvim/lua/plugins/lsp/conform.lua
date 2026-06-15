-- import conform plugin safely
local setup, conform = pcall(require, "conform")
if not setup then
	return
end

local lsp_util = require("plugins.lsp.util")

-- configure conform
local function first_available(bufnr, ...)
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then
			return formatter
		end
	end

	return select(1, ...)
end

local function prefer_oxfmt(bufnr)
	if not lsp_util.is_ox_project(bufnr) then
		return "prettier"
	end

	return first_available(bufnr, "oxfmt", "prettier")
end

conform.setup({
	-- setup formatters
	formatters_by_ft = {
		json = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		lua = { "stylua" },
		javascript = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		javascriptreact = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		typescript = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		typescriptreact = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		css = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		html = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
		markdown = function(bufnr)
			return { prefer_oxfmt(bufnr) }
		end,
	},
	-- format on save
	format_on_save = function(bufnr)
		-- disable format on save for some filetypes
		local ignored_filetypes = {
			"python",
		}
		if vim.tbl_contains(ignored_filetypes, vim.bo[bufnr].filetype) then
			return
		end

		return {
			timeout_ms = 5000,
			lsp_format = "fallback",
		}
	end,
})
