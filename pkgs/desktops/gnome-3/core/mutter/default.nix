{ fetchurl, fetchpatch, stdenv, pkgconfig, gnome3, gettext, gobject-introspection, upower, cairo
, pango, cogl, clutter, libstartup_notification, zenity, libcanberra-gtk3
, ninja, makeWrapper, xkeyboard_config, libxkbfile, libxkbcommon, libXtst, libinput
, gsettings-desktop-schemas, glib, gtk3, gnome-desktop
, geocode-glib, pipewire, libgudev, libwacom, xwayland, meson
, gnome-settings-daemon
, xorgserver
, python3
}:

stdenv.mkDerivation rec {
  name = "mutter-${version}";
  version = "3.31.92";

  src = fetchurl {
    url = "mirror://gnome/sources/mutter/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "1r77vfzmab4i99sq0a53igbiklyjhky3mig00mbc1gslmrbzsq38";
  };

  mesonFlags = [
    "-Dxwayland-path=${xwayland}/bin/Xwayland"
  ];

  propagatedBuildInputs = [
    # required for pkgconfig to detect mutter-clutter
    libXtst
  ];

  nativeBuildInputs = [
    meson
    pkgconfig
    gettext
    ninja
    makeWrapper
    python3
    # for cvt command
    xorgserver
  ];

  buildInputs = [
    glib gobject-introspection gtk3 gsettings-desktop-schemas upower
    gnome-desktop cairo pango cogl clutter zenity libstartup_notification
    geocode-glib libinput libgudev libwacom
    libcanberra-gtk3 zenity xkeyboard_config libxkbfile
    libxkbcommon pipewire xwayland
    gnome-settings-daemon
  ];

  postPatch = ''
    patchShebangs src/backends/native/gen-default-modes.py
  '';

  postInstall = ''
    ${glib.dev}/bin/glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  preFixup = ''
    wrapProgram "$out/bin/mutter" \
      --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  '';

  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "mutter";
      attrPath = "gnome3.mutter";
    };
  };

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
  };
}
