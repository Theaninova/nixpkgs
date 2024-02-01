{ lib
, stdenv
, cmake
, fetchFromGitHub
, git
, gmp
, perl
}:

stdenv.mkDerivation rec {
  pname = "lean4";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "lean4";
    rev = "v${version}";
    hash = "sha256-KTCTk4Fpbmm7FsUo03tAvenC6HuB3zJGax6iGTwLaXM=";
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace 'set(GIT_SHA1 "")' 'set(GIT_SHA1 "${src.rev}")'

    # Remove tests that fails in sandbox.
    # It expects `sourceRoot` to be a git repository.
    rm -rf src/lake/examples/git/
  '';

  preConfigure = ''
    patchShebangs stage0/src/bin/ src/bin/
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gmp
  ];

  nativeCheckInputs = [
    git
    perl
  ];

  cmakeFlags = [
    "-DUSE_GITHASH=OFF"
    "-DINSTALL_LICENSE=OFF"
  ];

  # Work around https://github.com/NixOS/nixpkgs/issues/166205.
  env = lib.optionalAttrs stdenv.cc.isClang {
    NIX_LDFLAGS = "-l${stdenv.cc.libcxx.cxxabi.libName}";
  };

  meta = with lib; {
    description = "Automatic and interactive theorem prover";
    homepage = "https://leanprover.github.io/";
    changelog = "https://github.com/leanprover/lean4/blob/${src.rev}/RELEASES.md";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ marsam ];
    mainProgram = "lean";
  };
}
