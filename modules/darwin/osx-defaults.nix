{ ... }:

{
  system.defaults.NSGlobalDomain = {
    # "com.apple.trackpad.scaling" = "3.0";
    AppleInterfaceStyleSwitchesAutomatically = false;
    AppleMeasurementUnits = "Inches";
    AppleMetricUnits = 0;
    AppleShowScrollBars = "WhenScrolling";
    AppleTemperatureUnit = "Fahrenheit";
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSTableViewDefaultSizeMode = 3;
    NSUseAnimatedFocusRing = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = true;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = true; # i think i like this overall!
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    NSScrollAnimationEnabled = true;
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
    _HIHideMenuBar = false;
  };

  # Firewall
  system.defaults.alf = {
    globalstate = 1;
    allowsignedenabled = 1;
    allowdownloadsignedenabled = 1;
    stealthenabled = 1;
  };

  # Dock and Mission Control
  system.defaults.dock = {
    autohide = true;
    orientation = "left";
    expose-group-by-app = false;
    mru-spaces = false;
    tilesize = 26;
    show-process-indicators = true;
    show-recents = false;
    mineffect = "genie";
    minimize-to-application = false;
    mouse-over-hilite-stack = true;
    enable-spring-load-actions-on-all-items = true;
  };

  # Login and lock screen
  system.defaults.loginwindow = {
    GuestEnabled = false;
    DisableConsoleAccess = true;
  };

  # Spaces
  # system.defaults.spaces.spans-displays = false;

  # Trackpad
  system.defaults.trackpad = {
    Clicking = false;
    TrackpadRightClick = true;
  };

  # Finder
  system.defaults.finder = {
    FXEnableExtensionChangeWarning = true;
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = true;
  };
}
