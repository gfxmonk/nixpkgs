{ stdenv, fetchurl, pkgconfig, gnome, gnome3, glib, libtool, callPackage, vala }:

stdenv.mkDerivation rec {
  name = "libido";
  src = fetchurl {
    url = "http://bazaar.launchpad.net/~indicator-applet-developers/ido/trunk.15.04/tarball/186?start_revid=186";
    sha256 = "1kg8zv5zaq2avr8mwp8lb643q0q3gc15xskf46ppc1iaisr8fc5d";
  };

  unpackCmd = "tar xzf $curSrc --strip-components=2";

  buildInputs = [ libtool pkgconfig
    # gnome3.gtk
    vala
    gnome3.gnome_common glib gnome.gtk_doc ];

  propagatedBuildInputs = [
    (callPackage ./gtk-ubuntu {})
  ];

  postPatch = ''
    sed -i -e 's/-Werror//g' configure.* */Makefile.in
  '';

  configureScript = "gnome-autogen.sh";
  configureFlags = "--disable-gtk-doc";

}

