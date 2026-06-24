local keymap = vim.keymap

-- command and undo
keymap.set("", "h", ":", { noremap = true })
keymap.set("", "U", "<C-r>", { noremap = true })

local has_comment_api, comment_api = pcall(require, "Comment.api")
keymap.set("", "Q", function()
	if #vim.api.nvim_list_wins() > 1 then
		local cur_buf = vim.api.nvim_get_current_buf()
		vim.cmd("bdelete! " .. cur_buf)

		local cur_name = vim.api.nvim_buf_get_name(0)
		if cur_name:match("NvimTree") then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local bname = vim.api.nvim_buf_get_name(buf)
				if not bname:match("NvimTree") and vim.bo[buf].buflisted then
					vim.api.nvim_set_current_win(win)
					break
				end
			end
		end
	else
		vim.cmd("q")
	end
end, { noremap = true, desc = "Close buffer or window" })
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

local builtin = require("telescope.builtin")

keymap.set("n", "<Tab>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-Tab>", "<Cmd>bprev<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>b", builtin.buffers, { desc = "Switch buffer" })
keymap.set("n", "<leader>p", builtin.find_files, { noremap = true, desc = "Find files" })
keymap.set("n", "g/", function()
	local flags = vim.fn.input("rg flags: ")
	if flags ~= "" then
		builtin.live_grep({ additional_args = function(args) return vim.split(flags, " ") end })
	else
		builtin.live_grep()
	end
end, { desc = "Search project contents" })
keymap.set("n", "<leader>R", "<Plug>RenamerStart", { desc = "Bulk rename files" })

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

-- search
keymap.set("", "-", "N", { noremap = true })
keymap.set("", "=", "n", { noremap = true })
keymap.set("", "m", "N", { noremap = true })

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

-- window management
keymap.set("", "<LEADER>sl", ":set nosplitbelow<CR>:split<CR>:set splitbelow<CR>", { noremap = true })
keymap.set("", "<LEADER>sk", ":set splitbelow<CR>:split<CR>", { noremap = true })
keymap.set("", "<LEADER>sj", ":set nosplitright<CR>:vsplit<CR>:set splitright<CR>", { noremap = true })
keymap.set("", "<LEADER>s;", ":set splitright<CR>:vsplit<CR>", { noremap = true })

keymap.set("", "<LEADER>w", "<C-w>w", { noremap = true })
keymap.set("", "<LEADER>l", "<C-w>k", { noremap = true })
keymap.set("", "<LEADER>k", "<C-w>j", { noremap = true })
keymap.set("", "<LEADER>j", "<C-w>h", { noremap = true })
keymap.set("", "<LEADER>;", "<C-w>l", { noremap = true })

keymap.set("", "<LEADER><up>", ":res +5<CR>", { noremap = true })
keymap.set("", "<LEADER><down>", ":res -5<CR>", { noremap = true })
keymap.set("", "<LEADER><left>", ":vertical -5<CR>", { noremap = true })
keymap.set("", "<LEADER><right>", ":vertical +5<CR>", { noremap = true })

keymap.set("", "<LEADER>sh", "<C-w>t<C-w>K", { noremap = true })
keymap.set("", "<LEADER>sv", "<C-w>t<C-w>H", { noremap = true })

keymap.set("", "<LEADER>q", "<C-w>j:q<CR>", { noremap = true })

-- move next character to the end of the line
keymap.set("i", "<C-;>", "<Esc>lx$p", { noremap = true })
keymap.set("", "\\s", ":%s//g<left><left>", { noremap = true })
