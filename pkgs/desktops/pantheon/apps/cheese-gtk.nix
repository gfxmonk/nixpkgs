{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "cheese-gtk";
	src = fetchurl {
		url = "https://download.gnome.org/sources/cheese/3.12/cheese-3.12.2.tar.xz";
		sha256="0r5wwcbjx91nglw9ldcxqkh0n8vc1s541979slxjw8jywxlm7d57";
	};
	buildInputs = with pkgs; [
		(callPackage ../core/gnome-video-effects.nix {})
		pkgconfig
		intltool
		libtool
		itstool # XXX disable docs instead?
		glib
		gnome3.gtk
		vala
		eudev
		# udev145
		gnome3.gsettings_desktop_schemas
		gnome3.gnome_desktop
		gnome3.clutter
		gnome3.clutter_gtk
		gnome3.clutter-gst
		gnome3.libcanberra
		gstreamer
		gst_all_1.gst-plugins-bad
		librsvg
	];
}


