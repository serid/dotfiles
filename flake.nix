{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-old, nixpkgs-unstable, impermanence, nix-index-database, ... }@inputs:
    let sharedModules = [
      ./configuration.nix
      ./services.nix
      ./home-linker/home-linker.nix

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
      specialArgs = {
        pkgs-old = nixpkgs-old.legacyPackages.x86_64-linux;
        pkgs-unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
      };
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
