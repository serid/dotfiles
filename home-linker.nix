let configs = {
  ".vimrc" = ".vimrc";
  "settings.json" = ".config/Code/User/settings.json";
  "keybindings.json" = ".config/Code/User/keybindings.json";
  "config.toml" = ".config/helix/config.toml";
  "fish_prompt.fish" = ".config/fish/functions/fish_prompt.fish";
  "proxychains.conf" = ".proxychains/proxychains.conf";
};
  script = "cat $0\n" +
    builtins.concatStringsSep "" (builtins.attrValues (builtins.mapAttrs (dotfilesPath: homePath: ''
      mkdir -p "/home/jit/$(dirname "${homePath}")"
      ln -sf /workshop/dotfiles/dotfiles/${dotfilesPath} /home/jit/${homePath}
      '') configs)); in
{
  systemd.services.just-in-time-home-linker = {
    wantedBy = [ "default.target" ];
    wants = [ "home.mount" ];
    after = [ "home.mount" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.User = "jit";
    inherit script;
  };

  systemd.services.just-in-time-home-linker-root = {
    wantedBy = [ "default.target" ];
    wants = [ "home.mount" ];
    after = [ "home.mount" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ln -sf /workshop/dotfiles/flake.nix /etc/nixos/flake.nix
    '';
  };
}

# Resulting script
# ln -sf /workshop/dotfiles/dotfiles/.vimrc /home/jit/.vimrc
# ln -sf /workshop/dotfiles/dotfiles/settings.json /home/jit/.config/Code/User/settings.json
# ln -sf /workshop/dotfiles/dotfiles/keybindings.json /home/jit/.config/Code/User/keybindings.json
# ...