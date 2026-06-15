local M = {}

local function gh(repo, opts)
	local spec = { src = "https://github.com/" .. repo }
	if opts then
		return vim.tbl_extend("force", spec, opts)
	end
	return spec
end

local legacy_packer_root = vim.fn.stdpath("data") .. "/site/pack/packer"
local legacy_packer_backup = legacy_packer_root .. ".disabled"

local function disable_legacy_packer_tree()
	if vim.fn.isdirectory(legacy_packer_root) == 0 then
		return
	end

	if vim.fn.isdirectory(legacy_packer_backup) == 1 then
		return
	end

	local ok, err = os.rename(legacy_packer_root, legacy_packer_backup)
	if not ok then
		vim.schedule(function()
			vim.notify(
				"Failed to disable legacy packer plugins: " .. tostring(err),
				vim.log.levels.WARN
			)
		end)
	end
end

local function register_pack_hooks()
	local group = vim.api.nvim_create_augroup("vim_pack_hooks", { clear = true })

	vim.api.nvim_create_autocmd("PackChanged", {
		group = group,
		callback = function(ev)
			local name = ev.data.spec.name
			local kind = ev.data.kind
			if kind ~= "install" and kind ~= "update" then
				return
			end

			if name == "telescope-fzf-native.nvim" then
				vim.system({ "make" }, { cwd = ev.data.path }):wait()
				return
			end

			if name == "nvim-treesitter" then
				if not ev.data.active then
					vim.cmd.packadd("nvim-treesitter")
				end
				pcall(vim.cmd, "TSUpdate")
			end
		end,
	})
end

local function add_plugins(specs)
	disable_legacy_packer_tree()
	register_pack_hooks()
	vim.pack.add(specs, {
		confirm = false,
		load = true,
	})
end

local function add_optional_plugins(specs)
	disable_legacy_packer_tree()
	register_pack_hooks()
	vim.pack.add(specs, {
		confirm = false,
		load = false,
	})
end

local function load_once(name, callback)
	local loaded = false

	return function()
		if not loaded then
			vim.cmd.packadd(name)
			if callback then
				callback()
			end
			loaded = true
		end
	end
end

M.load_telescope = load_once("telescope.nvim", function()
	require("plugins.telescope")
end)

function M.setup()
	add_plugins({
		gh("nvim-lua/plenary.nvim"),
		gh("rlue/vim-barbaric"),
		gh("bling/vim-bufferline"),
		gh("bpietravalle/vim-bolt"),
		gh("qpkorr/vim-renamer"),
		gh("szw/vim-maximizer"),
		gh("tpope/vim-surround"),
		gh("vim-scripts/ReplaceWithRegister"),
		gh("numToStr/Comment.nvim"),
		gh("kyazdani42/nvim-web-devicons"),
		gh("nvim-lualine/lualine.nvim"),
		gh("hrsh7th/nvim-cmp"),
		gh("hrsh7th/cmp-buffer"),
		gh("hrsh7th/cmp-path"),
		gh("L3MON4D3/LuaSnip"),
		gh("saadparwaiz1/cmp_luasnip"),
		gh("rafamadriz/friendly-snippets"),
		gh("williamboman/mason.nvim"),
		gh("williamboman/mason-lspconfig.nvim", { version = "main" }),
		gh("neovim/nvim-lspconfig"),
		gh("hrsh7th/cmp-nvim-lsp"),
		gh("onsails/lspkind.nvim"),
		gh("stevearc/conform.nvim"),
		gh("mfussenegger/nvim-lint"),
		gh("nvim-treesitter/nvim-treesitter", { version = "main" }),
		gh("windwp/nvim-autopairs"),
		gh("windwp/nvim-ts-autotag"),
		gh("lewis6991/gitsigns.nvim"),
		gh("folke/neodev.nvim"),
		gh("lambdalisue/suda.vim"),
		gh("f-person/auto-dark-mode.nvim"),
		gh("echasnovski/mini.nvim", { version = "stable" }),
	})

	add_optional_plugins({
		gh("jacoborus/tender.vim"),
		gh("ellisonleao/gruvbox.nvim"),
		gh("NLKNguyen/papercolor-theme"),
		gh("nvim-tree/nvim-tree.lua"),
		gh("nvim-telescope/telescope-fzf-native.nvim"),
		gh("nvim-telescope/telescope.nvim", { version = "v0.2.2" }),
	})
end

function M.setup_vscode()
	add_plugins({
		gh("rlue/vim-barbaric"),
	})
end

return M
