{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.hybrid-remote;
in {

  options.hybrid-remote = {
    enable = lib.mkEnableOption "Enable hybrid-remote module";
    
    user = mkOption {
      type = types.str;
    };

    outputs = {
      remote = mkOption {
        type = types.str;
      };
      
      physical = mkOption {
        type = types.str;
      };
    };
    
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.overlays = let
      pkgConf = {
        physOutput = cfg.outputs.physical;
        remoteOutput= cfg.outputs.remote;
      };
    in [
      (self: super: {
        setDesktopRemote = pkgs.callPackage ./setdesktop {
          scriptName = "setdesktop-remote";
          activeOutput = cfg.outputs.remote;
          inactiveOutput = cfg.outputs.physical;
        };

        setDesktopPhysical = pkgs.callPackage ./setdesktop {
          scriptName = "setdesktop-physical";
          activeOutput = cfg.outputs.physical;
          inactiveOutput = cfg.outputs.remote;
        };
      })
    ];

    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    services.xserver.enable = true;

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = false;
    services.desktopManager.plasma6.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    
    # Enable automatic login for the user.
    services.greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "startplasma-wayland";
          user = "${cfg.user}";
        };
        default_session = initial_session;
      };
    };
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "${cfg.user}";
    
    environment.etc = {
      "xdg/kscreenlockerrc" = {
        text = ''
          [Daemon]
          LockOnStart=true
        '';

        mode = "0444";
      };

      "xdg/autostart/setdesktop-physical.desktop" = {
        text = ''
          [Desktop Entry]
          Exec=/run/current-system/sw/bin/setdesktop-physical
          Icon=application-x-executable-script
          Name=setdesktop-physical
          Type=Application
          X-KDE-AutostartScript=true
        '';
        mode = "0444";
      };
    };

    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;

      settings = {
        global_prep_cmd = builtins.toJSON [
          {
            do = "${pkgs.stdenv.shell} ${pkgs.setDesktopRemote}/bin/setdesktop-remote";
            undo = "${pkgs.stdenv.shell} ${pkgs.setDesktopPhysical}/bin/setdesktop-physical";
          }
        ];
      };
    };
    
    environment.systemPackages = with pkgs; [
      setDesktopPhysical
      setDesktopRemote
    ];
  };
}
