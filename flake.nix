{
  description = "Generate Nix expressions to build Composer packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
  let
      overlays = final: prev: {
        composer2nix = prev.callPackage ./default.nix { };
        composer2nix-noDev = prev.callPackage ./default.nix { noDev = true; };
      };
  in
  {
    overlays.default = overlays;
  } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system self;
          overlays = [ self.overlays.default ];
        };
      in with pkgs; rec {
        app = flake-utils.lib.mkApp {
          drv = composer2nix;
          exePath = "/bin/composer2nix";
        };
        app-noDev = flake-utils.lib.mkApp {
          drv = composer2nix-noDev;
          exePath = "/bin/composer2nix";
        };
        packages.composer2nix = composer2nix;
        packages.composer2nix-noDev = composer2nix-noDev;
        defaultPackage = composer2nix;
        apps.composer2nix = app;
        apps.composer2nix-noDev = app-noDev;
        defaultApp = app;
      });
}
