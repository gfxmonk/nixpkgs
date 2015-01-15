{ callPackage, pkgs }:

rec {
  gnome3 = pkgs.gnome3_12 // { recurseForDerivations = false; };

  # dependencies
  elementary_gtk_theme = callPackage ./core/elementary-gtk-theme.nix { };

  elementary_icons = callPackage ./core/elementary-icons.nix { };

  bamf = callPackage ./core/bamf.nix { };

  # XXX probably belongs in gnome3
  cheese_gtk = callPackage ./apps/cheese-gtk.nix { };
  libido = callPackage ./core/libido.nix { };
  libindicator = callPackage ./core/libindicator.nix { };

  # pantheon components
  cerbere = callPackage ./core/cerbere.nix { };

  gala = callPackage ./core/gala.nix { };

  plank = callPackage ./core/plank.nix { };

  slingshot = callPackage ./core/slingshot.nix { };

  wingpanel = callPackage ./core/wingpanel.nix { };

  mkSession = { additionalApps ? [], pantheonComponents ? null} @ args: callPackage ./wrappers/session.nix args;

  # apps
  pantheon-terminal = callPackage ./apps/pantheon-terminal { };

  switchboard = callPackage ./apps/switchboard { };

}
