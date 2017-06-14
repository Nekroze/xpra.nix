#!/run/current-system/sw/bin/nix-build
import <nixpkgs/nixos/tests/make-test.nix> {
  machine = { config, pkgs, ... }: {
    imports = [
      ./default.nix
    ];
    services.xpra = {
      enable = true;
      bindPort = 4444;
    };
  };

  testScript = ''
    subtest "xpra is running", sub {
      $machine->waitForUnit("xpra.service");
    };
    subtest "xpra is listening on tcp", sub {
      $machine->waitForOpenPort(4444);
    };
    subtest "xpra is listening on socket", sub {
      $machine->waitForFile("/var/lib/xpra/.xpra/machine-0");
    };
  '';
}
