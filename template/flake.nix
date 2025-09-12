{
  description = "Development environment with Kiro IDE";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kiro-nix.url = "github:lg2m/kiro.nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      kiro-nix,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          home-manager.nixosModules.home-manager
          {
            # System-wide packages
            environment.systemPackages = [
              kiro-nix.packages.x86_64-linux.kiro
            ];

            # Home Manager integration
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.myuser = {
              imports = [ kiro-nix.homeManagerModules.kiro ];
              programs.kiro.enable = true;
            };
          }
        ];
      };
    };
}
