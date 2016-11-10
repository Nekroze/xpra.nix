{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.xpra;
in {
  options = {
    services.xpra = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the xpra server";
      };
      bind = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Use a bind option for the server.
          False for ssh serving options.
        '';
      };
      bindOption = mkOption {
        type = types.string;
        default = "bind";
        example = "bind-vsock";
        description = ''The option for the server to bind with.
        One of; bind, bind-vsock, bind-tcp, bind-ssl.
        '';
      };
      bindLocation = mkOption {
        type = types.string;
        default = "/var/run/xpra.sock";
        example = "auto:1234";
        description = "Location to bind to with the bindOption.";
      };
      display = mkOption {
        type = types.string;
        default = ":100";
        description = "Display to use for xpra.";
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
      wantedBy = [ "multi-user.target" ];
      script = "${pkgs.xpra}/bin/xpra start ${cfg.display}" + optionalString cfg.bind " --${cfg.bindOption}=${cfg.bindLocation}";
    };
  };
}
