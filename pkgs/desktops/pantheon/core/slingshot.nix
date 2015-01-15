{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "slingshot";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~elementary-pantheon/slingshot/trunk/tarball/499?start_revid=499";
		sha256="1bwp8bxwmq909kq58pdfb88p61fd81iq7zd9c84fp8ks5zy3glvb";
	};
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	buildInputs = with pkgs; [
		# libtool intltool
		cmake
		pkgconfig
		gnome.gnome_common vala
		glib
		gnome3.gtk
		# (callPackage ./libgee-0.6.nix {})
		gnome3.libgee
		# gnome.gnome_menus
		gnome3.gnome-menus
		gnome3.gnome_desktop
		gnome3.clutter
		gnome3.clutter_gtk
		gnome.libsoup
		# (callPackage ./bamf.nix {})
		# (callPackage ./plank.nix {})
		granite
		gnome3.gsettings_desktop_schemas
		gnome3.libcanberra
		makeWrapper
		libwnck3
		zeitgeist
		gettext
		# TODO: unity?
	];

	# hardcodes appmenu destination as /etc/xdg/menus
	postPatch = ''
		sed -i -e 's|DESTINATION /etc/xdg|DESTINATION share|' CMakeLists.txt
	'';

	# XXX enable unity integration?
	cmakeFlags = "-DUSE_UNITY=OFF" ;
	# configurePhase = ''
	# 	mkdir build
	# 	cd build
	# 	cmake .. 
	# '';

	# makeFlags = "-C build";
}

