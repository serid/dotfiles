{ config, pkgs, lib, ... }:
{
  networking.hostName = "svarog";

  programs.steam = {
    enable = true;
  };

  systemd.services.thermald-amd = {
    enable = false;
    description = "Adjust CPU frequency to prevent overheating";
    wantedBy = [ "graphical.target" ];
    serviceConfig.Type = "exec";
    serviceConfig.User = "root";
    serviceConfig.ExecStart = "${pkgs.bun}/bin/bun ${./thermald-amd.js}";
  };

  systemd.services.bckp = {
    description = "Commit changes to bckp";
    wantedBy = [ "graphical.target" ];
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