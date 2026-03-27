{ config, pkgs, lib, ... }:
{
  systemd.services.tmp-workshop = {
    description = "Create a temporary working directory";
    wantedBy = [ "graphical.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jit";
    serviceConfig.WorkingDirectory = "/";
    script = ''
      mkdir -p /tmp/workshop
    '';
  };
}