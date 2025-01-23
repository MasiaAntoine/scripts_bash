#!/bin/bash

# Chemin où sont situés tous les projets
BASE_DIR="/Users/antoine/Documents/projet/"

# Liste des projets
projects=("native-app-shopper" "board-admin" "flashpage" "board-keeper")

# Chemin du fichier texte à créer sur le bureau
OUTPUT_FILE="/Users/antoine/scripts_bash/gerenate_done.txt"

# Vider le fichier avant d'y écrire
> "$OUTPUT_FILE"

# Fonction pour demander la période (Aujourd'hui, Hier, etc. avec les jours de la semaine et dates)
function choose_day {
    echo "Sélectionnez la période de génération des commits :"
    echo "1) Aujourd'hui (défaut)"
    echo "2) Hier"
    for i in {2..7}; do
        day_name=$(date -v-"$i"d +"%A")  # Nom du jour
        day_date=$(date -v-"$i"d +"%d %b")  # Date au format 'jour mois'
        echo "$(($i+1))) $day_name - $day_date"
    done

    # Lire la sélection de l'utilisateur avec la valeur par défaut (1)
    read -p "Choix (appuyez sur Entrée pour aujourd'hui): " choice
    choice=${choice:-1}  # Défaut à 1 si rien n'est sélectionné

    case $choice in
        1) since="midnight"; selected_date=$(date +"%d %b %Y") ;;
        2) since="yesterday"; selected_date=$(date -v-1d +"%d %b %Y") ;;
        3) since="2 days ago"; selected_date=$(date -v-2d +"%d %b %Y") ;;
        4) since="3 days ago"; selected_date=$(date -v-3d +"%d %b %Y") ;;
        5) since="4 days ago"; selected_date=$(date -v-4d +"%d %b %Y") ;;
        6) since="5 days ago"; selected_date=$(date -v-5d +"%d %b %Y") ;;
        7) since="6 days ago"; selected_date=$(date -v-6d +"%d %b %Y") ;;
        8) since="7 days ago"; selected_date=$(date -v-7d +"%d %b %Y") ;;
        *) since="midnight"; selected_date=$(date +"%d %b %Y") ;;
    esac

    echo "Génération des commits depuis : $since."
}

# Appeler la fonction pour choisir le jour
choose_day

# Ajouter la date sélectionnée au début du fichier
echo "$selected_date" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Parcourir chaque projet
for project in "${projects[@]}"; do
    # Se déplacer dans le répertoire du projet
    REPO_DIR="$BASE_DIR$project"

    # Vérifier si le répertoire est un dépôt Git
    if [ -d "$REPO_DIR/.git" ]; then
        cd "$REPO_DIR" || { echo "Le répertoire n'existe pas."; exit 1; }

        # Sauvegarder la branche courante
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        # Sauvegarder les modifications locales non commités (si nécessaire)
        git stash -u >/dev/null 2>&1

        # Lister toutes les branches locales
        branches=$(git branch --all | grep -v "remotes" | sed 's/*//')

        # Variable pour savoir si le projet a des commits
        has_commits=false

        # Pour chaque branche, afficher les commits faits selon la période sélectionnée
        for branch in $branches; do
            # Se déplacer sur la branche
            git checkout "$branch" >/dev/null 2>&1

            # Récupérer les commits selon la période sélectionnée
            commits=$(git log --author="$(git config user.name)" --since="$since" --oneline --reverse)

            if [ -n "$commits" ]; then
                # Si des commits ont été trouvés, marquer que le projet a des commits
                if [ "$has_commits" = false ]; then
                    # Convertir le nom du projet en majuscules et formater
                    UPPER_PROJECT=$(echo "$project" | tr '[:lower:]' '[:upper:]')
                    echo "【 $UPPER_PROJECT 】" >> "$OUTPUT_FILE"
                    has_commits=true
                fi

                # Afficher la branche et les messages de commit formatés
                echo "➤ $branch" >> "$OUTPUT_FILE"
                echo "$commits" | awk '{$1=""; print "  ▪︎  " $0}' >> "$OUTPUT_FILE"
            fi
        done

        if [ "$has_commits" = true ]; then
            echo "" >> "$OUTPUT_FILE"  # Séparer les projets avec une ligne vide
            echo "" >> "$OUTPUT_FILE"  # Séparer les projets avec une ligne vide
        fi

        # Revenir à la branche initiale
        git checkout "$current_branch" >/dev/null 2>&1

        # Restaurer les modifications locales sauvegardées
        git stash pop >/dev/null 2>&1
    else
        echo "Le répertoire $project n'est pas un dépôt Git." >> "$OUTPUT_FILE"
    fi
done

# Ouvrir le fichier texte après l'avoir créé
open "$OUTPUT_FILE"
