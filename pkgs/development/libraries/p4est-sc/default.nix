{ lib, stdenv, fetchgit
, autoreconfHook, pkg-config
, p4est-sc-debugEnable ? true, p4est-sc-mpiSupport ? true
, mpi ? null, openmpi ? null, openssh ? null, zlib
}:

# we prefer MPICH over OpenMPI; call accordingly
assert p4est-sc-mpiSupport -> mpi != null;
assert p4est-sc-mpiSupport && mpi == openmpi -> openssh != null;

let
  dbg = if debugEnable then "-dbg" else "";
  debugEnable = p4est-sc-debugEnable;
  mpiSupport = p4est-sc-mpiSupport;
in
stdenv.mkDerivation {
  pname = "p4est-sc${dbg}-prev3-develop";
  version = "2021-06-14";

  # fetch an untagged snapshot of the prev3-develop branch
  src = fetchgit {
    name = "p4est-sc.git";
    url = "https://github.com/cburstedde/libsc.git";
    rev = "1ae814e3fb1cc5456652e0d77550386842cb9bfb";
    sha256 = "14vm0b162jh8399pgpsikbwq4z5lkrw9vfzy3drqykw09n6nc53z";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  propagatedBuildInputs = [ zlib ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional (mpiSupport && mpi == openmpi) openssh
  ;
  inherit debugEnable mpiSupport;

  postPatch = ''
    echo "dist_scaclocal_DATA += config/sc_v4l2.m4" >> Makefile.am
  '';
  preConfigure = ''
    echo "2.8.0" > .tarball-version
    ${if mpiSupport then "unset CC" else ""}
  '';

  configureFlags = [ ]
    ++ lib.optional debugEnable "--enable-debug"
    ++ lib.optional mpiSupport "--enable-mpi"
  ;

  makeFlags = [ "V=0" ];

  dontDisableStatic = true;
  enableParallelBuilding = true;
  doCheck = stdenv.hostPlatform == stdenv.buildPlatform;

  meta = {
    branch = "prev3-develop";
    description = "Support for parallel scientific applications";
    longDescription = ''
      The SC library provides support for parallel scientific applications.
      Its main purpose is to support the p4est software library, hence
      this package is called p4est-sc, but it works standalone, too.
    '';
    homepage = "https://www.p4est.org/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
