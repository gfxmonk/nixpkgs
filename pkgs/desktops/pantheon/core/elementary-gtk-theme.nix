{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "elementary-gtk-theme";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~elementary-design/egtk/4.x/tarball/387?start_revid=387";
		sha256="046zny1pxfna6hdihb5qk0jx353jg3027813a3j4a3mnsss2xc0x";
	};
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	installPhase = ''
		mkdir -p $out/share/themes
		cp -a . $out/share/themes/elementary
	'';
}
