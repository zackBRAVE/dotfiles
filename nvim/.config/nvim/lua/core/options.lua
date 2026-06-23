local opt = vim.opt

-- line numbers
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = true

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

-- appearance
-- turn on termguicolors for nightfly colorscheme to work
opt.termguicolors = true

-- clipboard
opt.clipboard:append("unnamedplus")

-- word seperate
opt.iskeyword:append("-") -- consider string-string as whole word

-- misc
opt.timeout = false


