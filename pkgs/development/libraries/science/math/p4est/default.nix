{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, p4est-sc
}:

let
  inherit (p4est-sc) debugEnable mpiSupport;
  dbg = if debugEnable then "-dbg" else "";
in
stdenv.mkDerivation {
  pname = "p4est${dbg}";
  version = "unstable-2021-06-22";

  # fetch an untagged snapshot of the prev3-develop branch
  src = fetchFromGitHub {
    # url = "https://github.com/cburstedde/p4est.git";
    owner = "cburstedde";
    repo = "p4est.git";
    name = "p4est.git";
    rev = "7423ac5f2b2b64490a7a92e5ddcbd251053c4dee";
    sha256 = "0vffnf48rzw6d0as4c3x1f31b4kapmdzr1hfj5rz5ngah72gqrph";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  propagatedBuildInputs = [ p4est-sc ];
  inherit debugEnable mpiSupport;

  postPatch = ''
    sed -i -e "s:\(^\s*ACLOCAL_AMFLAGS.*\)\s@P4EST_SC_AMFLAGS@\s*$:\1 -I ${p4est-sc}/share/aclocal:" Makefile.am
  '';
  preConfigure = ''
    echo "2.8.0" > .tarball-version
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
    homepage = "https://www.p4est.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
