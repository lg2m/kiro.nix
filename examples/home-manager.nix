# Example home-manager configuration for Kiro IDE
# This demonstrates how to use the Kiro home-manager module

{ config, pkgs, ... }:

{
  # Import the Kiro home-manager module
  imports = [
    ../modules/home-kiro.nix
  ];

  # Basic Kiro configuration
  programs.kiro = {
    enable = true;
    # Use default package (uses pinned version for reproducible builds)
    # package = pkgs.kiro; # This is the default
  };

  # Example 2: Use with custom nixpkgs overlay
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     kiro = prev.callPackage ../pkgs/kiro { };
  #   })
  # ];
  # programs.kiro.enable = true;

  # Ensure XDG integration is enabled (recommended)
  xdg.enable = true;

  # Optional: Additional desktop integration
  xdg.mimeApps = {
    enable = true;
    # You can add MIME type associations here if Kiro supports specific file types
    # defaultApplications = {
    #   "text/plain" = "kiro.desktop";
    # };
  };

  # Optional: Shell integration
  programs.bash = {
    enable = true;
    shellAliases = {
      # Create convenient aliases
      kiro-dev = "kiro --no-sandbox";
      k = "kiro";
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      kiro-dev = "kiro --no-sandbox";
      k = "kiro";
    };
  };

  # Optional: Development environment integration
  home.sessionVariables = {
    # Set default editor to Kiro for git and other tools
    # EDITOR = "kiro --wait";
    # VISUAL = "kiro --wait";
  };

  # Optional: Desktop environment specific configurations
  
  # For GNOME users:
  # dconf.settings = {
  #   "org/gnome/desktop/applications/terminal" = {
  #     exec = "kiro";
  #   };
  # };

  # For KDE users:
  # programs.plasma = {
  #   enable = true;
  #   # Add Kiro-specific KDE configurations here
  # };

  # Example of a complete development setup with Kiro
  home.packages = with pkgs; [
    # Development tools that work well with Kiro
    git
    nodejs
    python3
    rustc
    cargo
    go
    
    # Additional tools for enhanced development experience
    ripgrep  # Fast text search
    fd       # Fast file finder
    bat      # Better cat with syntax highlighting
    exa      # Better ls
    
    # Language servers for better IDE experience
    nodePackages.typescript-language-server
    nodePackages.pyright
    rust-analyzer
    gopls
    
    # Recommended fonts for development
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    fira-code
    jetbrains-mono
  ];

  # Git configuration that works well with Kiro
  programs.git = {
    enable = true;
    # Configure git to use Kiro as editor (uncomment if desired)
    # extraConfig = {
    #   core.editor = "kiro --wait";
    #   merge.tool = "kiro";
    #   mergetool.kiro.cmd = "kiro --wait $MERGED";
    # };
  };

  # Optional: Systemd user services for Kiro-related automation
  # systemd.user.services.kiro-backup = {
  #   Unit = {
  #     Description = "Backup Kiro settings";
  #     After = [ "graphical-session.target" ];
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.rsync}/bin/rsync -av ~/.config/kiro/ ~/backups/kiro/";
  #   };
  #   Install = {
  #     WantedBy = [ "default.target" ];
  #   };
  # };

  # Optional: Fonts that work well with development
  fonts.fontconfig.enable = true;
}