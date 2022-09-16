{ ... }: {
  type = "pure";

  build =
    { lib
    , pkgs
    , stdenv
    , # dream2nix inputs
      externals
    , ...
    }: {
         ### FUNCTIONS
         # AttrSet -> Bool) -> AttrSet -> [x]
         getCyclicDependencies
       , # name: version: -> [ {name=; version=; } ]
         getDependencies
       , # name: version: -> [ {name=; version=; } ]
         getSource
       , # name: version: -> store-path
         # to get information about the original source spec
         getSourceSpec
       , # name: version: -> {type="git"; url=""; hash="";}
         ### ATTRIBUTES
         subsystemAttrs
       , # attrset
         defaultPackageName
       , # string
         defaultPackageVersion
       , # string
         # all exported (top-level) package names and versions
         # attrset of pname -> version,
         packages
       , # all existing package names and versions
         # attrset of pname -> versions,
         # where versions is a list of version strings
         packageVersions
       , # function which applies overrides to a package
         # It must be applied by the builder to each individual derivation
         # Example:
         #   produceDerivation name (mkDerivation {...})
         produceDerivation
       , ...
       } @ args:
    let
      l = lib // builtins;

      # the main package
      # defaultPackage = throw (lib.toString allPackages);
      defaultPackage = pkgs.tree;
      # allPackages."${defaultPackageName}";
      # ."${defaultPackageVersion}";
      packages.default = pkgs.tree;
      packages."${defaultPackageName}-control"."1.0.0" = pkgs.tree;

      # packages to export
      # packages =
      #   lib.mapAttrs
      #   (name: version: {
      #     "${version}" = allPackages.${name}.${version};
      #   })
      #   args.packages;

      devShell = pkgs.mkShell {
        name = "test";
        buildInputs = [ ];
      };

      # manage packages in attrset to prevent duplicated evaluation
      allPackages =
        lib.mapAttrs
          (name: versions:
            lib.genAttrs
              versions
              (version: makeOnePackage name version))
          packageVersions;

      nativeBuildInputs = map (name: pkgs."${name}") (subsystemAttrs."control_inputs") ++ [ pkgs.glib ];
      # nativeBuildInputs = (getSource "control_inputs" "1.0.0") ++ [pkgs.pkg-config];
      # buildInputs = (getSource "control_inputs" "1.0.0") ++ [pkgs.pkg-config];
      buildInputs = [ ];

      devShells."${defaultPackageName}-control" = pkgs.mkShell {
        name = "${defaultPackageName}";
        buildInputs = nativeBuildInputs ++ buildInputs;
      };

      # Generates a derivation for a specific package name + version
      makeOnePackage = name: version:
        let
          pkg = stdenv.mkDerivation rec {
            pname = l.strings.sanitizeDerivationName name;
            inherit version;

            src = getSource name version;

            buildInputs =
              map
                (dep: allPackages."${dep.name}"."${dep.version}")
                (getDependencies name version)
              ++ getSource "control_inputs"
              ++ [ pkgs.pkg-config ];

            # TODO: Implement build phases
            # passthru.devShells."${defaultPackageName}-test" = pkgs.mkShell {
            #   name = "${defaultPackageName}-test" ;
            #   buildInputs = nativeBuildInputs ++ buildInputs;
            # };
          };
        in
        # apply packageOverrides to current derivation
        produceDerivation name pkg;
    in
    {
      inherit
        # defaultPackage
        # packages
        devShells
        ;
      # devShells = {
      #   test = pkgs.mkShell {
      #     buildInputs = [pkgs.tree];
      #   };
      # };
    };
}
