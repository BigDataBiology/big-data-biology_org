let
pkgs = let
  hostPkgs = import <nixpkgs> {};
  pinnedPkgs = hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "a1a8e7b0217fd6a72a5d008d8dfb3fdf8ba92e00";
    sha256 = "18xna03j2vp551f2x80w7y02865hvpmrppp5i6mxp2g36bldym6h";
  };
in import pinnedPkgs {};

envname = "big_data_biology_web";
jenv = pkgs.bundlerEnv {
  name = "jekyll_rbst_env";
  gemset = ./gemset.nix;
  gemfile = ./Gemfile;
  lockfile = ./Gemfile.lock;
 };

py27 = pkgs.python27.withPackages (pp: [
      pp.docutils
      pp.pygments
      ]);

in
pkgs.stdenv.mkDerivation {
  name = envname;

  buildInputs = with pkgs; [
    jenv
    bundler
    zsh
    py27
    awscli
    python3
    glibcLocales
  ];
  # When used as `nix-shell --pure`
  shellHook = ''
  export LC_ALL='en_US.UTF-8'
  export NIX_ENV="[${envname}] "
  '';
  # used when building environments
  extraCmds = ''
  export LC_ALL='en_US.UTF-8'
  export NIX_ENV="[${envname}] "
  '';

 }

