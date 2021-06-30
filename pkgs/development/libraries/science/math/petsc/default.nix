{ lib, stdenv, darwin
, fetchurl, gfortran
, blas, lapack, python
, p4est, zlib, mpi
}:

let
  inherit (p4est) mpiSupport;
in
stdenv.mkDerivation rec {
  pname = "petsc";
  version = "3.14.2";

  src = fetchurl {
    url = "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz";
    sha256 = "04vy3qyakikslc58qyv8c9qrwlivix3w6znc993i37cvfg99dch9";
  };

  nativeBuildInputs = [ gfortran gfortran.cc.lib ];
  buildInputs = [ blas lapack python p4est ] ++ lib.optional mpiSupport mpi;

  # Upstream does some hot she-py-bang stuff, this change streamlines that
  # process. The original script in upstream is both a shell script and a
  # python script, where the shellscript just finds a suitable python
  # interpreter to execute the python script. See
  # https://github.com/NixOS/nixpkgs/pull/89299#discussion_r450203444
  # for more details.
  prePatch = ''
    substituteInPlace configure \
      --replace /bin/sh /usr/bin/python
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace config/install.py \
      --replace /usr/bin/install_name_tool ${darwin.cctools}/bin/install_name_tool
  '';

  preConfigure = ''
    export FC="${gfortran}/bin/gfortran" F77="${gfortran}/bin/gfortran"
    patchShebangs .
    configureFlagsArray=(
      $configureFlagsArray
      "--CC=${if mpiSupport then "mpicc" else "$CC"}"
      "--with-cxx=${if mpiSupport then "mpicxx" else "$CXX"}"
      "--with-fc=${if mpiSupport then "mpif90" else "$FC"}"
      "--with-mpi=${if mpiSupport then "1" else "0"}"
      "--with-blas-lib=[${blas}/lib/libblas.so,${gfortran.cc.lib}/lib/libgfortran.a]"
      "--with-lapack-lib=[${lapack}/lib/liblapack.so,${gfortran.cc.lib}/lib/libgfortran.a]"
      "--with-p4est=1"
      "--with-zlib-include=${zlib.dev}/include"
      "--with-zlib-lib=-L${zlib}/lib -lz"
    )
  '';

  enableParallelBuilding = true;
  inherit mpiSupport;

  meta = with lib; {
    description = "Linear algebra algorithms for solving partial differential equations";
    homepage = "https://www.mcs.anl.gov/petsc/index.html";
    license = licenses.bsd2;
    maintainers = with maintainers; [ wucke13 cburstedde ];
    platforms = platforms.all;
  };
}
