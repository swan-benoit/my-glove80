# Environnement de développement local

Ce projet inclut maintenant un environnement de développement Nix qui vous permet de builder le firmware localement, exactement comme l'image Docker.

## Prérequis

- Nix installé avec flakes activés
- Cachix installé (optionnel mais recommandé pour la vitesse)

## Utilisation

### Méthode 1: Avec Nix Flakes (recommandé)

```bash
# Entrer dans l'environnement de développement
nix develop

# Builder le firmware (branche main par défaut)
build-glove80

# Builder une branche spécifique
build-glove80 dev
```

### Méthode 2: Avec shell.nix traditionnel

```bash
# Entrer dans l'environnement
nix-shell

# Builder avec le script fourni
./build-local.sh

# Ou builder une branche spécifique
./build-local.sh dev
```

### Méthode 3: Build direct avec Nix

```bash
# Builder directement le package
nix build

# Le firmware sera dans result/glove80.uf2
```

## Fonctionnement

L'environnement de développement :

1. Configure automatiquement le cache Cachix `moergo-glove80-zmk-dev` pour des builds plus rapides
2. Clone le repository ZMK officiel de MoErgo (`moergo-sc/zmk`) si nécessaire
3. Utilise la même configuration Nix que l'image Docker
4. Produit exactement le même firmware que le build Docker

## Avantages par rapport au Docker

- Plus rapide (pas de overhead de conteneur)
- Intégration native avec votre environnement de développement
- Partage du cache Nix entre différents projets
- Possibilité de modifier facilement la configuration de build

## Structure des fichiers

- `flake.nix` - Configuration moderne avec Nix Flakes
- `shell.nix` - Configuration compatible legacy Nix
- `build-local.sh` - Script de build simple à utiliser
- Repository `zmk/` - Sera cloné automatiquement au premier build