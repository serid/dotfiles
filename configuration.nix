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

  #services.fwupd.enable = true;

  # Enable GNOME on Wayland.
  #services.xserver.enable = true;
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = true;
  #services.xserver.desktopManager.gnome.enable = true;

  #services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration # Keep me if you use KDE Connect
    kdepim-runtime # Unneeded if you use Thunderbird, etc.
    konsole
    oxygen
    elisa
    kwalletmanager
  ];

  # Enable Hyprland
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = true;
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  #programs.hyprland.enable = true;

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
  users.users.root = {
    hashedPassword = "$6$rH1RccqGWOa8FATa$vdFe6zPnRj7EqiI.Bh1XiFlEI5xMUdKvAeeA5Z6l8UDE8Cgxr9F5.zuouiHsMQ5RN0Dz8glokC5.1Z1i6dIr.1";
  };
  users.users.jit = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      # rust utils
      eza
      bat
      fd
      ripgrep
      dust
      tokei

      openssl # for decrypting github token
      git
      unzip
      ghostty
      gimp
      tdesktop
      thunderbird
      firefox
      ungoogled-chromium
      #opera

      xray
      proxychains-ng
      #discord

      #jetbrains.idea-ultimate

      vscode
      #vscodium
      /*
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          #bbenoist.nix
          #haskell.haskell
          #justusadam.language-haskell
          #rust-lang.rust-analyzer
        ];
      })
      */

      # TODO: declaratively set keybord shortcut for switching layout https://github.com/gvolpe/dconf2nix
      #gnomeExtensions.tweaks-in-system-menu
    ];
    # A hashed password can be generated using "mkpasswd -m sha-512" after installing the mkpasswd package.
    hashedPassword = "$6$cezSswUwD1jaiyLv$gZfEYmYXsdirpkDp8C6apknbpdzU3B2CzP5PPC7YrFZICn51d3GZFx6xpvLdETsL0K713cjUwoBz9sCNsxDoR.";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    helix # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
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
