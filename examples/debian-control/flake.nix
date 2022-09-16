{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    cosmic.url = "github:pop-os/cosmic-launcher";
    # cosmic.url = "github:i3/i3";
    cosmic.flake = false;
  };

  outputs = {
    self,
    dream2nix,
    cosmic,
  } @ inp: (dream2nix.lib.makeFlakeOutputs {
    systems = ["x86_64-linux"];
    config.projectRoot = ./.;
    source = cosmic;
    settings = [
      {
        # builder = "debian-control";
        translator = "debian-control-pure";
      }
    ];
  });
}
