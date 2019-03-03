{ stdenv, meson, fetchurl, python3
, pkgconfig, gtk3, glib, adwaita-icon-theme
, libpeas, gtksourceview4, gsettings-desktop-schemas
, wrapGAppsHook, ninja, libsoup, libxml2
, gnome3, gspell, perl, itstool }:

stdenv.mkDerivation rec {
  name = "gedit-${version}";
  version = "3.31.92";

  src = fetchurl {
    url = "mirror://gnome/sources/gedit/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "1sbwxcrqpghfkkkim9idpj13xha5f5j7xysxc07vsd3356vy7gkc";
  };

  nativeBuildInputs = [
    pkgconfig wrapGAppsHook meson ninja libxml2
    python3 perl itstool
  ];

  buildInputs = [
    gtk3 glib
    adwaita-icon-theme libsoup
    libpeas gtksourceview4
    gsettings-desktop-schemas gspell
  ];

  patches = [
    # Do not update desktop database
    ./block-update-desktop.patch
  ];

  postPatch = ''
    chmod +x build-aux/meson/post_install.py
    chmod +x plugins/externaltools/scripts/gedit-tool-merge.pl
    patchShebangs build-aux/meson/post_install.py
    patchShebangs plugins/externaltools/scripts/gedit-tool-merge.pl
  '';

  mesonFlags = [
    "--buildtype=plain" # don't require git
  ];

  # Reliably fails to generate gedit-file-browser-enum-types.h in time
  enableParallelBuilding = false;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = "gedit";
      attrPath = "gnome3.gedit";
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Apps/Gedit;
    description = "Official text editor of the GNOME desktop environment";
    maintainers = gnome3.maintainers;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
