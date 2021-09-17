{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, p4est-sc-debugEnable ? true, p4est-sc-mpiSupport ? true
, mpi, openssh, zlib
}:

let
  dbg = if debugEnable then "-dbg" else "";
  debugEnable = p4est-sc-debugEnable;
  mpiSupport = p4est-sc-mpiSupport;
  isOpenmpi = mpiSupport && mpi.pname == "openmpi";
in
stdenv.mkDerivation {
  pname = "p4est-sc${dbg}";
  version = "unstable-2021-09-17";

  # fetch an untagged snapshot of the prev3-develop branch
  src = fetchFromGitHub {
    owner = "cburstedde";
    repo = "libsc";
    rev = "1d8ab1397cec48c71f86eaca726e1d56a2bc49a7";
    sha256 = "01l08cgfwm30l19v00c5zrkiqd548ag8iylhxk7x1m9aad1aa15h";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  propagatedBuildInputs = [ zlib ]
    ++ lib.optional mpiSupport mpi
    ++ lib.optional isOpenmpi openssh
  ;
  inherit debugEnable mpiSupport;

  preConfigure = ''
    echo "2.8.0" > .tarball-version
    ${if mpiSupport then "unset CC" else ""}
  '';

  configureFlags = [ "--enable-pthread=-pthread" ]
    ++ lib.optional debugEnable "--enable-debug"
    ++ lib.optional mpiSupport "--enable-mpi"
  ;

  dontDisableStatic = true;
  enableParallelBuilding = true;
  makeFlags = [ "V=0" ];

  preCheck = ''
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export HYDRA_IFACE=lo
  '';

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
    downloadPage = "https://github.com/cburstedde/libsc.git";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
