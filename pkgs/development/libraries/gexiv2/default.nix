{ stdenv, fetchurl, meson, ninja, pkgconfig, exiv2, glib, gnome3, gobject-introspection, vala, gtk-doc, docbook_xsl, docbook_xml_dtd_43 }:

stdenv.mkDerivation rec {
  pname = "gexiv2";
  version = "0.11.0";

  outputs = [ "out" "dev" "devdoc" ];

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${stdenv.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "1v042jvbgw739fjz8qdlad4ys2v01i21j7nnbzgfcdwf3hggfzsc";
  };

  nativeBuildInputs = [ meson ninja pkgconfig gobject-introspection vala gtk-doc docbook_xsl docbook_xml_dtd_43 ];
  buildInputs = [ glib ];
  propagatedBuildInputs = [ exiv2 ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
    };
  };

  meta = with stdenv.lib; {
    homepage = https://wiki.gnome.org/Projects/gexiv2;
    description = "GObject wrapper around the Exiv2 photo metadata library";
    license = licenses.gpl2;
    platforms = platforms.unix;
    maintainers = gnome3.maintainers;
  };
}
