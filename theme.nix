{ pkgs, ... }: {
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    image = ./wallpapers/Wind.png;
    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
    };
# Inside theme.nix
    targets = {
      gtk.enable = true;
      qt = {
        enable = true;
      };
    };

# hyprland.enable = true;
# waybar.enable = true;
  };
}
