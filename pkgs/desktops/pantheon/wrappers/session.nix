{pkgs, additionalApps ? [], pantheonComponents ? null,
cerbere, gala, slingshot, wingpanel, plank, switchboard,
elementary_gtk_theme, elementary_icons, gnome3, bamf, pantheon-terminal }:
with pkgs;
let
	defaultComponents = [
		slingshot wingpanel plank gala cerbere
	];
	apps = [
		bamf
		zeitgeist
		gnome3.dconf
		gnome3.gnome_themes_standard
		elementary_gtk_theme elementary_icons
		gnome3.gnome_icon_theme hicolor_icon_theme
		gnome3.dconf
		pantheon-terminal switchboard

		(lib.overrideDerivation at_spi2_core (base: {
			configureFlags = "--with-dbus-daemondir=${dbus_daemon}/bin";
		}))
	]
		++ (if pantheonComponents == null then defaultComponents else pantheonComponents)
		++ additionalApps
	;
	joinPaths = suffix: deps: lib.concatStringsSep ":" (map (dep: "${dep}/${suffix}") deps);
in
stdenv.mkDerivation {
	name="session-wrap";
	unpackPhase = "true";
	dontInstall = true;
	buildInputs = [
		gnome3.gsettings_desktop_schemas
		makeWrapper
	];

	configurePhase = "true";
	buildPhase = ''
		mkdir -p $out/bin
		cat > $out/bin/dbus-wrapper <<"EOF"
			#!${pkgs.bash}/bin/bash
			set -eu
			base="$(mktemp -d)"
			pid=""
			echo "created tempdir $base" >&2
			[[ "$base" == /tmp/* ]]
			function cleanup () {
				rm -rf "$base"
				if [ -n "$pid" ]; then
					echo "Killing dbus ($pid)" >&2
					# wait "$pid"
					# set -x
					kill -INT "$pid"
					while kill -0 "$pid" 2>/dev/null; do
						sleep 0.2
					done
				fi
			}
			trap cleanup EXIT
			exec 3> "$base/pid"
			exec 4> "$base/address"
			${dbus_daemon}/bin/dbus-daemon --session --fork --print-pid=3 --print-address=4
			pid="$(cat "$base/pid")"
			address="$(cat "$base/address")"
			echo "DBUS_SESSION_BUS_ADDRESS=$address" >&2
			export DBUS_SESSION_BUS_ADDRESS="$address"
			"$@"
EOF
		chmod +x $out/bin/dbus-wrapper
	'';

	#XXX GSETTINGS_SCHEMAS_PATH is empty, shouldn't it contain gnome3.gsettings_desktop_schemas?

	preFixup = ''
		echo "XDG_ICON_DIRS = $XDG_ICON_DIRS"
		echo "GSETTINGS_SCHEMAS_PATH = $GSETTINGS_SCHEMAS_PATH"
		echo "---------------"
		makeWrapper $out/bin/dbus-wrapper $out/bin/pantheon-session \
			--prefix XDG_DATA_DIRS : ${gnome3.gsettings_desktop_schemas}/share/gsettings-schemas/gsettings-desktop-schemas-* \
			--prefix XDG_DATA_DIRS : "${joinPaths "share" apps}:${gala}/share/gsettings-schemas/gala:$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH" \
			--set GTK_DATA_PREFIX "${elementary_gtk_theme}" \
			--set GDK_PIXBUF_MODULE_FILE "${callPackage ./all-pixbuf-loaders.nix {}}" \
			--prefix PATH : "${joinPaths "bin" apps}" \
			--prefix GIO_EXTRA_MODULES : "${gnome3.dconf}/lib/gio/modules" \
			;
	'';
}



