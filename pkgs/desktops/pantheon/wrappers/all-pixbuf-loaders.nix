{ stdenv, gdk_pixbuf, librsvg }:

# XXX this surely doesn't belong here...

stdenv.mkDerivation {
  name = "gdk-pixbuf-loaders";
  unpackPhase = "true";
  installPhase = ''
    cat "${gdk_pixbuf}/lib/gdk-pixbuf-2.0/"*/loaders.cache > $out
    cat "${librsvg}/lib/gdk-pixbuf/loaders.cache" >> $out
  '';
}
