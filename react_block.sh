#!/bin/bash
# =============================================================
# react_block.sh — Blocage automatique des adresses IP suspectes
# -------------------------------------------------------------
# Analyse le journal d'authentification et bloque, via iptables,
# toute IP ayant dépassé le seuil de tentatives échouées.
# Évite d'ajouter une règle en double pour une IP déjà bloquée.
#
# Usage : sudo ./react_block.sh
# =============================================================

LOGFILE="/var/log/auth.log"
THRESHOLD=3

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Ce script doit être exécuté en root (sudo)."
    exit 1
fi

if [ ! -f "$LOGFILE" ]; then
    echo "[!] Fichier journal introuvable : $LOGFILE"
    exit 1
fi

echo "=== Blocage automatique des IP suspectes ==="

grep "Failed password" "$LOGFILE" \
  | grep -oE 'from [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' \
  | awk '{print $2}' \
  | sort | uniq -c \
  | while read count ip; do
        if [ "$count" -ge "$THRESHOLD" ]; then
            # Vérifier si une règle existe déjà pour cette IP
            if iptables -C INPUT -s "$ip" -j DROP 2>/dev/null; then
                echo "[INFO] $ip déjà bloquée."
            else
                iptables -A INPUT -s "$ip" -j DROP
                echo "[BLOCAGE] $ip bloquée ($count tentatives)."
            fi
        fi
    done

echo
echo "Règles actuelles :"
iptables -L INPUT -n --line-numbers | grep DROP
