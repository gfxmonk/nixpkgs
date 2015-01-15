{pkgs}:
with pkgs;
stdenv.mkDerivation {
	name = "bamf";
	src = fetchurl {
		url = "https://launchpad.net/bamf/0.5/0.5.0/+download/bamf-0.5.0.tar.gz";
		sha256="04wiixx733s46b306hw14qicw50hfsrgw66gf1ib6ckdv77arcck";
	};
	buildInputs = [
		# autoconf automake111x
		libtool pkgconfig
		# intltool
		vala
		gnome.gnome_common
		# gnome.gtk_doc # XXX disable doc building instead
		glib
		# gnome3.libgee
		python
		libxslt_python
		libxml2Python
		# xlibs.libX11
		libwnck3
		libgtop
		gnome3.gtk
		# gdk_pixbuf
	];

	# XXX doesn't currently compile without warnings
	prePatch = "sed -i -e 's/-Werror -/-/' configure";

	configureFlags = [
		"--disable-webapps"
	];

	makeFlags = [
		"INTROSPECTION_GIRDIR=$(out)/share/gir-1.0"
		"INTROSPECTION_TYPELIBDIR=$(out)/lib/girepository"
	];

}


