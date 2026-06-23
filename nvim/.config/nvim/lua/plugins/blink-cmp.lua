local ok, cmp = pcall(require, "blink.cmp")
if not ok then
  return
end

-- Ensure Rust binary is built
cmp.build():pwait()

cmp.setup({
  keymap = {
    ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
    ["<C-n>"] = { "select_next", "fallback_to_mappings" },
    ["<C-b>"] = { "scroll_documentation_up", "fallback" },
    ["<C-f>"] = { "scroll_documentation_down", "fallback" },
    ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<Tab>"] = {
      function(cmp)
        if cmp.snippet_active() then return cmp.accept() end
        return cmp.select_and_accept()
      end,
      "snippet_forward",
      "fallback",
    },
    ["<CR>"] = { "accept", "fallback" },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = {
    documentation = { auto_show = false },
    menu = { draw = { columns = { { "label" }, { "kind_icon" }, { "source_name" } } } },
  },
  snippets = { preset = "luasnip" },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
