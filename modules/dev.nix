{ inputs, ... }: {
  flake.nixosModules.dev = { pkgs, config, lib, ... }: {
  };

  flake.homeModules.dev = { pkgs, config, lib, ... }: {

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "shaheer";
          email = "shaheerkt123@users.noreply.github.com";
        };
        init.defaultBranch = "main";
        commit.gpgSign = true;
        gpg.format = "openpgp";
      };
      signing = {
        key = "F1CE2C4445FCB25E";
        signByDefault = true;
      };
    };

    home.packages = with pkgs; [
      cargo
      rustc
      gcc
      gnumake
      go
      gopls
      python3
      yarn
      jdk25
    ];

    home.sessionVariables = {
      GOPATH = "$HOME/go";
    };

    home.sessionPath = [
      "${config.home.homeDirectory}/go/bin"
    ];

    home.file = {
      ".local/share/jdks/jdk21".source = pkgs.jdk21;
    };
  };
}
