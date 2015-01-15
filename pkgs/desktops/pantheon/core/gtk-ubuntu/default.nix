{ gnome3, callPackage, lib, pkgs }:

# This is the upstream gtk+ with just enough ubuntu-specific
# patches to work for elementary. It is not a full "ubuntu-gtk"

let
	patches = (callPackage ./patches.nix {});
in
lib.overrideDerivation gnome3.gtk (base: {
	patches = (base.patches or []) ++ [ ./ubuntu_gtk_custom_menu_items.patch ];
	buildInputs = (base.buildInputs or []) ++ [ pkgs.automake114x pkgs.autoconf ];
	# prePatch = (base.prePatch or "") + ''
	# tar xzf ${patches} --strip-components=2
	# # XXX why can't I just use patches=path/to/patches/* ...?
	# patches="$patches $(find ubuntugtk3/debian/patches -type f | sort)"
	# '';
	# patchFlags = "--verbose -p1 --unified";
	# postPatch =''
	# 	echo "DONE PATCHING $patches"
	# 	exit 2
	# '';
})
