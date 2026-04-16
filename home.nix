{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.kickstart-nixvim.homeManagerModules.default
  ];

# Home Manager needs a bit of information about you and the paths it should
# manage.
  home.username = "shaheer";
  home.homeDirectory = "/home/shaheer";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell";
    };
    initContent = ''
      bindkey '^f' vi-forward-word
      '';
  };  # <-- this closing brace is missing

  programs.git = {
    enable = true;
    userName = "shaheer";
    userEmail = "shaheerkt1234@gmail.com";

    signing = {
      key = "C475BEB786DF2FC1";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgSign = true;
      gpg.format = "openpgp";
    };
  };


  programs.nixvim.enable = true;

  programs.gpg = {
    enable = true;
    homedir = "/home/shaheer/.gnupg"; # Matches your existing setup
  };

services.gpg-agent = {
  enable = true;
  pinentryPackage = pkgs.pinentry-qt;   # ← replaces pinentry.package
  defaultCacheTtl = 3600;
  maxCacheTtl = 86400;
  enableSshSupport = true;
};

# 2. Set environment variables so SSH knows to use KDE for the prompt
  home.sessionVariables = {
  };

programs.ssh = {
  enable = true;
  # Fix: Move addKeysToAgent inside a matchBlock
  matchBlocks = {
    "*" = {
      addKeysToAgent = "yes";
    };
  };
};

  services.ssh-agent.enable = true;

  home.packages = with pkgs; [
      thunderbird

# # It is sometimes useful to fine-tune packages, for example, by applying
# # overrides. You can do that directly here, just don't forget the
# # parentheses. Maybe you want to install Nerd Fonts with a limited number of
# # fonts?
# (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

# # You can also create simple shell scripts directly inside your
# # configuration. For example, this adds a command 'my-hello' to your
# # environment:
# (pkgs.writeShellScriptBin "my-hello" ''
#   echo "Hello, ${config.home.username}!"
# '')
  ];

# Home Manager is pretty good at managing dotfiles. The primary way to manage
# plain files is through 'home.file'.
  home.file = {
# # Building this configuration will create a copy of 'dotfiles/screenrc' in
# # the Nix store. Activating the configuration will then make '~/.screenrc' a
# # symlink to the Nix store copy.
# ".screenrc".source = dotfiles/screenrc;

# # You can also set the file content immediately.
# ".gradle/gradle.properties".text = ''
#   org.gradle.console=verbose
#   org.gradle.daemon.idletimeout=3600000
# '';
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
      "x-scheme-handler/discord" = [ "discord.desktop" ];
    };
  };

# Home Manager can also manage your environment variables through
# 'home.sessionVariables'. These will be explicitly sourced when using a
# shell provided by Home Manager. If you don't want to manage your shell
# through Home Manager then you have to manually source 'hm-session-vars.sh'
# located at either
#
#  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
#
# or
#
#  /etc/profiles/per-user/shaheer/etc/profile.d/hm-session-vars.sh
#
  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "zen";
    GOPATH = "$HOME/go";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];

# This value determines the Home Manager release that your configuration is
# compatible with. This helps avoid breakage when a new Home Manager release
# introduces backwards incompatible changes.
#
# You should not change this value, even if you update Home Manager. If you do
# want to update the value, then make sure to first check the Home Manager
# release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

# Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}
