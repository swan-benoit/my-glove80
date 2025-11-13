{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    git
    nix
    cachix
  ];

  shellHook = ''
    # Configuration pour utiliser le cache moergo-glove80-zmk-dev
    if ! cachix list | grep -q "moergo-glove80-zmk-dev"; then
      echo "Configuration du cache Cachix pour moergo-glove80-zmk-dev..."
      cachix use moergo-glove80-zmk-dev
    fi

    # Cloner le repository ZMK si nécessaire
    if [ ! -d "./zmk" ]; then
      echo "Clonage du repository moergo-sc/zmk..."
      git clone https://github.com/moergo-sc/zmk.git
    fi

    echo "Environnement de développement Glove80 prêt!"
    echo "Pour builder le firmware:"
    echo "  ./build-local.sh [branch]"
    echo ""
    echo "Ou manuellement:"
    echo "  cd zmk && git checkout main"
    echo "  nix-build ./config --arg firmware 'import ./zmk/default.nix {}' -o glove80.uf2"
  '';
}