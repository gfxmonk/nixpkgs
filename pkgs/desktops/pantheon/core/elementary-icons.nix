{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "elementary-icon";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~danrabbit/elementaryicons/trunk/tarball/1436?start_revid=1436";
		sha256="0cck5y2aj4bzxy3kkcy62pq5lnnh3iim0lxna484bgnj527wmaf7";
	};
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	installPhase = ''
		mkdir -p $out/share/icons
		cp -a . $out/share/icons/elementary
	'';
}
