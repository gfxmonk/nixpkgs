{ stdenv, fetchurl, pkgconfig, gnome3, glib, callPackage, pkgs }:

let
	major = "12.10";
	minor = "1";
	version="${major}.${minor}";
in

stdenv.mkDerivation rec {
  name = "libindicator-${version}";
  src = fetchurl {
    url = "http://bazaar.launchpad.net/~indicator-applet-developers/libindicator/trunk.15.04/tarball/531?start_revid=531";
    sha256 = "0yw0jgbf00fpqpfyp9g69mq4c64inpajqayzd04bflm52nrsz6zd";
  };
  unpackCmd = "tar xzf $curSrc --strip-components=2";

  # buildInputs = [ pkgconfig (callPackage ./gtk-ubuntu {}) glib ];
  buildInputs = [ pkgconfig gnome3.gtk glib
    pkgs.gnome3.gnome_common
    # pkgs.gnome3.gio
    pkgs.libtool
    (callPackage ./libido.nix {})
  ];

  postPatch = ''
    sed -i -e 's/-Werror//g' configure.* */Makefile.in
  '';
  configureScript = "./autogen.sh";

}

