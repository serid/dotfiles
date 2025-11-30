{ config, pkgs, lib, ... }:
{
  networking.hostName = "svarog";

  programs.steam = {
    enable = true;
  };
}