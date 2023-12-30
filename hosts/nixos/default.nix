{ lib, specialArgs, config, inputs, pkgs, agenix, ... }:

let user = "williamgoeller";
    keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFVrWZkf6wERr0iwo4/LB2If1etVtlJRS6J3+yXdNM/a william@williamgoeller.com" ]; in
{
  imports = [
    ../../modules/nixos/secrets.nix
    ../../modules/nixos/disk-config.nix
    ../../modules/shared
    ../../modules/shared/cachix

  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      # systemd-boot = {
      #   enable = true;
      #   configurationLimit = 42;
      # };
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
      # efi.canTouchEfiVariables = true;
    };
    initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "megaraid_sas" "nvme" "sd_mod" ];
    initrd.kernelModules = [ "dm-snapshot" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    zfs.extraPools = [ "tank" ];
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  fileSystems."/tank" =
    { device = "tank";
      fsType = "zfs";
    };

  fileSystems."/export/tank" = {
    device = "/tank";
    options = [ "bind" ];
  };

  services.nfs.server.exports = ''
    # /export         192.168.1.10(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)
    /export/tank    100.0.0.0/8(rw,sync,no_subtree_check,insecure)
  '';


  # services.zfs.enable = true;
  services.zfs.autoScrub.enable = true;
  services.nfs.server.enable = true;


  services.tailscale.enable = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    hostName = "wkg1"; # Define your hostname.
    hostId = "0005f5a5";
    useDHCP = true;

    # interfaces."%INTERFACE%".useDHCP = true;
  };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    zsh.enable = true;
  };

  age.rekey = {
    hostPubkey = ./id_ed25519.pub;
    masterIdentities = [ "${specialArgs.self}/nix-secrets/identities/yubikey-1.age" "${specialArgs.self}/nix-secrets/identities/yubikey-2.age" ];
    extraEncryptionPubkeys = [ ];
  }; 

  services = {
    xserver = {
      enable = true;

      # Uncomment these for AMD or Nvidia GPU
      # boot.initrd.kernelModules = [ "amdgpu" ];
      # services.xserver.videoDrivers = [ "amdgpu" ];
      # services.xserver.videoDrivers = [ "nvidia" ];

      # Comment this for AMD GPU
      # This helps fix tearing of windows for Nvidia cards
      # services.xserver.screenSection = ''
      #   Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      #   Option       "AllowIndirectGLXProtocol" "off"
      #   Option       "TripleBuffer" "on"
      # '';

      # LightDM Display Manager
      displayManager.defaultSession = "none+bspwm";
      displayManager.lightdm = {
        enable = true;
        greeters.slick.enable = true;
        background = ../../modules/nixos/config/login-wallpaper.png;
      };

      # Tiling window manager
      windowManager.bspwm = {
        enable = true;
      };

      # Turn Caps Lock into Ctrl
      layout = "us";
      xkbOptions = "ctrl:nocaps";

      # Better support for general peripherals
      libinput.enable = true;
    };

    # Let's be able to SSH into this machine
    openssh.enable = true;

    # Sync state between machines
    # Sync state between machines
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      dataDir = "/home/${user}/.local/share/syncthing";
      configDir = "/home/${user}/.config/syncthing";
      user = "${user}";
      group = "users";
      guiAddress = "127.0.0.1:8384";
      overrideFolders = true;
      overrideDevices = true;

      settings = {
        devices = {};
        options.globalAnnounceEnabled = false; # Only sync on LAN
      };
    };

    # Picom, my window compositor with fancy effects
    #
    # Notes on writing exclude rules:
    #
    #   class_g looks up index 1 in WM_CLASS value for an application
    #   class_i looks up index 0
    #
    #   To find the value for a specific application, use `xprop` at the
    #   terminal and then click on a window of the application in question
    #
    picom = {
      enable = true;
      settings = {
        animations = true;
        animation-stiffness = 300.0;
        animation-dampening = 35.0;
        animation-clamping = false;
        animation-mass = 1;
        animation-for-workspace-switch-in = "auto";
        animation-for-workspace-switch-out = "auto";
        animation-for-open-window = "slide-down";
        animation-for-menu-window = "none";
        animation-for-transient-window = "slide-down";
        corner-radius = 12;
        rounded-corners-exclude = [
          "class_i = 'polybar'"
          "class_g = 'i3lock'"
        ];
        round-borders = 3;
        round-borders-exclude = [];
        round-borders-rule = [];
        shadow = true;
        shadow-radius = 8;
        shadow-opacity = 0.4;
        shadow-offset-x = -8;
        shadow-offset-y = -8;
        fading = false;
        inactive-opacity = 0.8;
        frame-opacity = 0.7;
        inactive-opacity-override = false;
        active-opacity = 1.0;
        focus-exclude = [
        ];

        opacity-rule = [
          "100:class_g = 'i3lock'"
          "60:class_g = 'Dunst'"
          "100:class_g = 'Alacritty' && focused"
          "90:class_g = 'Alacritty' && !focused"
        ];

        blur-kern = "3x3box";
        blur = {
          method = "kernel";
          strength = 8;
          background = false;
          background-frame = false;
          background-fixed = false;
          kern = "3x3box";
        };

        shadow-exclude = [
          "class_g = 'Dunst'"
        ];

        blur-background-exclude = [
          "class_g = 'Dunst'"
        ];

        backend = "glx";
        vsync = false;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
        detect-rounded-corners = true;
        detect-client-opacity = false;
        detect-transient = true;
        detect-client-leader = true;
        use-damage = true;
        log-level = "info";

        wintypes = {
          normal = { fade = true; shadow = false; };
          tooltip = { fade = true; shadow = false; opacity = 0.75; focus = true; full-shadow = false; };
          dock = { shadow = false; };
          dnd = { shadow = false; };
          popup_menu = { opacity = 1.0; };
          dropdown_menu = { opacity = 1.0; };
        };
      };
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    # Emacs runs as a daemon
    emacs = {
      enable = true;
      package = pkgs.emacs-unstable;
    };
  };

  # When emacs builds from no cache, it exceeds the 90s timeout default
  systemd.user.services.emacs = {
    serviceConfig.TimeoutStartSec = "7min";
  };

  # Enable CUPS to print documents
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.brlaser ]; # Brother printer driver

  # Enable sound
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Video support
  hardware = {
    opengl.enable = true;
    # nvidia.modesetting.enable = true;

    # Enable Xbox support
    # xone.enable = true;

    # Crypto wallet support
    ledger.enable = true;
    
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };


 # Add docker daemon
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;
  # virtualisation.docker.logDriver = "json-file";

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
        "podman"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
       {
         command = "${pkgs.systemd}/bin/reboot";
         options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = with pkgs; [
    dejavu_fonts
    emacs-all-the-icons-fonts
    feather-font # from overlay
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    # agenix.packages."${pkgs.system}".default # "x86_64-linux"
    gitAndTools.gitFull
    inetutils
    tailscale
    arion
  ];

  system.stateVersion = "21.05"; # Don't change this
}
