{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "cerbere";
	src = fetchurl {
		url = "http://bazaar.launchpad.net/~elementary-pantheon/cerbere/cerbere/tarball/48?start_revid=48";
		sha256="108m932pzwk7q7nhi90zxjx7l3laaa9c8nafcxbv77bvlq7vd4zz";
	};
	unpackCmd = "tar xzf $curSrc --strip-components=2";
	buildInputs = with pkgs; [
		cmake
		pkgconfig
		vala
		glib
		gnome3.libgee
	];

	# XXX this should be handled by pkgconfig, but the build step
	# seems to fail otherwise
	# XXX we're also hacking out session registration, because we just want to run it on-demand for now...
	preConfigure = ''
		export XDG_DATA_DIRS="${gnome3.libgee}/share:'' + "$\{XDG_DATA_DIRS:+:$XDG_DATA_DIRS}" + ''"
		sed -i -s '/^ *register_session_client/d' src/Cerbere.vala
	'';
}

