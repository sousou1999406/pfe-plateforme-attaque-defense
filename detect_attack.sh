#!/bin/bash
# =============================================================
# detect_attack.sh — Détection des adresses IP suspectes
# -------------------------------------------------------------
# Analyse le journal d'authentification et signale toute adresse
# IP ayant dépassé un seuil de tentatives de connexion échouées.
# (Détection uniquement — aucun blocage n'est effectué ici.)
#
# Usage : sudo ./detect_attack.sh
# =============================================================

LOGFILE="/var/log/auth.log"   # journal SSH (Debian/Ubuntu)
THRESHOLD=3                    # seuil de tentatives échouées

if [ ! -f "$LOGFILE" ]; then
    echo "[!] Fichier journal introuvable : $LOGFILE"
    exit 1
fi

echo "=== Détection des tentatives de connexion échouées ==="
echo "Seuil d'alerte : $THRESHOLD tentatives"
echo

# grep -oE (compatible anciennes versions) au lieu de grep -oP
grep "Failed password" "$LOGFILE" \
  | grep -oE 'from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' \
  | awk '{print $2}' \
  | sort | uniq -c | sort -rn \
  | while read count ip; do
        if [ "$count" -ge "$THRESHOLD" ]; then
            echo "[ALERTE] $ip → $count tentatives échouées"
        fi
    done

echo
echo "Analyse terminée."
