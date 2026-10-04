#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
ai_analyst.py — Analyse des alertes Wazuh par l'API Claude (Anthropic)

Lit le fichier d'alertes de Wazuh, en extrait les derniers événements de
sécurité, puis demande à l'API Claude un rapport d'analyse clair et synthétique.

SÉCURITÉ : la clé API n'est PAS écrite dans ce fichier.
Elle est lue depuis la variable d'environnement ANTHROPIC_API_KEY.

    export ANTHROPIC_API_KEY="votre_cle_api"     # Linux / macOS
    $env:ANTHROPIC_API_KEY = "votre_cle_api"     # Windows PowerShell

Dépendance :
    pip install anthropic
"""

import os
import sys
import json

# --- Configuration ---------------------------------------------------------
ALERTS_FILE = os.environ.get(
    "WAZUH_ALERTS_FILE", "/var/ossec/logs/alerts/alerts.json"
)
MODEL = "claude-sonnet-4-5"      # adapter au modèle disponible sur votre compte
MAX_ALERTS = 30                  # nombre d'alertes récentes à analyser


def load_alerts(path, limit):
    """Charge les dernières alertes depuis le fichier JSON-lines de Wazuh."""
    if not os.path.exists(path):
        print(f"[!] Fichier d'alertes introuvable : {path}")
        sys.exit(1)

    alerts = []
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                alerts.append(json.loads(line))
            except json.JSONDecodeError:
                continue  # ignore les lignes mal formées

    if not alerts:
        print("[i] Aucune alerte trouvée.")
        sys.exit(0)

    return alerts[-limit:]


def summarize(alert):
    """Extrait les champs utiles d'une alerte pour réduire la taille envoyée."""
    rule = alert.get("rule", {})
    return {
        "timestamp": alert.get("timestamp"),
        "agent": alert.get("agent", {}).get("name"),
        "rule_id": rule.get("id"),
        "level": rule.get("level"),
        "description": rule.get("description"),
        "src_ip": alert.get("data", {}).get("srcip"),
        "mitre": rule.get("mitre", {}).get("id"),
    }


def build_prompt(alerts):
    compact = [summarize(a) for a in alerts]
    data = json.dumps(compact, ensure_ascii=False, indent=2)
    return (
        "Tu es un analyste SOC. Voici les dernières alertes de sécurité "
        "remontées par le SIEM Wazuh (format JSON). Rédige un rapport clair "
        "en français qui :\n"
        "1. résume les événements marquants et leur gravité ;\n"
        "2. identifie les adresses IP suspectes et les types d'attaque ;\n"
        "3. propose des recommandations concrètes de remédiation.\n\n"
        f"Alertes :\n{data}"
    )


def main():
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("[!] Variable d'environnement ANTHROPIC_API_KEY non définie.")
        print('    Exemple : export ANTHROPIC_API_KEY="votre_cle_api"')
        sys.exit(1)

    try:
        import anthropic
    except ImportError:
        print("[!] Module 'anthropic' manquant. Installez-le : pip install anthropic")
        sys.exit(1)

    alerts = load_alerts(ALERTS_FILE, MAX_ALERTS)
    print(f"[i] {len(alerts)} alerte(s) chargée(s), analyse en cours...\n")

    client = anthropic.Anthropic(api_key=api_key)
    message = client.messages.create(
        model=MODEL,
        max_tokens=1024,
        messages=[{"role": "user", "content": build_prompt(alerts)}],
    )

    report = "".join(
        block.text for block in message.content if getattr(block, "type", "") == "text"
    )
    print(report)

    # Sauvegarde locale du rapport
    with open("rapport_soc.txt", "w", encoding="utf-8") as f:
        f.write(report)
    print("\n[+] Rapport enregistré dans rapport_soc.txt")


if __name__ == "__main__":
    main()
