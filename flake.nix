{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = { self, nixpkgs, impermanence, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        impermanence.nixosModules.default

        # Graphical docker WIP
        (nixpkgs.lib.attrsets.optionalAttrs false {
          environment.persistence."/persist".directories = [ "/var/lib/docker" ];
          services.xserver.enable = true;
          virtualisation.docker.enable = true;
          virtualisation.docker.rootless = {
            enable = true;
            setSocketVariable = true;
          };
        })
      ];
    };
  };
}
