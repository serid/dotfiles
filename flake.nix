{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    impermanence.url = "github:nix-community/impermanence";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, impermanence, nix-index-database, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix

        impermanence.nixosModules.default

        nix-index-database.nixosModules.nix-index
        { programs.nix-index-database.comma.enable = true; }

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
