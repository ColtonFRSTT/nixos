
{
  description = "NixOS with Catppuccin via flakes";

  inputs = {
    # Choose ONE:
    # Stable release channel:
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Bleeding edge:
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # Replace HOST with your machine’s hostname (run `hostname` to see it)
    nixosConfigurations.xps-nixos-colton = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        # Catppuccin NixOS module
        catppuccin.nixosModules.catppuccin

        # Home Manager as a NixOS module (recommended)
        home-manager.nixosModules.home-manager

        ({ ... }: {
          nixpkgs.config.allowUnfree = true;   # <— add this
        })

        # Per-user Home Manager config + Catppuccin HM module
        {
          home-manager.backupFileExtension = "hm-bak";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Replace USER with your username
          home-manager.users.colton = {
           # nixpkgs.config.allowUnfree = true;
            imports = [
              ./home.nix
              catppuccin.homeModules.catppuccin
            ];
          };
        }
      ];
    };
   
    devShells.${system}.sfml = pkgs.mkShell {
      nativeBuildInputs = [ pkgs.pkg-config ];
      buildInputs = [
        pkgs.gcc
        pkgs.sfml
        pkgs.libGL    # for -lGL
      ];
    };
  };
}
