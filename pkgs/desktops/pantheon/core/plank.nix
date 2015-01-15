{pkgs ? import <nixpkgs> {}, local ? false}:
with pkgs;
let
	bamf = callPackage ./bamf.nix {};
in
stdenv.mkDerivation {
	name = "plank";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~docky-core/plank/trunk/tarball/1153?start_revid=1153";
		sha256="0z7bhk2pw4i24xqrj03f7mw7aczqi7xis9jj0njyjfpjnidlcv9v";
	};
	buildInputs = with pkgs; [
		autoconf automake111x libtool intltool pkgconfig
		gnome.gnome_common vala
		glib libxml2
		gnome3.libgee
		xlibs.libX11
		libwnck3
		bamf
		gnome3.gtk
		gdk_pixbuf
		librsvg
		libpng
		hicolor_icon_theme
		gnome3.gnome_icon_theme
		makeWrapper
	];
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	# preFixup = ''
	#   wrapProgram "$out/bin/plank" \
	#     --set GDK_PIXBUF_MODULE_FILE "${librsvg}/lib/gdk-pixbuf/loaders.cache" \
	#     --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH" \
	#     ;
	# '';

	configureScript = "./autogen.sh";
}


