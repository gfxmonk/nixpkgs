{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "gala";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~gala-dev/gala/trunk/tarball/429?start_revid=429";
		sha256="1571574kjxiwdj91spjnzixz8mjxi25rwrh98hyfldbpsx48d1vz";
	};
	buildInputs = with pkgs; [
		autoconf automake111x libtool intltool pkgconfig
		gnome.gnome_common vala
		glib
		gnome3.gtk
		gnome3.libgee
		xlibs.libX11
		gnome3.gnome_desktop
		gnome3.clutter
		gnome3.clutter_gtk
		gnome3.mutter
		# gnome3.gnome-backgrounds
		(callPackage ./bamf.nix {})
		(callPackage ./plank.nix {})
		granite
		gnome3.gsettings_desktop_schemas
		gnome3.libcanberra
		makeWrapper
	];
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	configureScript = "./autogen.sh";
  #XXX schemas installed in share/gsettings-schemas/gala, not just share?
  preFixup = ''
    wrapProgram "$out/bin/gala" \
      --prefix XDG_DATA_DIRS : "${gnome3.gnome_themes_standard}/share:$GSETTINGS_SCHEMAS_PATH" \
      --set LIBGL_DRIVERS_PATH "${mesa_drivers}/lib/dri" \
      ;
  '';
}

