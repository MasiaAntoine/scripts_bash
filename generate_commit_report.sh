#!/bin/bash
BASE_DIR="/Users/antoine/Documents/projet/"
OUTPUT_FILE="/Users/antoine/scripts_bash/gerenate_done.txt"
IA_OUTPUT_FILE="/Users/antoine/scripts_bash/gerenate_done_ai.txt"

IGNORED_PROJECTS=(
    "wallet"
)

> "$OUTPUT_FILE"
> "$IA_OUTPUT_FILE"
function choose_day {
    echo "Sélectionnez la période de génération des commits :"
    echo "1) Aujourd'hui (défaut)"
    echo "2) Hier"
    for i in {2..7}; do
        day_name=$(date -v-"$i"d +"%A")
        day_date=$(date -v-"$i"d +"%d %b")
        echo "$(($i+1))) $day_name - $day_date"
    done
    read -p "Choix (appuyez sur Entrée pour aujourd'hui): " choice
    choice=${choice:-1}
    if [[ $choice -eq 1 ]]; then
        since="midnight"
        selected_date=$(date +"%d %b %Y")
    else
        days_ago=$((choice - 1))
        since="$days_ago days ago"
        selected_date=$(date -v-"$days_ago"d +"%d %b %Y")
    fi
}
choose_day
read -p "Ajoutez des tâches supplémentaires pour cette journée (laisser vide si aucune) : " extra_tasks

projects=($(ls -d "$BASE_DIR"*/ | xargs -n 1 basename))
echo "$selected_date" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
if [[ -n "$extra_tasks" ]]; then
    echo "【 TÂCHES SUPPLÉMENTAIRES 】" >> "$OUTPUT_FILE"
    echo "  ▪︎  $extra_tasks" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

for project in "${projects[@]}"; do
    # Vérifier si le projet est dans la liste des projets ignorés
    should_ignore=false
    for ignored in "${IGNORED_PROJECTS[@]}"; do
        if [ "$project" = "$ignored" ]; then
            should_ignore=true
            break
        fi
    done

    if [ "$should_ignore" = true ]; then
        continue
    fi

    REPO_DIR="$BASE_DIR$project"
    if [ -d "$REPO_DIR/.git" ]; then
        cd "$REPO_DIR" || { exit 1; }
        current_branch=$(git rev-parse --abbrev-ref HEAD)
        git stash -u >/dev/null 2>&1
        commits=$(git log --author="$(git config user.name)" --since="$since" --oneline --reverse)
        if [ -n "$commits" ]; then
            UPPER_PROJECT=$(echo "$project" | tr '[:lower:]' '[:upper:]')
            echo "【 $UPPER_PROJECT 】" >> "$OUTPUT_FILE"
            echo "$commits" | awk '{$1=""; print "  ▪︎  " $0}' >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
        fi
        git checkout "$current_branch" >/dev/null 2>&1
        git stash pop >/dev/null 2>&1
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "Génération du résumé IA avec Ollama..."

REPORT_CONTENT=$(cat "$OUTPUT_FILE")
AI_REQUEST="Tu es un assistant chargé de rédiger un compte rendu de travail à partir de commits Git.
Instructions :
Tu répondras en Français.
Écris directement le message, sans phrases de politesse inutiles, sans introduction ou conclusion.
Formate chaque projet en majuscules et en gras.
Formate le résumé de chaque projet en utilisant des puces (▪).
Ajoute la date en début de compte rendu.
Inclut les tâches supplémentaires mentionnées par l'utilisateur.
Regroupe les commits par projet si cela a du sens.
Voici les commits et tâches supplémentaires à résumer :
$REPORT_CONTENT
"
if [[ -s "$OUTPUT_FILE" ]]; then
    if ! command -v ollama &> /dev/null; then
        echo ":x: Ollama n'est pas installé. Ignorer la génération IA."
        exit 1
    fi
    AI_RESPONSE=$(echo "$AI_REQUEST" | ollama run mistral)
    ollama run mistral <<< "/bye" &> /dev/null
else
    AI_RESPONSE="Aucun commit à résumer."
fi
echo "$REPORT_CONTENT" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
# echo "=====================" >> "$IA_OUTPUT_FILE"
# echo ":épingle: RÉSUMÉ AI" >> "$IA_OUTPUT_FILE"
# echo "=====================" >> "$IA_OUTPUT_FILE"
printf "%s\n" "$AI_RESPONSE" >> "$IA_OUTPUT_FILE"
# echo "=====================" >> "$IA_OUTPUT_FILE"

open "$IA_OUTPUT_FILE"