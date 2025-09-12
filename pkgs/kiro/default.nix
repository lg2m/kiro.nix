# Kiro IDE Nix Package
#
# This package provides Kiro IDE for NixOS and other Nix-based systems.
# It uses explicit versioning following standard nixpkgs patterns.
#
# ============================================================================
# VERSION UPDATE INSTRUCTIONS
# ============================================================================
#
# To update Kiro to a new version, follow these steps:
#
# 1. FIND THE LATEST RELEASE INFORMATION
#    Check Kiro's metadata endpoint to get the latest release details:
#    
#    curl -s https://prod.download.desktop.kiro.dev/stable/metadata-linux-x64-stable.json | jq
#    
#    Look for the "releases" array and find the latest entry with:
#    - "packageVersion": The semantic version (e.g., "0.2.39")
#    - "url": The download URL for the Linux x64 tarball
#
# 2. UNDERSTAND THE URL PATTERN
#    Kiro release URLs follow this pattern:
#    https://prod.download.desktop.kiro.dev/releases/{TIMESTAMP}--distro-linux-x64-tar-gz/{TIMESTAMP}-distro-linux-x64.tar.gz
#    
#    Where {TIMESTAMP} is a build timestamp like "202509032213"
#    
#    Example:
#    https://prod.download.desktop.kiro.dev/releases/202509032213--distro-linux-x64-tar-gz/202509032213-distro-linux-x64.tar.gz
#
# 3. CALCULATE THE HASH
#    Use nix-prefetch-url to calculate the SHA256 hash for the new tarball:
#    
#    nix-prefetch-url https://prod.download.desktop.kiro.dev/releases/{TIMESTAMP}--distro-linux-x64-tar-gz/{TIMESTAMP}-distro-linux-x64.tar.gz
#    
#    This will download the file and output the hash in the format:
#    sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
#
# 4. UPDATE THE PACKAGE DEFINITION
#    Update the three values below:
#    - version: Set to the packageVersion from the metadata (e.g., "0.2.39")
#    - url: Set to the full download URL from step 2
#    - hash: Set to the hash calculated in step 3
#
# 5. TEST THE UPDATE
#    Build and test the package to ensure it works correctly:
#    
#    nix build .#kiro
#    ./result/bin/kiro --version  # Verify the version
#    
#    Also test with home-manager if applicable:
#    home-manager switch --flake .
#
# 6. VERIFY FUNCTIONALITY
#    Launch Kiro to ensure all features work:
#    - Desktop integration (application appears in launcher)
#    - Icon display
#    - All runtime dependencies are properly linked
#    - No missing library errors
#
# EXAMPLE UPDATE:
# If updating from 0.2.38 to 0.2.39 with timestamp 202509041500:
#
# OLD VALUES:
#   version = "0.2.38";
#   url = "https://prod.download.desktop.kiro.dev/releases/202509032213--distro-linux-x64-tar-gz/202509032213-distro-linux-x64.tar.gz";
#   hash = "sha256-nqOtD7Ef7dLYHzAM2jTybV/paUPjPYBJpa2AM0lnyIE=";
#
# NEW VALUES:
#   version = "0.2.39";
#   url = "https://prod.download.desktop.kiro.dev/releases/202509041500--distro-linux-x64-tar-gz/202509041500-distro-linux-x64.tar.gz";
#   hash = "sha256-[NEW_HASH_FROM_NIX_PREFETCH_URL]";
#
# TROUBLESHOOTING:
# - If nix-prefetch-url fails, check that the URL is accessible
# - If the build fails, verify the tarball contains the expected Kiro binary
# - If Kiro doesn't launch, check for missing runtime dependencies
# - If desktop integration fails, verify the icon and desktop entry installation
#
# ============================================================================

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook,


  # Graphics and display dependencies
  mesa,
  libdrm,
  wayland,
  libxkbcommon,
  libgbm,
  libglvnd,

  # X11 libraries
  xorg,

  # Desktop integration libraries
  gtk3,
  gdk-pixbuf,
  pango,
  cairo,
  atk,
  at-spi2-atk,
  at-spi2-core,

  # Audio dependencies
  alsa-lib,
  pipewire,
  libpulseaudio,

  # System libraries
  glib,
  nss,
  nspr,
  fontconfig,
  freetype,
  expat,
  zlib,
  openssl,
  libuuid,
  dbus,
  libnotify,
  libsecret,
  udev,
  libudev-zero,
  cups,


}:

