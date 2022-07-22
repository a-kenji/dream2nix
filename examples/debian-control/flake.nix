{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    src.url = "github:pop-os/cosmic-launcher";
    src.flake = false;
  };

  outputs = {
    self,
    dream2nix,
    src,
  } @ inp:
    (dream2nix.lib.makeFlakeOutputs {
      systems = ["x86_64-linux"];
      config.projectRoot = ./.;
      source = src;
      # settings = [
      #   {
      #     # optionally define python version
      #     subsystemInfo.pythonAttr = "python38";
      #     # # optionally define extra setup requirements;
      #     subsystemInfo.extraSetupDeps = ["cython > 0.29"];
      #   }
      # ];
    });
    # // {
    #   checks.x86_64-linux.aiohttp = self.packages.x86_64-linux.main;
    # };
}
