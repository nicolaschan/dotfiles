{
  description = "Home Manager configuration of nicolas";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    insanity = {
      url = "github:nicolaschan/insanity";
    };
    zeditor = {
      url = "github:zed-industries/zed";
    };
  };

  outputs = { nixpkgs, home-manager, ghostty, insanity, zeditor, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations."nicolas" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = { inherit ghostty; inherit insanity; inherit zeditor; };
      };
    };
}
