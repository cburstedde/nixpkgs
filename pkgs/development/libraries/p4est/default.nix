{ lib, stdenv, fetchgit
, which, gnum4, autoconf, automake, libtool, pkgconf
, p4est-sc
}:

let
  inherit (p4est-sc) debugEnable mpiSupport;
  dbg = if debugEnable then "-dbg" else "";
in
stdenv.mkDerivation {
  pname = "p4est${dbg}-prev3-develop";
  version = "2021-06-22";

  # fetch an untagged snapshot of the prev3-develop branch
  src = fetchgit {
    name = "p4est.git";
    url = "https://github.com/cburstedde/p4est.git";
    rev = "7423ac5f2b2b64490a7a92e5ddcbd251053c4dee";
    sha256 = "0am8mcxlkvvg7y52207cycwh78siq88j86mjn8fv6gxikg7j0498";
  };

  nativeBuildInputs = [
    which
    gnum4
    autoconf
    automake
    libtool
    pkgconf
  ];
  propagatedBuildInputs = [ p4est-sc ];
  inherit debugEnable mpiSupport;

  preConfigure = ''
    echo "2.8.0" > .tarball-version
    ./bootstrap
    ${if mpiSupport then "unset CC" else ""}
  '';

  configureFlags = [ "--with-sc=${p4est-sc}" ]
    ++ lib.optional debugEnable "--enable-debug"
    ++ lib.optional mpiSupport "--enable-mpi"
  ;

  makeFlags = [ "V=0" ];

  dontDisableStatic = true;
  enableParallelBuilding = true;
  doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

  meta = {
    branch = "prev3-develop";
    description = "Parallel AMR on Forests of Octrees";
    longDescription = ''
      The p4est software library provides algorithms for parallel AMR.
      AMR refers to Adaptive Mesh Refinement, a technique in scientific
      computing to cover the domain of a simulation with an adaptive mesh.
    '';
    homepage = https://www.p4est.org/;
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
