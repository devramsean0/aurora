{ config, pkgs, ... }:
{

  programs.nixvim = {
    enable = true;
    lsp.servers = {
      astro.enable = true;
      cmake.enable = true;
      html.enable = true;
      markdown_oxide.enable = true;
      tailwindcss.enable = true;
      rust_analyzer.enable = true;
      ruby_lsp.enable = true;
    };

    plugins = {
      cmp.enable = true;
      cmp-treesitter.enable = true;
      cmp-nvim-lsp.enable = true;
    };
  };
}
