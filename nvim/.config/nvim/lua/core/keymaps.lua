-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap

-- command and undo
keymap.set("", "h", ":", { noremap = true })
keymap.set("", "U", "<C-r>", { noremap = true })

if not vim.g.vscode then
	local has_comment_api, comment_api = pcall(require, "Comment.api")
	local plugin_setup = require("plugins-setup")

	-- save and quit
	keymap.set("", "Q", ":q<CR>", { noremap = true })
	keymap.set("", "<C-q>", ":qa<CR>", { noremap = true })
	keymap.set("", "S", ":w<CR>", { noremap = true })
	keymap.set("", "S", ":w!<CR>", { noremap = true })
	keymap.set("", "<C-s>", ":w suda://%<CR>", { noremap = true })
	keymap.set("", "<C-q>", ":q!<CR>", { noremap = true })

	if has_comment_api then
		local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
		local toggle_visual_comment = function()
			vim.api.nvim_feedkeys(esc, "nx", false)
			comment_api.locked("toggle.linewise")(vim.fn.visualmode())
		end

		keymap.set("n", "<C-_>", comment_api.toggle.linewise.current, { desc = "Toggle comment", silent = true })
		keymap.set("x", "<C-_>", toggle_visual_comment, { desc = "Toggle comment", silent = true })
		keymap.set("n", "<leader>/", comment_api.toggle.linewise.current, { desc = "Toggle comment", silent = true })
		keymap.set("x", "<leader>/", toggle_visual_comment, { desc = "Toggle comment", silent = true })
	end

	vim.api.nvim_create_user_command("Telescope", function(opts)
		plugin_setup.load_telescope()
		pcall(vim.api.nvim_del_user_command, "Telescope")
		vim.cmd("Telescope " .. opts.args)
	end, { nargs = "*" })

	keymap.set("n", "<leader>p", "<cmd>Telescope find_files<CR>", { noremap = true, desc = "Telescope find files" })
	keymap.set("n", "<M-p>", "<cmd>Telescope<CR>", { noremap = true, desc = "Telescope" })

	local nvim_tree_loaded = false
	keymap.set("n", "<leader>e", function()
		if nvim_tree_loaded then
			vim.cmd("NvimTreeToggle")
		else
			vim.cmd.packadd("nvim-tree.lua")
			require("plugins.nvim-tree")
			nvim_tree_loaded = true
			vim.cmd("NvimTreeToggle")
		end
	end, { noremap = true, desc = "Toggle file explorer" })

	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
				vim.cmd.packadd("nvim-tree.lua")
				require("plugins.nvim-tree")
				vim.cmd("NvimTreeToggle")
			end
		end,
	})
end

-- search
keymap.set("", "-", "N", { noremap = true })
if vim.g.vscode then
	keymap.set("", "m", "N", { noremap = true })
else
	keymap.set("", "=", "n", { noremap = true })
	keymap.set("", "m", "N", { noremap = true })
end

keymap.set("", "<LEADER><CR>", ":nohlsearch<CR>", { noremap = true })

-- copy paste
keymap.set("n", "Y", "y$", { noremap = true })
keymap.set("v", "Y", '"+y', { noremap = true })

-- indentation
keymap.set("n", "<", "<<", { noremap = true })
keymap.set("n", ">", ">>", { noremap = true })

-- cursor movement
keymap.set("", "j", "h", { noremap = true, silent = true })
keymap.set("", "k", "j", { noremap = true, silent = true })
keymap.set("", "l", "k", { noremap = true, silent = true })
keymap.set("", ";", "l", { noremap = true, silent = true })

keymap.set("", "gl", "gk", { noremap = true, silent = true })
keymap.set("", "gk", "gj", { noremap = true, silent = true })

keymap.set("", "L", "5k", { noremap = true, silent = true })
keymap.set("", "K", "5j", { noremap = true, silent = true })
keymap.set("", "W", "5w", { noremap = true, silent = true })
keymap.set("", "B", "5b", { noremap = true, silent = true })
keymap.set("", "N", "0", { noremap = true, silent = true })
keymap.set("", "M", "$", { noremap = true, silent = true })

keymap.set("", "<LEADER>o", "o<Esc>l", { noremap = true })
keymap.set("", "<LEADER>O", "O<Esc>k", { noremap = true })

if not vim.g.vscode then
	-- window management
	-- split window
	keymap.set("", "<LEADER>sl", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", { noremap = true })
	keymap.set("", "<LEADER>sk", ":set splitbelow<CR>:split<CR>", { noremap = true })
	keymap.set("", "<LEADER>sj", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", { noremap = true })
	keymap.set("", "<LEADER>s;", ":set splitright<CR>:vsplit<CR>", { noremap = true })

	-- move cursor around windows
	keymap.set("", "<LEADER>w", "<C-w>w", { noremap = true })
	keymap.set("", "<LEADER>l", "<C-w>k", { noremap = true })
	keymap.set("", "<LEADER>k", "<C-w>j", { noremap = true })
	keymap.set("", "<LEADER>j", "<C-w>h", { noremap = true })
	keymap.set("", "<LEADER>;", "<C-w>l", { noremap = true })

	-- resize window
	keymap.set("", "<LEADER><up>", ":res +5<CR>", { noremap = true })
	keymap.set("", "<LEADER><down>", ":res -5<CR>", { noremap = true })
	keymap.set("", "<LEADER><left>", ":vertical -5<CR>", { noremap = true })
	keymap.set("", "<LEADER><right>", ":vertical +5<CR>", { noremap = true })

	-- move window position
	keymap.set("", "<LEADER>sh", "<C-w>t<C-w>K", { noremap = true })
	keymap.set("", "<LEADER>sv", "<C-w>t<C-w>H", { noremap = true })

	-- close window below
	keymap.set("", "<LEADER>q", "<C-w>j:q<CR>", { noremap = true })
end

-- move next character to the end of the line
keymap.set("i", "<C-;>", "<Esc>lx$p", { noremap = true })
keymap.set("", "\\s", ":%s//g<left><left>", { noremap = true })

-- keymap.set('', '', '', { noremap = true })
