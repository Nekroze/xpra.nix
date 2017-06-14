{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.xpra;
in {
  options = {
    services.xpra = {
      enable = mkEnableOption "xpra server";
      bind = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Use a bind option for the server.
          Set to False for ssh serving options.
        '';
      };
      bindOption = mkOption {
        type = types.enum [ "bind" "bind-tcp" "bind-vsock" "bind-ssl" ];
        default = "bind-tcp";
        example = "bind-vsock";
        description = ''
          The option for the server to bind with.
          One of; bind, bind-vsock, bind-tcp, bind-ssl.
        '';
      };
      bindLocation = mkOption {
        type = types.str;
        default = "0.0.0.0";
        example = "xpra.sock";
        description = "Location to bind to with the bindOption, paths are prefixed with $dataDir/.xpra/$hostname-.";
      };
      bindPort = mkOption {
        type = types.int;
        default = 4141;
        description = "TCP port to listen on when binding to a network interface";
      };
      display = mkOption {
        type = types.nullOr types.str;
        default = "";
        example = ":100";
        description = "display to use for xpra.";
      };
      mmapLocation = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/sys/devices/pci0000:00/0000:00:04.0/resource2";
        description = "Device path of the mmap file to utilise.";
      };
      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/xpra";
        description = "Home data directory for xpra.";
      };
      extraOpts = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional command line options to be passed to xpra.";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.xpra = {
      enable = true;
      description = "Xpra server";
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 1;
      };
      environment = {
        HOME = cfg.dataDir;
      };
      wantedBy = [ "multi-user.target" ];
      script = ''
        mkdir -p $HOME && cd $HOME
        ${pkgs.xpra}/bin/xpra start ${concatStringsSep " " (flatten [
          "--no-daemon"
          (optional (!isNull cfg.display) cfg.display)
          (optional cfg.bind " --${cfg.bindOption}=${cfg.bindLocation}${optionalString (cfg.bindOption == "bind-tcp" || cfg.bindOption == "bind-ssl") (":${toString cfg.bindPort}")}")
          (optional (!isNull cfg.mmapLocation) "-d mmap --mmap=${cfg.mmapLocation}")
        ])}
      '';
    };
  };
}
