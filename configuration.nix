# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, lib, ... }:
{
  fileSystems."/".options = [ "defaults" "size=32G" "mode=755" "noatime" ];
  fileSystems."/nix".options = [ "noatime" ];
  fileSystems."/persist".options = [ "noatime" ];
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/workshop".options = [ "noatime" ];

  fileSystems."/boot".options = [ "noatime" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/var/lib/nixos"
      "/var/log"

      "/home"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
    ];
  };

  security.sudo.extraConfig = ''
    # Disarm lectures lest they be shown every reboot
    Defaults lecture = never
  '';

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl."kernel.sysrq" = 1;

  networking.networkmanager.enable = true;
  networking.useDHCP = false;

  time.timeZone = "Europe/Moscow";
  i18n = {
    supportedLocales = [ "all" ];
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_COLLATE = "C.UTF-8";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    extra-experimental-features = nix-command
    extra-experimental-features = flakes
  '';

  users.mutableUsers = false;
  users.users.root.initialPassword = "1";
  users.users.jit = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      # rust utils
      bat
      fd
      ripgrep
      dust
      tokei

      tree

      unzip
      ghostty
      gimp
      tdesktop
      thunderbird
      firefox
      ungoogled-chromium
      #opera

      kdePackages.karousel
      vial

      xray
      proxychains-ng
      #discord

      #jetbrains.idea-ultimate

      vscode
    ];
    initialPassword = "1";
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    helix # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    file
    wget
  ];

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

  environment.variables = {
    EDITOR = "${pkgs.helix}/bin/hx";
    LESS = "-RiF --mouse --wheel-lines=3";
  };
  #services.deluge.enable = true;
  programs.fish.enable = true;
  # todo: port auto-shell
  programs.fish.shellAliases = {
    nix-shell = "nix-shell --run \"$SHELL\"";
    l = "${pkgs.eza}/bin/eza --group-directories-first";
    ll = "l -l";
    la = "l -A";
    rm = "rm -vI";
    rmr = "rm -r";
    j = "jobs";
    o = "xdg-open";
    hexdump = "hexdump -C";
    tar-ex = "tar -xvf";
    poff = "poweroff";
    diff = "diff --color=auto";
    git-river = "${pkgs.git}/bin/git log --all --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
  };
  programs.fish.interactiveShellInit = ''
    set -g fish_greeting

    function cd; builtin cd $argv && l; end

    # Default "nix develop" does not work with "exec fish"
    function nd
      nix develop $argv -c "$SHELL"
    end

    # Show status and changes to config before enacting them
    function nb
      git -C /workshop/dotfiles status --verbose --verbose
      sudo nixos-rebuild $argv
    end

    function q
      if test -d $argv[1]
        ${pkgs.eza}/bin/eza $argv
        return
      end
      ${pkgs.bat}/bin/bat $argv
    end
    
    # Create a new "~/.git-credentials" in encrypted form
    function new_github_token
      echo "https://serid:$argv[1]@github.com" | ${pkgs.openssl}/bin/openssl aes-256-cbc -pbkdf2 -out /workshop/dotfiles/credentials.enc
    end

    function with_github_token
      ${pkgs.openssl}/bin/openssl aes-256-cbc -pbkdf2 -d -in /workshop/dotfiles/credentials.enc -out ~/.git-credentials || return
      $argv
      rm ~/.git-credentials
    end

    function nixgc
      sudo nix-collect-garbage -d

      echo "Deleting old bootloader entries."
      set last_generation $(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | awk 'END {print $1}')
      echo "Keeping generation $last_generation."
      sudo bash -c "cd /boot/loader/entries; ls | grep -v $last_generation | xargs rm"
    end
  '';

  # Drop from Bash into Fish immediatenly when opening an interactive shell AND not executing a command with "-c"
  programs.bash = {
    interactiveShellInit = ''
      if [[ -z ''${BASH_EXECUTION_STRING} ]]
      then
        export SHELL=${pkgs.fish}/bin/fish
        exec ${pkgs.fish}/bin/fish
      fi
    '';
  };

  programs.git = {
    enable = true;
    config = {
      credential.helper = "store";
        # let git = pkgs.git.override { withLibsecret = true; }; in
        # "${pkgs.git-credential-keepassxc}/bin/git-credential-keepassxc";
    };
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
