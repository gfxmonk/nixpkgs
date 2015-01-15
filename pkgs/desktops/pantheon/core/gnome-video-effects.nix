{pkgs ? import <nixpkgs> {}}:
with pkgs;
stdenv.mkDerivation {
	name = "gnome-video-effects";
	src = fetchurl {
		url = "https://download.gnome.org/sources/gnome-video-effects/0.4/gnome-video-effects-0.4.1.tar.xz";
		sha256="0jl4iny2dqpcgi3sgxzpgnbw0752i8ay3rscp2cgdjlp79ql5gil";
	};
	buildInputs = with pkgs; [
		pkgconfig
		intltool
	];
}


