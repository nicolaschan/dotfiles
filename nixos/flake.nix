{
  description = "Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    lix-module,
    ...
  } @ inputs: let
    inherit (self) outputs;
    pkgs-unstable = nixpkgs-unstable.legacyPackages.${"x86_64-linux"};
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      xps = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          inherit pkgs-unstable;
        };
        # > Our main nixos configuration file <
        modules = [
          lix-module.nixosModules.default
          ./xps/configuration.nix
        ];
      };
      monad = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          inherit pkgs-unstable;
        };
        # > Our main nixos configuration file <
        modules = [
          ./monad/configuration.nix
        ];
      };
    };
  };
}
