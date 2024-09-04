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
        setDesktopRemote = pkgs.callPackage ./setdesktop-remote pkgConf;
        setDesktopPhysical = pkgs.callPackage ./setdesktop-physical pkgConf;
      })
    ];

    services.xserver.enable = true;

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };

    services.displayManager.sddm.enable = false;
    services.desktopManager.plasma6.enable = true;

    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    
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
