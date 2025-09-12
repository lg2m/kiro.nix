{
  description = "Kiro IDE - AI-powered development environment packaged for Nix";

  # Flake inputs - dependencies for building and running Kiro
  inputs = {
    # Use nixos-unstable for latest packages and compatibility
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utilities for multi-system support
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Usage Examples:
  #
  # 1. Run Kiro directly:
  #    nix run github:lg2m/kiro.nix
  #
  # 2. Install via home-manager:
  #    Add to your home.nix or flake.nix:
  #    {
  #      inputs.kiro.url = "github:lg2m/kiro.nix";
  #      # ... in your home-manager configuration:
  #      imports = [ inputs.kiro.homeManagerModules.kiro ];
  #      programs.kiro.enable = true;
  #    }
  #
  # 3. Add to system packages:
  #    environment.systemPackages = [ inputs.kiro.packages.x86_64-linux.kiro ];
  #
  # 4. Use as overlay:
  #    nixpkgs.overlays = [ inputs.kiro.overlays.default ];
  #    # Then use pkgs.kiro in your configuration

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import our Kiro package
        kiro = pkgs.callPackage ./pkgs/kiro { };

      in
      {
        # Package outputs - Main Kiro IDE package
        packages = {
          # The main Kiro IDE package - automatically fetches latest release
          kiro = kiro;

          # Default package for 'nix build' and 'nix run'
          default = kiro;
        };

        # Development shell for testing and package development
        devShells.default = pkgs.mkShell {
          name = "kiro-nix-dev";

          buildInputs = with pkgs; [
            # Nix development tools
            nix-build-uncached
            nix-tree
            nixpkgs-fmt

            # For testing desktop integration
            desktop-file-utils
            shared-mime-info

            # For icon and graphics testing
            imagemagick

            # For debugging and inspection
            file
            binutils
          ];

          shellHook = ''
            echo "🚀 Kiro Nix Package Development Environment"
            echo ""
            echo "📦 Package Commands:"
            echo "  nix build .#kiro          - Build the Kiro package"
            echo "  nix run .#kiro            - Run Kiro directly from flake"
            echo "  nix develop               - Enter this development shell"
            echo ""
            echo "🔍 Testing Commands:"
            echo "  nix flake check           - Run all flake checks"
            echo "  desktop-file-validate     - Validate desktop entry files"
            echo ""
            echo "🏠 Home Manager Testing:"
            echo "  # Add to your home.nix:"
            echo "  programs.kiro.enable = true;"
            echo ""
            echo "📋 Current system: ${system}"
            echo "📁 Working directory: $(pwd)"
            echo ""
          '';
        };

        # Apps for easy running - enables 'nix run' functionality
        apps = {
          # Main Kiro application
          kiro = flake-utils.lib.mkApp {
            drv = kiro;
            name = "kiro";
          };

          # Default app for 'nix run'
          default = self.apps.${system}.kiro;
        };

        # Checks for CI/testing - run with 'nix flake check'
        checks = {
          # Verify the package builds successfully
          kiro-builds = kiro;

          # Validate desktop integration files
          desktop-integration =
            pkgs.runCommand "kiro-desktop-check"
              {
                buildInputs = [ pkgs.desktop-file-utils ];
              }
              ''
                # Extract desktop file from the built package
                desktop_file="${kiro}/share/applications/kiro.desktop"

                if [ -f "$desktop_file" ]; then
                  echo "✓ Desktop file exists: $desktop_file"
                  
                  # Validate desktop file format
                  desktop-file-validate "$desktop_file" || {
                    echo "✗ Desktop file validation failed"
                    exit 1
                  }
                  
                  echo "✓ Desktop file validation passed"
                else
                  echo "✗ Desktop file not found at expected location"
                  exit 1
                fi

                # Check for icon files
                icon_dir="${kiro}/share/pixmaps"
                if [ -d "$icon_dir" ] && [ -n "$(ls -A "$icon_dir")" ]; then
                  echo "✓ Icon files found in $icon_dir"
                else
                  echo "⚠ No icon files found in $icon_dir"
                fi

                echo "Desktop integration check completed successfully"
                touch $out
              '';

          # Verify home-manager module structure
          home-manager-module = pkgs.runCommand "kiro-hm-module-check" { } ''
            # Basic syntax check for the home-manager module
            module_file="${./modules/home-kiro.nix}"

            if [ -f "$module_file" ]; then
              echo "✓ Home Manager module exists: $module_file"
              
              # Check if the module has required structure
              if grep -q "programs.kiro" "$module_file"; then
                echo "✓ Module defines programs.kiro options"
              else
                echo "✗ Module missing programs.kiro options"
                exit 1
              fi
              
              if grep -q "mkEnableOption" "$module_file"; then
                echo "✓ Module uses proper option definitions"
              else
                echo "✗ Module missing proper option definitions"
                exit 1
              fi
              
            else
              echo "✗ Home Manager module not found"
              exit 1
            fi

            echo "Home Manager module check completed successfully"
            touch $out
          '';
        };
      }
    )
    // {
      # System-independent outputs

      # Home Manager module for declarative Kiro installation
      # Usage: imports = [ inputs.kiro.homeManagerModules.kiro ];
      #        programs.kiro.enable = true;
      homeManagerModules = {
        # Main home-manager module for Kiro IDE
        kiro = import ./modules/home-kiro.nix;

        # Default module (same as kiro)
        default = self.homeManagerModules.kiro;
      };

      # Overlay for integrating Kiro into existing nixpkgs
      # Usage: nixpkgs.overlays = [ inputs.kiro.overlays.default ];
      overlays = {
        default = final: prev: {
          # Add kiro package to the package set
          kiro = final.callPackage ./pkgs/kiro { };
        };
      };

      # Templates for easy project setup
      # Usage: nix flake init -t github:lg2m/kiro.nix
      templates = {
        default = {
          path = ./template;
          description = "Basic development environment with Kiro IDE";
          welcomeText = ''
            # Kiro IDE Development Environment

            You now have a basic flake setup with Kiro IDE support.

            ## Next steps:
            1. Run `nix develop` to enter the development shell
            2. Run `kiro` to launch Kiro IDE
            3. Or use `nix run` to run Kiro directly

            ## Home Manager Integration:
            Add to your home.nix:
            ```nix
            programs.kiro.enable = true;
            ```

            See README.md for more configuration options.
          '';
        };
      };
    };
}
