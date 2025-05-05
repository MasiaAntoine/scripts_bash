#!/bin/bash

# Fonction pour afficher l'aide
show_help() {
  echo "Utilisation des raccourcis depuis le terminal"
  echo "--------------------------------------------"
  echo "Ce script permet d'exécuter et gérer vos raccourcis macOS via la ligne de commande."
  echo ""
  echo "Options:"
  echo "  -r, --run NOM      Exécute le raccourci spécifié"
  echo "  -i, --input FICHIER  Spécifie un fichier d'entrée pour le raccourci"
  echo "  -o, --output FICHIER Spécifie un fichier de sortie pour le résultat"
  echo "  -l, --list         Liste tous les raccourcis disponibles"
  echo "  -f, --folder NOM   Liste les raccourcis dans un dossier spécifique"
  echo "  -v, --view NOM     Affiche le raccourci spécifié dans l'éditeur"
  echo "  -h, --help         Affiche cette aide"
  echo ""
  echo "Exemples:"
  echo "  $0 --run \"Combiner les images\" --input ~/Desktop/*.jpg --output ~/Desktop/combined.png"
  echo "  $0 --list --folder \"Musique\""
  echo "  $0 --view \"Conversion PDF\""
}

# Traitement des arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

ACTION=""
SHORTCUT_NAME=""
INPUT_FILES=""
OUTPUT_FILE=""
FOLDER_NAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--run)
      ACTION="run"
      SHORTCUT_NAME="$2"
      shift 2
      ;;
    -i|--input)
      INPUT_FILES="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT_FILE="$2"
      shift 2
      ;;
    -l|--list)
      ACTION="list"
      shift
      ;;
    -f|--folder)
      FOLDER_NAME="$2"
      shift 2
      ;;
    -v|--view)
      ACTION="view"
      SHORTCUT_NAME="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Option non reconnue: $1"
      show_help
      exit 1
      ;;
  esac
done

# Exécution de l'action demandée
case $ACTION in
  "run")
    if [ -z "$SHORTCUT_NAME" ]; then
      echo "Erreur: Nom de raccourci manquant"
      exit 1
    fi
    
    CMD="shortcuts run \"$SHORTCUT_NAME\""
    
    if [ ! -z "$INPUT_FILES" ]; then
      CMD="$CMD -i $INPUT_FILES"
    fi
    
    if [ ! -z "$OUTPUT_FILE" ]; then
      CMD="$CMD -o $OUTPUT_FILE"
    fi
    
    echo "Exécution: $CMD"
    eval $CMD
    
    if [ $? -eq 0 ]; then
      echo "Raccourci exécuté avec succès"
    else
      echo "Erreur lors de l'exécution du raccourci"
    fi
    ;;
    
  "list")
    if [ ! -z "$FOLDER_NAME" ]; then
      echo "Liste des raccourcis dans le dossier \"$FOLDER_NAME\":"
      shortcuts list -f "$FOLDER_NAME"
    else
      echo "Liste de tous les raccourcis disponibles:"
      shortcuts list
    fi
    ;;
    
  "view")
    if [ -z "$SHORTCUT_NAME" ]; then
      echo "Erreur: Nom de raccourci manquant"
      exit 1
    fi
    
    echo "Ouverture du raccourci \"$SHORTCUT_NAME\" dans l'éditeur"
    shortcuts view "$SHORTCUT_NAME"
    ;;
    
  *)
    echo "Action non reconnue. Utilisez --help pour afficher l'aide."
    exit 1
    ;;
esac

exit 0