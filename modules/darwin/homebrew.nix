{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf elem;
  caskPresent = cask: lib.any (x: x.name == cask) config.homebrew.casks;
  brewEnabled = config.homebrew.enable;
#   homePackages = config.home-manager.users.${config.users.primaryUser.username}.home.packages;
in

{
  environment.shellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;
  homebrew.onActivation.extraFlags = [ "--force" ];

  homebrew.taps = [
    "homebrew/cask"
    # "homebrew/cask-drivers"
    # "homebrew/cask-fonts"
    # "homebrew/cask-versions"
    # "homebrew/core"
    # "homebrew/services"

    # "adoptopenjdk/openjdk"
    # "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    "1Password for Safari" = 1569813296;
    # "Accelerate for Safari" = 1459809092;
    # DaisyDisk = 411643860;
    # "Dark Mode for Safari" = 1397180934;
    # Deliveries = 290986013;
    # Fantastical = 975937182;
    # Flighty = 1358823008;
    Keynote = 409183694;
    # "Notion Web Clipper" = 1559269364;
    Numbers = 409203825;
    Pages = 409201541;
    # Patterns = 429449079;
    # "Pixelmator Pro" = 1289583905;
    # "Save to Raindrop.io" = 1549370672;
    Slack = 803453959;
    # "Swift Playgrounds" = 1496833156;
    # "Tailscale" = 1475387142;
    "Things 3" = 904280696;
    # Vimari = 1480933944;
    # "WiFi Explorer" = 494803304;
    Xcode = 497799835;
    # "Yubico Authenticator" = 1497506650;
    Messenger = 1480068668;
    Bear = 1091189122;
    "2048 Game" = 871033113;
    ColorSlurp = 1287239339;
    Jira = 1475897096;
    Taurine = 960276676;
    Infuse = 1136220934;
    Honey = 1472777122;
    Compressor = 424390742;
    "Final Cut Pro" = 424389933;
    "Logic Pro" = 634148309;
    "Apple Configurator 2" = 1037126344;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "1password"
    "1password-cli"
    "4k-video-downloader"
    "adobe-creative-cloud"
    # "adoptopenjdk/openjdk/adoptopenjdk16"
    # "adoptopenjdk/openjdk/adoptopenjdk15"
    # "adoptopenjdk/openjdk/adoptopenjdk8"
    "android-platform-tools"
    # "android-sdk"
    "android-studio"
    "anki"
    "apparency"
    "arq"
    "autodesk-fusion360"
    "backblaze"
    "balenaetcher"
    "bambu-studio"
    "bartender"
    "battle-net"
    "betterzip"
    "carbon-copy-cloner"
    "chef-workstation"
    "clay"
    "cleanmymac"
    "dash"
    "datagrip"
    "discord"
    "eclipse-ide"
    "electricbinary"
    "element"
    "etrecheckpro"
    "eul"
    "fastrawviewer"
    "firefox"
    # "firefox-developer-edition"
    "gimp"
    # "git-annex-turtle"
    "google-chrome"
    "google-drive"
    "gpg-suite"
    "grammarly"
    "gtkwave"
    "hammerspoon"
    "hiddenbar"
    "inkscape"
    "intellij-idea"
    "iterm2"
    "kap"
    "keybase"
    "keycastr"
    "ledger-live"
    "loopback"
    "mactex"
    "microsoft-office"
    "mimestream"
    "minecraft"
    "multiviewer-for-f1"
    "notion"
    "nvidia-geforce-now"
    "obsbot-webcam"
    "openscad"
    "openwebstart"
    # "osxfuse"
    "parallels"
    "pdf-expert"
    "postman"
    "prusaslicer"
    "pycharm"
    "qlcolorcode"
    "qlimagesize"
    "qlmarkdown"
    "qlprettypatch"
    "qlstephen"
    "qlvideo"
    "qt-creator"
    "quicken"
    "quicklook-csv"
    "quicklook-json"
    "quicklook-pat"
    "quicklookase"
    "raindropio"
    "raycast"
    # "sequel-pro"
    "signal"
    "skype"
    "slack"
    "sloth"
    "sonos"
    "sourcetree"
    "spotify"
    "steam"
    "superhuman"
    "suspicious-package"
    "teamviewer"
    "the-unarchiver"
    "tor-browser"
    "trader-workstation"
    "transmission"
    "transmit"
    "vagrant"
    # "virtualbox"
    "visual-studio-code"
    "vlc"
    "vmware-fusion"
    "vnc-viewer"
    "webpquicklook"
    "whisky"
    "xquartz"
    "yubico-yubikey-manager"
    "zoom"
    # "microsoft-auto-update"
  ];

  # Configuration related to casks
#   home-manager.users.${config.users.primaryUser.username} =
#     mkIf (caskPresent "1password-cli" && config ? home-manager) {
#       programs.ssh.enable = true;
#       programs.ssh.extraConfig = ''
#         # Only set `IdentityAgent` not connected remotely via SSH.
#         # This allows using agent forwarding when connecting remotely.
#         Match host * exec "test -z $SSH_TTY"
#           IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
#       '';
#       home.shellAliases = {
#         cahix = mkIf (elem pkgs.cachix homePackages) "op plugin run -- cachix";
#         gh = mkIf (elem pkgs.gh homePackages) "op plugin run -- gh";
#         nixpkgs-review = mkIf (elem pkgs.nixpkgs-review homePackages) "op run -- nixpkgs-review";
#       };
#       home.sessionVariables = {
#         GITHUB_TOKEN = "op://Personal/GitHub Personal Access Token/credential";
#       };
#     };

  # For cli packages that aren't currently available for macOS in `nixpkgs`.Packages should be
  # installed in `../home/default.nix` whenever possible.
  homebrew.brews = [
    "swift-format"
    "swiftlint"
  ];
}