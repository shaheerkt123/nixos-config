{ lib, ... }:
let
  getNixFiles = dir:
    let
      entries = builtins.readDir dir;
      processEntry = name: type:
        let path = dir + "/${name}"; in
        if type == "directory" then getNixFiles path
        else if type == "regular" && lib.hasSuffix ".nix" name && path != ./default.nix then [ path ]
        else [ ];
    in
      lib.flatten (lib.mapAttrsToList processEntry entries);
in {
  imports = getNixFiles ./. ++ [
    ({ lib, ... }: {
      options.flake.homeModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
        default = {};
      };
      config = {
        systems = [ "x86_64-linux" "aarch64-linux" ];
      };
    })
  ];
}