stdenv.mkDerivation rec {
  pname = "kiro";
  version = "0.2.38";

  src = fetchurl {
    url = "https://prod.download.desktop.kiro.dev/releases/202509032213--distro-linux-x64-tar-gz/202509032213-distro-linux-x64.tar.gz";
    hash = "sha256-nqOtD7Ef7dLYHzAM2jTybV/paUPjPYBJpa2AM0lnyIE=";
  };

  # Build-time dependencies
  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook
  ];

  # Runtime dependencies - all libraries that Kiro needs
  buildInputs = [
    # Graphics and display
    mesa
    libdrm
    wayland
    libxkbcommon
    libgbm
    libglvnd

    # X11 libraries (comprehensive set from shell.nix)
    xorg.libX11
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXi
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXdamage
    xorg.libxcb
    xorg.libxshmfence
    xorg.libXxf86vm
    xorg.libXt
    xorg.libXmu
    xorg.libxkbfile

    # Desktop integration
    gtk3
    gdk-pixbuf
    pango
    cairo
    atk
    at-spi2-atk
    at-spi2-core

    # Audio
    alsa-lib
    pipewire
    libpulseaudio

    # System libraries
    glib
    nss
    nspr
    fontconfig
    freetype
    expat
    zlib
    openssl
    libuuid
    dbus
    libnotify
    libsecret
    udev
    libudev-zero
    cups
  ];

  # Don't strip binaries (can cause issues with Electron apps)
  dontStrip = true;

  # Don't run configure phase
  dontConfigure = true;

  # Don't run build phase (we're just extracting and installing)
  dontBuild = true;

  # Installation phase
  installPhase = ''
    runHook preInstall

    # Create output directories
    mkdir -p $out/bin
    mkdir -p $out/share/kiro
    mkdir -p $out/share/applications
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256,scalable}/apps

    # Extract and install Kiro binary and assets
    if [ ! -d "." ] || [ -z "$(ls -A .)" ]; then
      echo "ERROR: Tarball extraction failed or directory is empty"
      exit 1
    fi
    
    # Copy files to installation directory
    cp -r . $out/share/kiro/

    # Find and validate Kiro binary
    kiro_binary=""
    
    # Search in common locations
    for potential_path in \
      "$out/share/kiro/kiro" \
      "$out/share/kiro/bin/kiro" \
      "$out/share/kiro/Kiro" \
      "$out/share/kiro/kiro-ide" \
      $(find $out/share/kiro -name "kiro" -type f 2>/dev/null) \
      $(find $out/share/kiro -name "Kiro" -type f 2>/dev/null) \
      $(find $out/share/kiro -name "*kiro*" -type f -executable 2>/dev/null); do
      
      if [ -f "$potential_path" ] && [ -x "$potential_path" ]; then
        # Basic validation - check if it's an ELF binary
        if file "$potential_path" | grep -q "ELF.*executable"; then
          kiro_binary="$potential_path"
          break
        fi
      fi
    done
    
    # Handle binary not found
    if [ -z "$kiro_binary" ]; then
      echo "ERROR: Could not find Kiro binary in extracted tarball"
      echo "Expected binary names: kiro, Kiro, or kiro-ide"
      exit 1
    fi
    
    # Ensure binary is executable and set up symlink if needed
    chmod +x "$kiro_binary"
    
    # Create symlink to standard location if binary is not already there
    if [ "$kiro_binary" != "$out/share/kiro/kiro" ]; then
      ln -sf "$kiro_binary" "$out/share/kiro/kiro"
    fi

    # Create wrapper script with proper sandbox flags and environment
    makeWrapper $out/share/kiro/kiro $out/bin/kiro \
      --add-flags "--no-sandbox" \
      --set-default ELECTRON_IS_DEV 0 \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --prefix PATH : "${lib.makeBinPath [ ]}" \
      --set-default NIXOS_OZONE_WL "1"

    # Extract and install application icon
    icon_found=false
    main_icon_path=""
    
    # Look for icon files in common locations
    for icon_path in \
      "resources/app.asar.unpacked/assets/icon.png" \
      "resources/assets/icon.png" \
      "assets/icon.png" \
      "icon.png" \
      "resources/app.asar.unpacked/assets/kiro.png" \
      "resources/assets/kiro.png" \
      "assets/kiro.png" \
      "kiro.png" \
      "resources/app.asar.unpacked/assets/logo.png" \
      "resources/assets/logo.png" \
      "assets/logo.png" \
      "logo.png"; do
      
      if [ -f "$out/share/kiro/$icon_path" ]; then
        main_icon_path="$out/share/kiro/$icon_path"
        icon_found=true
        break
      fi
    done
    
    # Install icon or create fallback
    if [ "$icon_found" = true ] && [ -n "$main_icon_path" ]; then
      # Install to pixmaps for legacy compatibility
      cp "$main_icon_path" "$out/share/pixmaps/kiro.png"
      
      # Install to hicolor icon theme (standard location)
      for size in 16x16 32x32 48x48 64x64 128x128 256x256; do
        cp "$main_icon_path" "$out/share/icons/hicolor/$size/apps/kiro.png"
      done
    else
      # Create a simple SVG icon as fallback
      cat > $out/share/icons/hicolor/scalable/apps/kiro.svg << 'ICON_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" rx="8" fill="#2563eb"/>
  <text x="32" y="40" font-family="Arial, sans-serif" font-size="24" font-weight="bold" text-anchor="middle" fill="white">K</text>
</svg>
ICON_EOF
      
      # Also create a fallback in pixmaps
      cat > $out/share/pixmaps/kiro.svg << 'ICON_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <rect width="64" height="64" rx="8" fill="#2563eb"/>
  <text x="32" y="40" font-family="Arial, sans-serif" font-size="24" font-weight="bold" text-anchor="middle" fill="white">K</text>
</svg>
ICON_EOF
    fi

    # Install desktop entry file from external file
    cp ${./kiro.desktop} $out/share/applications/kiro.desktop
    # Update the Exec path to use the actual installation path
    substituteInPlace $out/share/applications/kiro.desktop --replace "Exec=kiro" "Exec=$out/bin/kiro"

    runHook postInstall
  '';

  # Package metadata for nixpkgs compatibility
  meta = with lib; {
    description = "AI-powered IDE and development assistant";
    longDescription = ''
      Kiro is an AI-powered integrated development environment (IDE) that provides
      intelligent code assistance, automated development workflows, and seamless
      integration with modern development tools.
      
      This package uses explicit versioning and requires manual updates to new versions.
      See the update instructions in the package definition for details on how to
      update to newer Kiro releases.
    '';
    homepage = "https://kiro.dev";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "kiro";

    # Additional metadata for package discovery
    categories = [
      "Development"
      "IDE"
    ];

    # Maintainer notes:
    # - This package requires manual version updates
    # - Follow the update instructions at the top of this file
    # - Test thoroughly after each update, especially desktop integration
    # - Verify all runtime dependencies are properly linked
    # - Check that the tarball structure matches expectations
  };
}
