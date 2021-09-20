{ lib, stdenv, fetchFromGitHub
, autoreconfHook, pkg-config
, p4est-withMetis ? true, metis
, p4est-sc
}:

let
  inherit (p4est-sc) debugEnable mpiSupport;
  dbg = if debugEnable then "-dbg" else "";
  withMetis = p4est-withMetis;
in
stdenv.mkDerivation {
  pname = "p4est${dbg}";
  version = "unstable-2021-09-20";

  # fetch an untagged snapshot of the prev3-develop branch
  src = fetchFromGitHub {
    owner = "cburstedde";
    repo = "p4est";
    rev = "f4f46e595bcdb55b9b81b95700e7fba2538c38e0";
    sha256 = "09gjl4mb8fflqqcj0335swvmvkccpc7myjc22msh590lvh35f284";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  propagatedBuildInputs = [ p4est-sc ];
  buildInputs = lib.optional withMetis metis;
  inherit debugEnable mpiSupport withMetis;

  preConfigure = ''
    echo "2.8.0" > .tarball-version
    ${if mpiSupport then "unset CC" else ""}
  '';

  configureFlags = p4est-sc.configureFlags
    ++ [ "--with-sc=${p4est-sc}" ]
    ++ lib.optional withMetis "--with-metis"
  ;

  inherit (p4est-sc) makeFlags dontDisableStatic enableParallelBuilding preCheck doCheck;

  meta = {
    branch = "prev3-develop";
    description = "Parallel AMR on Forests of Octrees";
    longDescription = ''
      The p4est software library provides algorithms for parallel AMR.
      AMR refers to Adaptive Mesh Refinement, a technique in scientific
      computing to cover the domain of a simulation with an adaptive mesh.
    '';
    homepage = "https://www.p4est.org/";
    downloadPage = "https://github.com/cburstedde/p4est.git";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.cburstedde ];
  };
}
