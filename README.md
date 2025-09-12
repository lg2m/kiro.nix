# Kiro IDE Nix Package

> [!WARNING]
> **Disclaimer:** This whole thing is mostly LLM-generated code (via Kiro after I duct-taped a Nix shell together to get an initial instance running). I'm still quite new to Nix/NixOS, so run it at your own risk.

A Nix package for [Kiro](https://kiro.dev), an AI-powered development environment.  
This package handles all system dependencies (probably more than necessary) and provides desktop integration for NixOS on x86_64-linux.

## Quick Start

### Using Nix Flakes (Recommended)

Add Kiro to your system packages:

```nix
# In your NixOS configuration or home-manager
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kiro-nix.url = "github:lg2m/kiro.nix";
  };

  outputs = { self, nixpkgs, kiro-nix }: {
    # System-wide installation (NixOS)
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            kiro-nix.packages.x86_64-linux.kiro
          ];
        }
      ];
    };

    # Or for home-manager
    homeConfigurations.lg2m = home-manager.lib.homeManagerConfiguration {
      modules = [
        kiro-nix.homeManagerModules.kiro
        {
          programs.kiro.enable = true;
        }
      ];
    };
  };
}
```

See the [Flake](./examples/flake-usage.nix) or [Home-Manager](./examples/home-manager.nix) examples for more details.

## Contributing

This might already be useless (and guarenteed to be later), but for now it's here. PRs welcome if you want to teach me a thing or two. Or fork it or whatever.

### Making Changes

#### Package Updates

To update Kiro to a new version, follow these steps:

1. **Check for New Releases**: Monitor Kiro's release information or check the metadata endpoint:
   ```bash
   curl https://prod.download.desktop.kiro.dev/stable/metadata-linux-x64-stable.json | jq
   ```

2. **Update Package Definition**: In `pkgs/kiro/default.nix`, update three values:
   - `version`: The semantic version (e.g., "0.2.39")
   - `url`: The full download URL following the pattern:
     ```
     https://prod.download.desktop.kiro.dev/releases/{timestamp}--distro-linux-x64-tar-gz/{timestamp}-distro-linux-x64.tar.gz
     ```
   - `hash`: Calculate using `nix-prefetch-url <new-url>`

3. **Example Update Process**:
   ```bash
   # Get the new URL from metadata
   NEW_URL="https://prod.download.desktop.kiro.dev/releases/202509040000--distro-linux-x64-tar-gz/202509040000-distro-linux-x64.tar.gz"
   
   # Calculate the hash
   nix-prefetch-url $NEW_URL
   
   # Update the three values in pkgs/kiro/default.nix
   ```

4. **Other Updates**: You may also need to update:
   - **Dependencies**: Update `buildInputs` in `pkgs/kiro/default.nix`
   - **Desktop Integration**: Update `pkgs/kiro/kiro.desktop` for new features

#### Submitting Changes

1. **Create Branch**
   ```bash
   git switch -c chore/update-kiro-to-0.2.39
   ```

2. **Make Changes** feature, updates, bug fixes, etc.

3. **Test Changes** ensure everything works as expected

4. **Update Documentation** if needed

5. **Submit Pull Request** with:
   - Clear description of changes
   - Any breaking changes noted

### Code Style Guidelines

- **Comments**: Document complex logic and dependencies
- **Commit Messages**: Use conventional commit format

### Release Process

1. **Version Updates**: Manual updates following the process above
1. **Package Updates**: Manual updates for dependencies or structure
1. **Documentation**: Update README and examples/template as needed

## License

This package definition is licensed under MIT License. Kiro IDE itself is proprietary software - please refer to [Kiro's official licensing](https://kiro.dev) for terms of use.

---

For more information about Kiro IDE, visit [kiro.dev](https://kiro.dev).
For Nix and NixOS documentation, visit [nixos.org](https://nixos.org).
