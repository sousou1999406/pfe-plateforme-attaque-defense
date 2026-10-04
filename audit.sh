#!/bin/bash
# =============================================================
# audit.sh — Audit de sécurité du système
# -------------------------------------------------------------
# Dresse un inventaire rapide de l'état du système :
#   - ports en écoute
#   - utilisateurs et comptes privilégiés
#   - fichiers sensibles (SUID)
#
# Usage : sudo ./audit.sh
# =============================================================

echo "###############################################"
echo "#            AUDIT DE SÉCURITÉ                #"
echo "#   $(date)"
echo "###############################################"

echo
echo "=== 1. Ports en écoute ==="
if command -v ss >/dev/null 2>&1; then
    ss -tulnp
else
    netstat -tulnp
fi

echo
echo "=== 2. Utilisateurs du système (/etc/passwd) ==="
cut -d: -f1,3,7 /etc/passwd

echo
echo "=== 3. Comptes avec privilèges root (UID = 0) ==="
awk -F: '$3 == 0 {print $1}' /etc/passwd

echo
echo "=== 4. Fichiers avec bit SUID (exécution privilégiée) ==="
find / -perm -4000 -type f 2>/dev/null

echo
echo "=== 5. Dernières connexions ==="
last -n 10 2>/dev/null

echo
echo "Audit terminé."
