{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, p4est, p4est-sc
}:

assert p4est.debugEnable == p4est-sc.debugEnable;
assert p4est.mpiSupport == p4est-sc.mpiSupport;

let
  inherit (p4est-sc) debugEnable mpiSupport;
  dbg = if debugEnable then "-dbg" else "";
in
stdenv.mkDerivation {
  pname = "t8${dbg}";
  version = "unstable-2021-09-20";

  # fetch an untagged snapshot of the test-prev3 branch
  src = fetchFromGitHub {
    owner = "cburstedde";
    repo = "t8code";
    rev = "35ab1dab4e84a2c5fb9660472ddab3c14ca0881b";
    sha256 = "17d4m387sm0bragrzm4n932d3hyz4y0i5j19z6m4wzb2ka99djdl";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  propagatedBuildInputs = [ p4est ];
  inherit debugEnable mpiSupport;

  preConfigure = ''
    echo "2.8.0" > .tarball-version
    ${if mpiSupport then "unset CC" else ""}
    ${if mpiSupport then "unset CXX" else ""}
  '';

  configureFlags = p4est-sc.configureFlags
    ++ [ "--with-sc=${p4est-sc}" ]
    ++ [ "--with-p4est=${p4est}" ]
  ;

  inherit (p4est-sc) makeFlags dontDisableStatic enableParallelBuilding preCheck doCheck;

  meta = {
    branch = "test-prev3";
    description = "Hybrid parallel AMR on space trees";
    longDescription = ''
      t8code (spoken "tetcode") is a C/C++ library to manage parallel adaptive
      meshes with various element types.  t8code uses a collection (a forest)
      of multiple connected adaptive space-trees in parallel and scales to at
      least one million MPI ranks and over 1 trillion mesh elements.
    '';
    homepage = "https://github.com/holke/t8code.git";
    downloadPage = "https://github.com/cburstedde/p4est.git";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
