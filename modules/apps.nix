{ inputs, ... }: {
  flake.nixosModules.apps = { pkgs, config, lib, ... }: {
    # NixOS system-level apps can go here, none for now.
  };

  flake.homeModules.apps = { pkgs, config, lib, ... }: {
    home.packages = with pkgs; [
      inputs.kickstart-nix-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      (pkgs.symlinkJoin {
        name = "prismlauncher-cracked-wrapped";
        paths = [ inputs.prismlauncher-cracked.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/prismlauncher \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}
        '';
      })
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
      discord
      opencode
      pass
      keepassxc
      qbittorrent
      thunderbird
      seahorse
      tor-browser
      yazi
      lf
      fzf
    ];

    home.sessionVariables = {
      EDITOR = "nvim";
      DEFAULT_BROWSER = "zen";
      QT_QPA_PLATFORM = "wayland";
    };

    home.file = {
      ".gnupg/sshcontrol".text = ''
        134031545C93095D93D9484C9D957B1F6408C7C1
      '';
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
        "x-scheme-handler/vscode" = [ "code.desktop" ];
      };
    };
  };
}
