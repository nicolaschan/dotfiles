{
  description = "Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      pkgs-unstable = nixpkgs-unstable.legacyPackages.${"x86_64-linux"};
    in
    {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        xps = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            inherit pkgs-unstable;
          };
          modules = [
            ./modules/common.nix
            ./modules/gnome.nix
            ./modules/auto-upgrade.nix
            ./systems/xps/configuration.nix
          ];
        };
        monad = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            inherit pkgs-unstable;
          };
          modules = [
            ./modules/common.nix
            ./modules/nvidia.nix
            (import ./modules/ssh.nix {
              hostCertPub = builtins.readFile ./systems/monad/hostkey-cert.pub;
              caPub = builtins.readFile ./resources/ssh-ca.pub;
            })
            ./systems/monad/configuration.nix
          ];
        };
        kamino = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            inherit pkgs-unstable;
          };
          modules = [
            ./modules/common.nix
            ./modules/nvidia.nix
            ./modules/gnome.nix
            ./modules/openrgb.nix
            ./modules/auto-upgrade.nix
            (import ./modules/ssh.nix {
              hostCertPub = builtins.readFile ./systems/kamino/hostkey-cert.pub;
              caPub = builtins.readFile ./resources/ssh-ca.pub;
            })
            ./systems/kamino/configuration.nix
          ];
        };
      };
    };
}
