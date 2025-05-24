{
  description = "Nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
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
