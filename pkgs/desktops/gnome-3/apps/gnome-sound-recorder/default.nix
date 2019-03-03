{ stdenv, fetchurl, fetchpatch, pkgconfig, gettext, gobject-introspection, wrapGAppsHook, gjs, glib, gtk3, gdk_pixbuf, gst_all_1, gnome3
, meson, ninja, python3, hicolor-icon-theme }:

stdenv.mkDerivation rec {
  pname = "gnome-sound-recorder";
  version = "3.31.92";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1jmdqdrl1hkvqx3kp24cqzpag20mrw7ypnmlpn85i4yf0hc5il7h";
  };

  nativeBuildInputs = [
    pkgconfig gettext meson ninja gobject-introspection
    wrapGAppsHook python3 hicolor-icon-theme
  ];
  buildInputs = [ gjs glib gtk3 gdk_pixbuf ] ++ (with gst_all_1; [ gstreamer.dev gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad ]);

  patches = [
    ./fix-post-install.patch
  ];

  postPatch = ''
    chmod +x build-aux/meson_post_install.py
    patchShebangs build-aux/meson_post_install.py
  '';

  # TODO: fix this in gstreamer
  # TODO: make stdenv.lib.getBin respect outputBin
  PKG_CONFIG_GSTREAMER_1_0_TOOLSDIR = "${gst_all_1.gstreamer.dev}/bin";

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    description = "A simple and modern sound recorder";
    homepage = https://wiki.gnome.org/Apps/SoundRecorder;
    license = licenses.gpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.linux;
  };
}
