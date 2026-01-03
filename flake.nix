{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    impermanence.url = "github:nix-community/impermanence";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, impermanence, nix-index-database, ... }@inputs:
    let sharedModules = [
      ./configuration.nix
      ./home-linker.nix

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
    ]; in {
    nixosConfigurations.svarog = nixpkgs.lib.nixosSystem {
      modules = sharedModules ++ [
        ./svarog/hardware-configuration.nix
        ./svarog/configuration.nix
      ];
    };
    nixosConfigurations.veles = nixpkgs.lib.nixosSystem {
      modules = sharedModules ++ [
        ./veles/hardware-configuration.nix
        ./veles/configuration.nix
      ];
    };
  };
}
