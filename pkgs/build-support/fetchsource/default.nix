{ lib, pkgs, python3, nix-prefetch-scripts }:
with pkgs;
stdenv.mkDerivation {
  name = "nix-prefetch-source";
  buildInputs = [ makeWrapper ];
  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${./nix-prefetch-source} $out/bin/nix-prefetch-source \
      --prefix PATH : ${python3}/bin \
      --prefix PATH : ${nix-prefetch-scripts}/bin \
    ;
  '';
  passthru = {
    import = path:
      let
        json = lib.importJSON path;
        fetchFunction = builtins.getAttr json.type pkgs;
        src = fetchFunction json.fetchArgs;
      in
      json // { inherit src; };
  };
  meta = {
    maintainers = with maintainers; [ timbertson ];
  };
}
