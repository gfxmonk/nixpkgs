{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "switchboard";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~elementary-pantheon/switchboard/switchboard/tarball/534?start_revid=534";
		sha256="1bpw2fzqdmn7hx57z29q22q1kyh1372pd1dy6h1aakci5m570dac";
	};
	buildInputs = with pkgs; [
		pkgconfig
		gettext
		glib
		gnome3.gtk
		gnome3.libgee
		(callPackage ../cheese-gtk.nix {})
		cmake
		vala
		granite
	];
	cmakeFlags = "-DUSE_UNITY=OFF";
	unpackCmd = "tar xzf $curSrc --strip-components=2";
}
