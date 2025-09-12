# Example flake configurations for using Kiro
# This file demonstrates various ways to consume the Kiro flake

{
  # Example 1: Basic flake.nix that includes Kiro
  basic-flake = ''
    {
      description = "Development environment with Kiro IDE";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        kiro-nix.url = "path:./path/to/kiro-nix-package";  # Update with actual path/URL
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      outputs = { self, nixpkgs, kiro-nix, home-manager }:
        let
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.''${system};
        in
        {
          # Make Kiro package available
          packages.''${system}.kiro = kiro-nix.packages.''${system}.kiro;
          packages.''${system}.default = kiro-nix.packages.''${system}.kiro;

          # Development shell with Kiro
          devShells.''${system}.default = pkgs.mkShell {
            buildInputs = [
              kiro-nix.packages.''${system}.kiro
              pkgs.git
              pkgs.nodejs
              pkgs.python3
            ];
            
            shellHook = '''
              echo "Development environment with Kiro IDE"
              echo "Run 'kiro' to start the IDE"
            ''';
          };

          # Home Manager configuration
          homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            modules = [
              kiro-nix.homeManagerModules.kiro
              {
                home.username = "user";
                home.homeDirectory = "/home/user";
                home.stateVersion = "25.05";
                
                programs.kiro.enable = true;
              }
            ];
          };
        };
    }
  '';

  # Example 2: NixOS system configuration with Kiro
  nixos-system = ''
    # In your NixOS configuration.nix or flake.nix
    {
      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        kiro-nix.url = "path:./kiro-nix-package";
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      outputs = { nixpkgs, kiro-nix, home-manager, ... }: {
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
  '';

  # Example 3: Standalone home-manager with flake
  standalone-home-manager = ''
    {
      description = "Home Manager configuration with Kiro";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
        kiro-nix.url = "path:./kiro-nix-package";
      };

      outputs = { nixpkgs, home-manager, kiro-nix, ... }: {
        homeConfigurations = {
          "user@hostname" = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              kiro-nix.homeManagerModules.kiro
              {
                home.username = "user";
                home.homeDirectory = "/home/user";
                home.stateVersion = "25.05";

                # Enable Kiro
                programs.kiro = {
                  enable = true;
                  # Uses the pinned version from the package definition
                };

                # Additional development tools
                home.packages = with nixpkgs.legacyPackages.x86_64-linux; [
                  git
                  nodejs
                  python3
                  rustc
                  cargo
                ];
              }
            ];
          };
        };
      };
    }
  '';

  # Example 4: Development team flake with Kiro
  team-development = ''
    {
      description = "Team development environment with Kiro IDE";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        kiro-nix.url = "github:your-org/kiro-nix-package";  # Your team's fork
        flake-utils.url = "github:numtide/flake-utils";
      };

      outputs = { self, nixpkgs, kiro-nix, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.''${system};
            kiro = kiro-nix.packages.''${system}.kiro;
          in
          {
            # Team development shell
            devShells.default = pkgs.mkShell {
              buildInputs = [
                kiro
                pkgs.git
                pkgs.nodejs_20
                pkgs.python311
                pkgs.rustc
                pkgs.cargo
                pkgs.docker
                pkgs.kubectl
              ];

              shellHook = '''
                echo "🚀 Team Development Environment"
                echo "Kiro IDE: $(kiro --version 2>/dev/null || echo 'available')"
                echo "Node.js: $(node --version)"
                echo "Python: $(python --version)"
                echo "Rust: $(rustc --version)"
                echo ""
                echo "Run 'kiro' to start the IDE"
                echo "Project documentation: ./docs/README.md"
              ''';
            };

            # CI/CD shell for automated testing
            devShells.ci = pkgs.mkShell {
              buildInputs = [
                kiro
                pkgs.git
                pkgs.nodejs_20
                pkgs.python311
                pkgs.rustc
                pkgs.cargo
              ];
            };

            # Package for distribution
            packages.default = kiro;
            packages.kiro = kiro;

            # Apps for easy running
            apps.kiro = flake-utils.lib.mkApp {
              drv = kiro;
              name = "kiro";
            };
          });
    }
  '';

  # Example 5: Using Kiro package in different contexts
  package-usage = ''
    {
      description = "Kiro package usage examples";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        kiro-nix.url = "path:./kiro-nix-package";
      };

      outputs = { nixpkgs, kiro-nix, ... }: {
        packages.x86_64-linux = {
          # Use the standard Kiro package (version pinned in package definition)
          kiro = kiro-nix.packages.x86_64-linux.kiro;
          
          # Make it the default package
          default = kiro-nix.packages.x86_64-linux.kiro;
        };
        
        # Development shell with Kiro
        devShells.x86_64-linux.default = let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in pkgs.mkShell {
          buildInputs = [
            kiro-nix.packages.x86_64-linux.kiro
            pkgs.git
            pkgs.nodejs
          ];
        };
      };
    }
  '';
}