{ config, pkgs, lib, home-manager, ... }:

let
  user = "williamgoeller";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
   ./homebrew.nix
   ./osx-defaults.nix
   ./secrets.nix
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      manual.manpages.enable = true;
    };
  };

  

  # Fully declarative dock using the latest from Nix Store
  local = { 
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Launchpad.app/"; }
        { path = "/Applications/Safari.app/"; }
        { path = "/System/Applications/Messages.app/"; }
        { path = "/System/Applications/Mail.app/"; }
        { path = "/System/Applications/Maps.app/"; }
        { path = "/System/Applications/Calendar.app/"; }
        { path = "/System/Applications/Notes.app/"; }
        { path = "/Applications/Slack.app/"; }
        # { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/System Settings.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "/Applications/AutoCAD 2023.app/"; }
        { path = "/Applications/Xcode.app/"; }
        { path = "/Applications/iTerm.app/"; }
        { path = "/Applications/Spotify.app/"; }
        {
          path = toString myEmacsLauncher;
          section = "others";
        }
        {
          path = "${config.users.users.${user}.home}/.local/share/";
          section = "others";
          options = "--sort name --view grid --display folder";
        }
        {
          path = "${config.users.users.${user}.home}/Downloads/";
          section = "others";
          options = "--sort dateadded --view grid --display folder";
        }
      ];
    };
  };
}
