#!/usr/bin/env bash
set -euo pipefail

BRANCH=${1:-main}

echo "🔨 Construction du firmware Glove80 (branche: $BRANCH)"
echo ""

# Vérifier si zmk existe, sinon le cloner
if [ ! -d "./zmk" ]; then
    echo "📥 Clonage du repository moergo-sc/zmk..."
    git clone https://github.com/moergo-sc/zmk.git
    echo "✅ Repository cloné"
fi

# Aller dans le dossier zmk et checkout la branche
cd zmk
echo "🔄 Mise à jour et checkout de la branche $BRANCH..."
git fetch origin
git checkout -q --detach "$BRANCH"
cd ..

echo "🏗️  Construction du firmware..."
echo ""

# Construire le firmware
if nix-build ./config --arg firmware 'import ./zmk/default.nix {}' -j$(nproc) -o result --show-trace; then
    # Copier le fichier au lieu de créer un symlink
    cp result/glove80.uf2 ./glove80.uf2
    echo ""
    echo "✅ Firmware construit avec succès!"
    echo "📁 Fichier généré: $(realpath glove80.uf2)"
    echo "📊 Taille: $(du -h glove80.uf2 | cut -f1)"
    echo ""
    echo "Pour flasher votre Glove80:"
    echo "1. Mettez votre clavier en mode bootloader"
    echo "2. Copiez le fichier glove80.uf2 sur le lecteur USB qui apparaît"
else
    echo ""
    echo "❌ Échec de la construction du firmware"
    exit 1
fi