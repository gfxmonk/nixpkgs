{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "wingpanel";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~elementary-pantheon/wingpanel/0.3.x/tarball/195?start_revid=195";
		sha256="15s7mljwwa203zpnz3k7kw11k4x2phsx9k0bmpkwjsxdx3zrhipv";
	};
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	buildInputs = with pkgs; [
		# libtool intltool
		cmake
		pkgconfig
		gnome.gnome_common vala
		glib
		# gnome3.gtk
		# (callPackage ./libgee-0.6.nix {})
		gnome3.libgee
		# gnome.gnome_menus
		# gnome3.gnome-menus
		# gnome3.gnome_desktop
		# gnome3.clutter
		# gnome3.clutter_gtk
		# gnome.libsoup
		# (callPackage ./bamf.nix {})
		(callPackage ./gtk-ubuntu {})
		granite
		gnome3.gsettings_desktop_schemas
		# gnome3.libcanberra
		makeWrapper
		(callPackage ./libido.nix {})
		(callPackage ./libindicator.nix {})
		libwnck3
		# zeitgeist
		gettext
		# TODO: unity?
	];
}

