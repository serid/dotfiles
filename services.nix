{ config, pkgs, lib, ... }:
{
  # Commit changes to bckp
  systemd.services.tmp-workshop = {
    wantedBy = [ "default.target" ];
    wants = [ "-.mount" ];
    after = [ "-.mount" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jit";
    serviceConfig.WorkingDirectory = "/";
    script = ''
      mkdir -p /tmp/workshop
    '';
  };
}