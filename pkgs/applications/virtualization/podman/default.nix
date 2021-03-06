{ stdenv, fetchFromGitHub, pkgconfig
, buildGoPackage, gpgme, lvm2, btrfs-progs, libseccomp
, go-md2man
}:

buildGoPackage rec {
  name = "podman-${version}";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "libpod";
    rev = "v${version}";
    sha256 = "180sv1a7k3866ilb0mxbhiysms9xy4v6xbpy4in6ch8m8qym9amh";
  };

  goPackagePath = "github.com/containers/libpod";

  outputs = [ "bin" "out" "man" ];

  # Optimizations break compilation of libseccomp c bindings
  hardeningDisable = [ "fortify" ];
  nativeBuildInputs = [ pkgconfig go-md2man ];

  buildInputs = [
    btrfs-progs libseccomp gpgme lvm2
  ];

  buildPhase = ''
    pushd $NIX_BUILD_TOP/go/src/${goPackagePath}
    patchShebangs .
    make binaries docs
  '';

  installPhase = ''
    install -Dm555 bin/podman $bin/bin/podman
    MANDIR=$man/share/man make install.man
  '';

  meta = with stdenv.lib; {
    homepage = https://podman.io/;
    description = "A program for managing pods, containers and container images";
    license = licenses.asl20;
    maintainers = with maintainers; [ vdemeester ];
    platforms = platforms.linux;
  };
}
