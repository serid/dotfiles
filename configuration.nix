# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Select between systemd-boot and GRUB EFI bootloaders.
  #boot.loader.systemd-boot.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  #boot.loader.grub.enable = true;
  #boot.loader.grub.device = "nodev";
  #boot.loader.grub.efiSupport = true;
  #boot.loader.grub.useOSProber = true;  
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Enable GNOME on Wayland.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable the X11 windowing system.
  #services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # vscode fails, fallback to a blanket `allowUnfree = true` for now
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #  "code"
  #  "vscode-1.73.1"
  #  "discord"
  #];
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.jit = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      openssl # for decrypting github token
      git
      chromium
      tdesktop
      discord

      jetbrains.idea-ultimate

      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          #bbenoist.nix
          rust-lang.rust-analyzer
        ];
      })

      # TODO: declaratively set keybord shortcut for switching layout https://github.com/gvolpe/dconf2nix
      #gnomeExtensions.tweaks-in-system-menu
  #     thunderbird
    ];
    # A hashed password can be generated using "mkpasswd -m sha-512" after installing the mkpasswd package.
    hashedPassword = "$6$FDRuJ6XblatbUF8O$2xWWByeNSpKma6a6o2Dm8xO7aZ3XTK9JgYxrIXfzRhcb2zE9OOv.EF4j9K2ay0Ibc5bp37SygP//rYD6wsvjK/";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    file
    wget
  ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
