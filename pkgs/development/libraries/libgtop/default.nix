{ stdenv, fetchurl, fetchpatch, glib, pkgconfig, perl, gettext, gobject-introspection, libtool, gnome3, gtk-doc }:
let
  pname = "libgtop";
  version = "2.39.91";
in
stdenv.mkDerivation rec {
  name = "${pname}-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${name}.tar.xz";
    sha256 = "03qz4wag711s152kvfiq80qwqcxpxk09rwmxyzbp59c03j8f6a1l";
  };

  propagatedBuildInputs = [ glib ];
  nativeBuildInputs = [ pkgconfig gnome3.gnome-common libtool gtk-doc perl gettext gobject-introspection ];

  preConfigure = ''
    ./autogen.sh
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    description = "A library that reads information about processes and the running system";
    license = licenses.gpl2Plus;
    maintainers = gnome3.maintainers;
    platforms = platforms.unix;
  };
}
