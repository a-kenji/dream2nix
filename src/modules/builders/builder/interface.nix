{
  config,
  lib,
  ...
}: let
  t = lib.types;
in {
  options = {
    disabled = lib.mkOption {
      type = t.bool;
      default = false;
      description = "Whether to disable the builder, if disabled it can't be used.";
    };
    name = lib.mkOption {
      type = t.str;
      description = "Name of the builder.";
    };
    subsystem = lib.mkOption {
      type = t.str;
      description = "Subsystem of the builder.";
    };
    build = lib.mkOption {
      type = t.functionTo (t.functionTo t.attrs);
      default = _: _: {};
    };
    type = lib.mkOption {
      type = t.enum [
        "pure"
        "ifd"
      ];
    };
  };
}
