let

  githubTarball = owner: repo: rev:
    builtins.fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    };

  latestPkgs = import (githubTarball "NixOS" "nixpkgs" "91d5b3f07d27622ff620ff31fa5edce15a5822fa") {};
  # gitignore = pkgs.nix-gitignore.gitignoreSourcePure [ ./.gitignore ];
  
in
{ obelisk ? import ./.obelisk/impl {
    system = builtins.currentSystem;
    iosSdkVersion = "10.2";
    # You must accept the Android Software Development Kit License Agreement at
    # https://developer.android.com/studio/terms in order to build Android apps.
    # Uncomment and set this to `true` to indicate your acceptance:
    # config.android_sdk.accept_license = false;
  }
}:
with obelisk;
project ./. ({ pkgs, ... }: {

  overrides = self: super: {
    servant = pkgs.haskell.lib.dontCheck super.servant;
    servant-reflex = self.callCabal2nix "servant-reflex" (githubTarball "imalsogreg" "servant-reflex" "9310745a99c670ec244ecdcac6577d0f365f6946") {};
  };
  
  shellToolOverrides = ghc: super: {
    inherit (latestPkgs) yarn dbmate;
  };
  
  android.applicationId = "systems.obsidian.obelisk.examples.minimal";
  android.displayName = "Obelisk Minimal Example";
  ios.bundleIdentifier = "systems.obsidian.obelisk.examples.minimal";
  ios.bundleName = "Obelisk Minimal Example";
})
