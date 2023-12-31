{
  description = "Starter Configuration for MacOS and NixOS";
  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:KeenWill/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    }; 
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/KeenWill/nix-secrets.git";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, nixpkgs, nixos-generators, disko, agenix, agenix-rekey, secrets } @inputs:
    let
      user = "williamgoeller";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;


      devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
        default = with pkgs; mkShell {
          nativeBuildInputs = with pkgs; [ 
            bashInteractive 
            git 
            age 
            agenix-rekey.packages.${system}.agenix-rekey
          age-plugin-yubikey ];
          shellHook = with pkgs; ''
            export EDITOR=vim
          '';
        };
      };
      mkApp = scriptName: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
          #!/usr/bin/env bash
          PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
          echo "Running ${scriptName} for ${system}"
          exec ${self}/apps/${system}/${scriptName}
        '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
      };
    in
    {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nodes = self.nixosConfigurations ++ self.darwinConfigurations;
        # Example for colmena:
        # inherit ((colmena.lib.makeHive self.colmena).introspect (x: x)) nodes;
      };

      darwinConfigurations = let user = "williamgoeller"; in {
        macos = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs;
          modules = [
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            agenix.darwinModules.default
            agenix-rekey.darwinModules.default
            {
              nix-homebrew = {
                enable = true;
                user = "${user}";
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                };
                mutableTaps = false;
                autoMigrate = true;
              };
            }
            ./hosts/darwin
          ];
        };
      };

      nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          nixos-generators.nixosModules.all-formats
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/nixos/home-manager.nix;
            };
          }
          ./hosts/nixos
        ];
     });

      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [];
          };
        };

      # host-a = { name, nodes, pkgs, ... }: {
      #   boot.isContainer = true;
      #   time.timeZone = nodes.host-b.config.time.timeZone;
      # };
      wkg1 = {
        deployment = {
          targetHost = "100.122.17.47";
          # targetPort = 1234;
          targetUser = "williamgoeller";
          buildOnTarget = true;
        };
        # boot.isContainer = true;
        time.timeZone = "America/New_York";
      };
    };

    packages.x86_64-linux = {
      video-downloader = video-downloader;
    };

    packages.aarch64-linux = {

      video-downloader = video-downloader;

      vmware = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        modules = self.nixosConfigurations."aarch64-linux"._module;
        format = "vmware";
        
        # optional arguments:
        # explicit nixpkgs and lib:
        # pkgs = nixpkgs.legacyPackages.x86_64-linux;
        # lib = nixpkgs.legacyPackages.x86_64-linux.lib;
        # additional arguments to pass to modules:
        # specialArgs = { myExtraArg = "foobar"; };
        
        # you can also define your own custom formats
        # customFormats = { "myFormat" = <myFormatModule>; ... };
        # format = "myFormat";
      };
      vbox = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        modules = self.nixosConfigurations."aarch64-linux"._module;
        format = "virtualbox";
      };

      iso = nixos-generators.nixosGenerate {
        system = "aarch64-linux";
        # modules = self.nixosConfigurations."aarch64-linux"._module;
        specialArgs = inputs;
        # nixpkgs.localSystem ="aarch64-darwin"; 
        modules = [
          disko.nixosModules.disko
          agenix.nixosModules.default
          agenix-rekey.nixosModules.default
          nixos-generators.nixosModules.all-formats
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./modules/nixos/home-manager.nix;
            };
          }
          # { nixpkgs = import nixpkgs { localSystem = "aarch64-darwin"; crossSystem = "aarch64-linux"; }; }
          ({ pkgs, ... }: {
            # nixpkgs.localSystem = "aarch64-darwin";
            # nixpkgs.crossSystem = { config = "aarch64-linux"; };
            nixpkgs.localSystem = { config = "aarch64-darwin"; };
          })
          ./hosts/nixos
        ];
        format = "iso";
      };
    };
  };
}
