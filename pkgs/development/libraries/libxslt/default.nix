{ stdenv, fetchurl, libxml2, findXMLCatalogs, pythonSupport ? false, python }:

stdenv.mkDerivation rec {
  name = "libxslt-1.1.28";

  src = fetchurl {
    url = "ftp://xmlsoft.org/libxml2/${name}.tar.gz";
    sha256 = "13029baw9kkyjgr7q3jccw2mz38amq7mmpr5p3bh775qawd1bisz";
  };

  buildInputs = stdenv.lib.optional pythonSupport python
    ++ [ libxml2 ];

  propagatedBuildInputs = [ findXMLCatalogs ];

  patches = stdenv.lib.optionals stdenv.isSunOS [ ./patch-ah.patch ];

  configureFlags = [
    "--with-libxml-prefix=${libxml2}"
    "--without-crypto"
    "--without-debug"
    "--without-mem-debug"
    "--without-debugger"
  ] ++ (if pythonSupport
    then [ "--with-python=${python}" ]
    else [ "--with-python=no" ] # otherwise build impurity bites us
  );

  meta = {
    homepage = http://xmlsoft.org/XSLT/;
    description = "A C library and tools to do XSL transformations";
    license = "bsd";
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.eelco ];
  };
} // stdenv.lib.optionalAttrs pythonSupport {
  # this is a pair of ugly hacks to make python stuff install into the right place
  preInstall = ''substituteInPlace python/libxml2mod.la --replace "${python}" "$out"'';
  installFlags = ''pythondir="$(out)/lib/${python.libPrefix}/site-packages"'';
}
