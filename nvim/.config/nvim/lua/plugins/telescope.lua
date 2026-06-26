local ok, telescope = pcall(require, "telescope")
if not ok then
  return
end

telescope.setup({
  defaults = {
    find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
    file_ignore_patterns = { "node_modules", ".git/" },
    mappings = {
      i = {
        ["<C-l>"] = "move_selection_previous",
        ["<C-k>"] = "move_selection_next",
        ["<C-j>"] = "move_to_top",
        ["<C-;>"] = "move_to_bottom",
        ["<C-q>"] = "send_to_qflist",
      },
      n = {
        ["k"] = "move_selection_next",
        ["l"] = "move_selection_previous",
        ["j"] = { "<Nop>", type = "command" },
        [";"] = "select_default",
      },
    },
  },
  pickers = {
    buffers = {
      initial_mode = "normal",
    },
  },
})

telescope.load_extension("fzf")
