
{ config, pkgs, lib, ... }:

{
  home.username = "colton";
  home.homeDirectory = "/home/colton";
  home.stateVersion = "25.05";

  home.packages = [
    pkgs.xfce.thunar
    pkgs.xfce.thunar-archive-plugin
    pkgs.xfce.thunar-volman
    pkgs.gvfs
    pkgs.gcc
    pkgs.pkg-config
    pkgs.sfml
    pkgs.nodejs_24
    pkgs.awscli2
  ];

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # Enable the apps so HM writes their configs
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty/kitty.conf;
  };
  programs.chromium.enable = false;
  
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
  };
  programs.vscode.userSettings = {
    # Kill ALL inline ghost text engines
    "editor.inlineSuggest.enabled" = false;

    # Stop the faint inline preview from IntelliSense suggestions
    "editor.suggest.preview" = false;

    # Copilot: disable *completions* only (keep Chat)
    "github.copilot.inlineSuggest.enable" = false;
    "github.copilot.editor.enableAutoCompletions" = false;

    # (Optional) leave this OUT if you want Copilot Chat usable
    # "github.copilot.enable" = { "*": false; };

    "workbench.startupEditor" = "none";
    "workbench.activityBar.location" = "hidden";
    "workbench.layoutControl.enabled" = false;
    "workbench.editor.showTabs" = "single";
    "workbench.editor.tabActionLocation" = "hidden";

    "editor.minimap.enabled" = false;
    "editor.scrollbar.vertical" = "hidden";
    "editor.scrollbar.horizontal" = "hidden";
    "editor.lineNumbers" = "relative";

    "breadcrumbs.enabled" = false;
    "editor.glyphMargin" = false;

    "telemetry.telemetryLevel" = "off";
    "extensions.ignoreRecommendations" = true;

    "window.titleBarStyle" = "custom";
    "window.menuBarVisibility" = "hidden";
    "window.commandCenter" = false;
  };


  xdg.configFile."waybar/style.css" = lib.mkForce {
    source = ./waybar/extras.css;  # your file in repo
    force = true;                  # overwrite HM’s read-only symlink
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # File explorer
      nvim-tree-lua
      nvim-web-devicons

      # Git
      gitsigns-nvim
      vim-fugitive

      # Fuzzy finder
      telescope-nvim
      plenary-nvim

      # Statusline
      lualine-nvim

      # LSP + completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp_luasnip
      luasnip
      friendly-snippets

      # Treesitter
      nvim-treesitter

      # QoL
      which-key-nvim
    ];

    extraLuaConfig = ''
      vim.g.mapleader = ","

      -- which-key
      require("which-key").setup({})

      -- nvim-tree
      require("nvim-tree").setup({})
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Explorer" })

      -- telescope
      local telescope = require("telescope")
      telescope.setup({})
      local tb = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", tb.live_grep,  { desc = "Grep" })
      vim.keymap.set("n", "<leader>fb", tb.buffers,    { desc = "Buffers" })

      -- lualine
      require("lualine").setup({ options = { theme = "auto" } })

      -- gitsigns
      require("gitsigns").setup({})
      vim.keymap.set("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { silent = true, desc = "Git preview hunk" })
      vim.keymap.set("n", "<leader>gr", ":Gitsigns reset_hunk<CR>",   { silent = true, desc = "Git reset hunk" })
      vim.keymap.set("n", "<leader>gb", ":G blame<CR>",               { silent = true, desc = "Git blame (fugitive)" })

      -- treesitter
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- completion (cmp)
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        },
      })

      -- LSP (basic)
      local lsp = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(_, bufnr)
        local map = function(m, lhs, rhs, desc)
          vim.keymap.set(m, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "K",  vim.lsp.buf.hover,      "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      end

      -- Enable servers you have installed on your system (examples):
      -- lsp.lua_ls.setup({ capabilities = caps, on_attach = on_attach })
      -- lsp.tsserver.setup({ capabilities = caps, on_attach = on_attach })
      -- lsp.pyright.setup({ capabilities = caps, on_attach = on_attach })

      -- nice defaults
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.termguicolors = true

      -- optional: transparent background
      vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
      vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
      vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
    '';
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        spacing = 10;
        layer = "top";
        position = "top";
        height = 32;
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "network" "pulseaudio" "battery" "tray" ];

        # Example clock formatting
        "clock" = {
          format = "{:%H:%M}";
          tooltip = true;
          tooltip-format = "{:%A %d %B %Y}";
        };

        "cpu" = { format = "{usage}%"; };
        "memory" = { format = "{} MB"; };
        "network" = { format-wifi = "  {essid}"; format-ethernet = ""; };
        "pulseaudio" = { format = "{volume}%"; };
      };
    };
    style = lib.mkForce "";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hypr/hyprland.conf;
  };

  services.swww.enable = true;

  # needed for GUI mounting
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome authentication agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  # Catppuccin core + per-app integrations
  catppuccin = {
    enable = true;
    flavor = "mocha";   # latte | frappe | macchiato | mocha
    accent = "mauve";   # e.g., blue | pink | mauve | teal

    kitty.enable = true;
    waybar.enable = false;
    hyprland.enable = true;
  };

  xdg.configFile."VSCodium/User/settings.json" = {
    source = ./vscodium/settings.json;
  };
}
