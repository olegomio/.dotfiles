-- init.lua
-- Neovim Config with Lazy.nvim, LSP, and Keybindings

-- Lazy.nvim Setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins mit Lazy.nvim verwalten
require("lazy").setup({
    { "nvim-treesitter/nvim-treesitter",          build = ":TSUpdate" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },
    { "hrsh7th/nvim-cmp" },     -- Autocomplete
    { "hrsh7th/cmp-nvim-lsp" }, -- LSP-Autocomplete
    { "L3MON4D3/LuaSnip" },     -- Snippet Engine
    { "nvim-telescope/telescope.nvim",            dependencies = { "nvim-lua/plenary.nvim" } },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-lualine/lualine.nvim" }, -- Statusline
    { "nvim-tree/nvim-tree.lua" },   -- File Explorer
    { "akinsho/bufferline.nvim" },   -- Tabs
    { "folke/tokyonight.nvim" },     -- Farben
})

-- ========== Allgemeine Einstellungen ==========
vim.opt.number = true             -- Zeilennummern anzeigen
vim.opt.relativenumber = true     -- Relative Zeilennummern
vim.opt.tabstop = 4               -- Tabs auf 4 setzen
vim.opt.shiftwidth = 4            -- Indent auf 4 setzen
vim.opt.expandtab = true          -- Tabs in Spaces umwandeln
vim.opt.mouse = "a"               -- Maus aktivieren
vim.opt.clipboard = "unnamedplus" -- System-Clipboard nutzen
vim.opt.termguicolors = true      -- True Colors aktivieren
vim.cmd("colorscheme tokyonight")

-- ========== Keybindings ==========
vim.g.mapleader = " " -- Space als Leader Key
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
vim.keymap.set("n", "<leader>sf", "<cmd>Telescope find_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>sg", "<cmd>Telescope git_files<CR>", { silent = true })
vim.keymap.set("n", "<leader>g", ":Telescope live_grep<CR>", { silent = true })
vim.keymap.set("n", "<leader>b", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("n", "<leader>q", ":bd<CR>", { silent = true })
-- format code
vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
end, { silent = true, desc = "Format Code" })


-- ========== Mason (LSP-Manager) ==========
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "volar",        -- Vue
        "ts_ls",        -- TypeScript (Ersetzt `tsserver`)
        "cssls",        -- CSS
        "jsonls",       -- JSON
        "yamlls",       -- YAML
        "eslint",       -- ESLint
        "intelephense", -- PHP für Laravel
        "lua_ls",       -- Lua
        "pyright"       -- Python
    }
})

-- ========== LSP-Config ==========
local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({})
lspconfig.pyright.setup({})
lspconfig.intelephense.setup({})
lspconfig.volar.setup({})
lspconfig.ts_ls.setup({}) -- Ersetzt tsserver!
lspconfig.cssls.setup({})
lspconfig.jsonls.setup({})
lspconfig.yamlls.setup({})
lspconfig.eslint.setup({})

-- ========== Autocomplete (nvim-cmp) ==========
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

-- ========== Statusline ==========
require("lualine").setup({ options = { theme = "tokyonight" } })

-- ========== File Explorer ==========
require("nvim-tree").setup({
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = true,
      },
    },
  },
})
-- require'nvim-web-devicons'.setup()
-- ========== Treesitter ==========
require("nvim-treesitter.configs").setup({
    ensure_installed = { "lua", "python", "javascript", "html", "css" },
    highlight = { enable = true },
})

-- ========== Telescope ==========
require("telescope").setup({
    defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
    },
    extensions = {
        fzf = {
            fuzzy = true, -- Fuzzy Searching
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

require("telescope").load_extension("fzf")
