{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.kiro;
in
{
  meta.maintainers = [ ];

  options.programs.kiro = {
    enable = mkEnableOption "Kiro IDE";

    package = mkOption {
      type = types.package;
      default = pkgs.kiro;
      defaultText = literalExpression "pkgs.kiro";
      description = ''
        The Kiro package to install.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install the Kiro package with validation
    home.packages = [ cfg.package ];

    # Ensure XDG desktop integration is properly set up
    # The package already installs desktop entries and icons,
    # but we need to make sure home-manager processes them correctly
    xdg.enable = mkDefault true;
    
    # Enhanced desktop integration with comprehensive error handling
    home.activation.kiroDesktopIntegration = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "=== Kiro Home Manager Integration ==="
      echo "Configuring desktop integration for Kiro..."
      
      # Validate package installation
      if [ ! -f "$HOME/.nix-profile/bin/kiro" ] && [ ! -f "${cfg.package}/bin/kiro" ]; then
        echo "WARNING: Kiro binary not found in expected locations"
        echo "Expected locations:"
        echo "  - $HOME/.nix-profile/bin/kiro"
        echo "  - ${cfg.package}/bin/kiro"
        echo ""
        echo "This might indicate:"
        echo "  1. Package build failed"
        echo "  2. Installation is incomplete"
        echo "  3. Package path is incorrect"
        echo ""
        echo "Available binaries in profile:"
        ls -la $HOME/.nix-profile/bin/ | grep -i kiro || echo "  No kiro binaries found"
      else
        echo "Kiro binary found and accessible"
      fi
      
      # Update desktop database with error handling
      if command -v update-desktop-database >/dev/null 2>&1; then
        echo "Updating desktop database..."
        if ! $DRY_RUN_CMD ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.nix-profile/share/applications 2>/dev/null; then
          echo "WARNING: Failed to update desktop database"
          echo "This is usually not critical, but Kiro might not appear in application menus immediately"
          echo "You can try running this manually:"
          echo "  ${pkgs.desktop-file-utils}/bin/update-desktop-database $HOME/.nix-profile/share/applications"
        else
          echo "Desktop database updated successfully"
        fi
      else
        echo "WARNING: update-desktop-database not available"
        echo "Desktop integration might be limited"
      fi
      
      # Update icon cache with error handling
      if command -v gtk-update-icon-cache >/dev/null 2>&1; then
        echo "Updating icon cache..."
        if [ -d "$HOME/.nix-profile/share/icons/hicolor" ]; then
          if ! $DRY_RUN_CMD ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t $HOME/.nix-profile/share/icons/hicolor 2>/dev/null; then
            echo "WARNING: Failed to update icon cache"
            echo "This is usually not critical, but Kiro icon might not appear immediately"
            echo "You can try running this manually:"
            echo "  ${pkgs.gtk3}/bin/gtk-update-icon-cache -f -t $HOME/.nix-profile/share/icons/hicolor"
          else
            echo "Icon cache updated successfully"
          fi
        else
          echo "WARNING: Icon directory not found: $HOME/.nix-profile/share/icons/hicolor"
          echo "Kiro icons might not be properly installed"
        fi
      else
        echo "WARNING: gtk-update-icon-cache not available"
        echo "Icon integration might be limited"
      fi
      
      # Validate desktop entry installation
      desktop_entry="$HOME/.nix-profile/share/applications/kiro.desktop"
      if [ -f "$desktop_entry" ]; then
        echo "Desktop entry found: $desktop_entry"
        
        # Basic validation of desktop entry
        if grep -q "^Exec=" "$desktop_entry" && grep -q "^Name=" "$desktop_entry"; then
          echo "Desktop entry appears valid"
        else
          echo "WARNING: Desktop entry might be malformed"
          echo "Contents:"
          cat "$desktop_entry"
        fi
      else
        echo "WARNING: Desktop entry not found: $desktop_entry"
        echo "Kiro might not appear in application menus"
        echo ""
        echo "Available desktop entries:"
        ls -la $HOME/.nix-profile/share/applications/ | grep -i kiro || echo "  No kiro desktop entries found"
      fi
      
      # Final validation and troubleshooting info
      echo ""
      echo "=== Installation Summary ==="
      echo "Package: ${cfg.package}"
      echo "Binary available: $([ -f "$HOME/.nix-profile/bin/kiro" ] && echo "Yes" || echo "No")"
      echo "Desktop entry: $([ -f "$desktop_entry" ] && echo "Yes" || echo "No")"
      echo "XDG enabled: ${toString config.xdg.enable}"
      echo ""
      
      if [ -f "$HOME/.nix-profile/bin/kiro" ]; then
        echo "Kiro should now be available. You can:"
        echo "  1. Run 'kiro' from the command line"
        echo "  2. Find it in your application menu"
        echo "  3. Create a desktop shortcut if needed"
      else
        echo "Installation appears incomplete. Please check:"
        echo "  1. Package build logs for errors"
        echo "  2. Home manager configuration"
        echo "  3. Report this issue with the above diagnostic information"
      fi
      echo "=================================="
    '';
    
    # Add assertion to catch common configuration errors
    assertions = [
      {
        assertion = cfg.package != null;
        message = ''
          programs.kiro.package cannot be null.
          
          This usually indicates:
          1. The kiro package is not available in your nixpkgs
          2. There's an error in the package definition
          3. Missing package override parameters
          
          Try specifying the package explicitly:
          programs.kiro.package = pkgs.kiro.override { /* parameters */ };
        '';
      }
    ];
  };
}