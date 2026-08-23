{
  description = "Home Manager configuration of nicolas";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    insanity.url = "github:nicolaschan/insanity";
    cx.url = "github:nicolaschan/cx";
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
    };
    paseo = {
      url = "github:getpaseo/paseo";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    insanity,
    cx,
    stylix,
    nixvim,
    ghostty,
    claude-code-nix,
    paseo,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    homeConfigurations."nicolas" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      # Specify your home configuration modules here, for example,
      # the path to your home.nix.
      modules = [
        stylix.homeModules.stylix
        nixvim.homeModules.nixvim
        ./modules/dynamic-wallpaper.nix
        ./home.nix
      ];

      # Optionally use extraSpecialArgs
      # to pass through arguments to home.nix
      extraSpecialArgs = {
        inherit insanity cx pkgs-unstable ghostty claude-code-nix paseo;
      };
    };
  };
}
