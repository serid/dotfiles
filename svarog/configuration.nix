{ config, pkgs, lib, ... }:
{
  networking.hostName = "svarog";

  programs.steam = {
    enable = true;
  };

  # Commit changes to bckp
  systemd.services.bckp = {
    wantedBy = [ "default.target" ];
    wants = [ "home.mount" ];
    after = [ "home.mount" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jit";
    serviceConfig.WorkingDirectory = "/workshop/bckp";
    script = ''
      if [ -n "$(${pkgs.git}/bin/git status --porcelain)" ]; then
        ${pkgs.git}/bin/git add .
        ${pkgs.git}/bin/git commit -m "$(${pkgs.git}/bin/git status --porcelain | ${pkgs.gawk}/bin/awk '{print $2}' | tr '\n' ' ')"
      fi
    '';
  };
}