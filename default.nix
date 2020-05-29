{ pkgs ? import <nixpkgs> {}, name, main, assets ? [], fonts ? [] }:
let
  inherit (pkgs) stdenv;
  texlive = (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-full; });
  fontsConf = pkgs.makeFontsConf { fontDirectories = fonts; };
in
stdenv.mkDerivation {
  name = name;

  buildInputs = [texlive];
  srcs = [main] ++ assets;

  dontConfigure = true;
  unpackPhase = ''
    for _src in $srcs; do
      cp "$_src" $(stripHash "$_src")
    done
  '';

  preBuild = ''
    export FONTCONFIG_FILE="${fontsConf}"
    export main="$(stripHash ${main})"
  '';
  buildPhase = ''
    runHook preBuild
    xelatex -jobname="${name}" "$main"
  '';

  installPhase = ''
    mkdir -p $out 
    cp *.pdf $out
  '';
}
