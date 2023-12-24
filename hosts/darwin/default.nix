{ inputs, age, reykey, agenix, config, pkgs, home, ... }:

let user = "williamgoeller"; in

{
  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Setup user, packages, programs
  nix = {
    package = pkgs.nixUnstable;
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    emacs-unstable
    agenix.packages."${pkgs.system}".default
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  # Enable fonts dir
  fonts.fontDir.enable = true;

  launchd.user.agents.emacs.path = [ config.environment.systemPath ];
  launchd.user.agents.emacs.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/bin/wait4path ${pkgs.emacs}/bin/emacs && exec ${pkgs.emacs}/bin/emacs --fg-daemon"
    ];
    StandardErrorPath = "/tmp/emacs.err.log";
    StandardOutPath = "/tmp/emacs.out.log";
  };

  networking = {
    hostName = "wkg-mbp";
  };
  
  age.rekey = {
    hostPubkey = ./id_ed25519.pub;
    masterIdentities = [ "${inputs.self}/nix-secrets/identities/yubikey-1.txt" "${inputs.self}/nix-secrets/identities/yubikey-2.txt" ];
    extraEncryptionPubkeys = [ ];
  }; 

  

  age.secrets.id_ed25519_old = {
    rekeyFile = ./id_ed25519_old.age;
    path = "~/.ssh/id_ed25519_old";
  };



  # age.secrets = {
  #   id_ed25519_old = {
      
      # rekeyFile = ./id_ed25519_old.age;
      # file = config.age.secrets.secret1.path;
      # path = "/Users/${user}/.ssh/id_ed25519_old";
      # mode = "600";
  #   };
  # };
  
  # age.secrets.id_ed25519_old.rekeyFile = ./id_ed25519_old.age;

  
  # system = {
    # stateVersion = 4;

  #   defaults = {
  #     NSGlobalDomain = {
  #       AppleShowAllExtensions = true;
  #       ApplePressAndHoldEnabled = false;

  #       # 120, 90, 60, 30, 12, 6, 2
  #       KeyRepeat = 2;

  #       # 120, 94, 68, 35, 25, 15
  #       InitialKeyRepeat = 15;

  #       "com.apple.mouse.tapBehavior" = 1;
  #       "com.apple.sound.beep.volume" = 0.0;
  #       "com.apple.sound.beep.feedback" = 0;
  #     };

  #     # dock = {
  #     #   autohide = false;
  #     #   show-recents = false;
  #     #   launchanim = true;
  #     #   orientation = "bottom";
  #     #   tilesize = 48;
  #     # };

  #     finder = {
  #       _FXShowPosixPathInTitle = false;
  #     };

  #     trackpad = {
  #       Clicking = true;
  #       TrackpadThreeFingerDrag = true;
  #     };
  #   };

  #   keyboard = {
  #     enableKeyMapping = true;
  #     remapCapsLockToControl = true;
  #   };
  # };
}
