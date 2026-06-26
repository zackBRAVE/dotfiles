-- import nvim-tree plugin safely
local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
  return
end

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

-- configure nvim-tree
nvimtree.setup({
  renderer = {
    icons = {
      web_devicons = {
        file = {
          enable = true,
          color = true,
        },
      },
      glyphs = {
        folder = {
          arrow_closed = "",
          arrow_open = "",
        },
      },
    },
  },
  update_focused_file = {
    enable = true,
    update_root = false,
  },
  git = {
    enable = true,
    timeout = 400,
    ignore = false,
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false,
      },
    },
  },
})

-- Refresh git status when returning to Neovim from another app
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    if package.loaded["nvim-tree"] then
      pcall(require("nvim-tree.api").tree.reload)
    end
  end,
})


