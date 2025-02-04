-- init.lua
-- Neovim Config with Lazy.nvim, LSP, and Keybindings

-- Install Lazy.nvim (Plugin Manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "neovim/nvim-lspconfig" },
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-lualine/lualine.nvim" },
    { "nvim-tree/nvim-tree.lua" },
    { "akinsho/bufferline.nvim" },
    { "folke/tokyonight.nvim" },
})

-- General Settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.tabstop = 4           -- Set tab width to 4 spaces
vim.opt.shiftwidth = 4        -- Indent width
vim.opt.expandtab = true      -- Convert tabs to spaces
vim.opt.mouse = "a"           -- Enable mouse
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.termguicolors = true  -- Enable true colors
vim.cmd("colorscheme tokyonight")

-- Keybindings
vim.g.mapleader = " "  -- Space as leader key
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<leader>b", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":bd<CR>", { silent = true })

-- LSP Config
local lspconfig = require("lspconfig")
lspconfig.tsserver.setup({})
lspconfig.pyright.setup({})
lspconfig.lua_ls.setup({})

-- Autocomplete
local cmp = require("cmp")
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
    }),
})

-- Statusline
require("lualine").setup({ options = { theme = "tokyonight" } })

-- File Explorer
require("nvim-tree").setup()

-- Treesitter
require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "javascript", "html", "css" },
    highlight = { enable = true },
})

