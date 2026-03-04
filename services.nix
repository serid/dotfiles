{ config, pkgs, lib, ... }:
{
  # Commit changes to bckp
  systemd.services.bckp = {
    wantedBy = [ "default.target" ];
    wants = [ "-.mount" ];
    after = [ "-.mount" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jit";
    serviceConfig.WorkingDirectory = "/workshop/bckp";
    script = ''
      mkdir /tmp/workshop
    '';
  };
}