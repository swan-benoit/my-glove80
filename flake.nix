{
  description = "Glove80 ZMK firmware development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Script pour builder le firmware
        buildScript = pkgs.writeShellScriptBin "build-glove80" ''
          set -euo pipefail
          BRANCH=''${1:-main}
          
          echo "Checkout de la branche $BRANCH depuis moergo-sc/zmk"
          
          if [ ! -d "./zmk" ]; then
            echo "Clonage du repository moergo-sc/zmk..."
            git clone https://github.com/moergo-sc/zmk.git
          fi
          
          cd zmk
          git fetch origin
          git checkout -q --detach "$BRANCH"
          cd ..
          
          echo "Construction du firmware Glove80..."
          nix-build ./config --arg firmware 'import ./zmk/default.nix {}' -j$(nproc) -o glove80.uf2 --show-trace
          
          echo "Firmware construit avec succès: glove80.uf2"
        '';
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            nix
            cachix
            buildScript
          ];

          shellHook = ''
            # Configuration pour utiliser le cache moergo-glove80-zmk-dev
            if ! cachix list 2>/dev/null | grep -q "moergo-glove80-zmk-dev"; then
              echo "Configuration du cache Cachix pour moergo-glove80-zmk-dev..."
              cachix use moergo-glove80-zmk-dev || echo "Attention: échec de configuration du cache Cachix"
            fi

            echo "🔨 Environnement de développement Glove80 prêt!"
            echo ""
            echo "Pour builder le firmware:"
            echo "  build-glove80 [branch]  # (défaut: main)"
            echo ""
            echo "Exemple:"
            echo "  build-glove80           # Build la branche main" 
            echo "  build-glove80 dev       # Build la branche dev"
            echo ""
          '';
        };

        # Package pour builder le firmware directement
        packages.default = pkgs.stdenv.mkDerivation {
          name = "glove80-firmware";
          src = ./.;
          
          buildInputs = with pkgs; [ git nix cachix ];
          
          buildPhase = ''
            export HOME=$TMPDIR
            
            # Configuration Cachix
            cachix use moergo-glove80-zmk-dev || true
            
            # Clone ZMK si pas déjà fait
            if [ ! -d "./zmk" ]; then
              git clone https://github.com/moergo-sc/zmk.git
            fi
            
            cd zmk
            git checkout main
            cd ..
            
            # Build le firmware
            nix-build ./config --arg firmware 'import ./zmk/default.nix {}' -o result
          '';
          
          installPhase = ''
            mkdir -p $out
            cp result/glove80.uf2 $out/
          '';
        };
      });
}