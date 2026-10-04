# Plateforme de simulation Attaque / Défense sous Unix

Projet de Fin d'Études — conception et mise en œuvre d'une plateforme isolée
permettant de reproduire un scénario réaliste **d'attaque** et de **défense**,
d'analyser les traces laissées dans les journaux et d'automatiser la détection
et la réaction face aux attaques à l'aide d'un **SIEM (Wazuh)**.

> **Auteure :** Soukaina DOUAZI — HESTIM Engineering & Business School
> **Encadrement :** Mme Asmae HMAMI — Année universitaire 2025 / 2026

---

## 🎯 Objectifs

- Simuler des attaques réelles : reconnaissance réseau, brute force, exploitation de services vulnérables.
- Analyser les traces (logs) générées par ces attaques sur la machine victime.
- Mettre en place des mécanismes de défense : pare-feu, durcissement des services, Fail2ban.
- Automatiser la détection et la réaction via une solution SIEM (Wazuh).

---

## 🖥️ Architecture de la plateforme

Trois machines virtuelles interconnectées sur un réseau host-only `192.168.56.0/24` (VirtualBox) :

| Machine            | Système                         | Adresse IP       | Rôle                                        |
|--------------------|---------------------------------|------------------|---------------------------------------------|
| Attaquant          | Kali Linux                      | 192.168.56.106   | Lancer les attaques (scan, brute force, exploitation) |
| Victime            | Metasploitable2 (Ubuntu 8.04)   | 192.168.56.105   | Cible volontairement vulnérable             |
| Défenseur / SIEM   | Wazuh Manager                   | 192.168.56.108   | Collecte des logs, détection et réaction    |

---

## 🧰 Outils utilisés

- **Attaque :** Nmap, Hydra, Medusa, Metasploit Framework, Netcat, expect, rockyou.txt
- **Défense :** iptables, UFW, Fail2ban, durcissement SSH
- **Supervision (SIEM) :** Wazuh (Manager / Indexer / Dashboard), redirection Syslog (UDP 514), Active Response, MITRE ATT&CK
- **Extension IA :** API Claude (Anthropic) pour l'analyse en langage naturel des alertes

---

## 📁 Structure du dépôt

```
.
├── README.md
├── .gitignore
├── rapport/
│   └── Rapport_PFE_Soukaina_DOUAZI.pdf      # Rapport complet
├── presentation/
│   └── PFE.pptx                              # Diaporama de soutenance (19 slides)
├── scripts/
│   ├── detect_attack.sh                      # Détection des IP suspectes
│   ├── react_block.sh                        # Blocage automatique (iptables)
│   └── audit.sh                              # Audit système
└── ia/
    └── ai_analyst.py                         # Analyse des alertes Wazuh par l'API Claude
```

---

## ⚙️ Scripts d'automatisation

| Script             | Rôle                                                             |
|--------------------|-----------------------------------------------------------------|
| `detect_attack.sh` | Alerte lorsqu'une IP dépasse un seuil de tentatives échouées     |
| `react_block.sh`   | Bloque automatiquement l'IP suspecte via iptables               |
| `audit.sh`         | Inventorie les ports ouverts, utilisateurs et fichiers sensibles |

Rendre les scripts exécutables puis les lancer :

```bash
chmod +x scripts/*.sh
sudo ./scripts/detect_attack.sh
sudo ./scripts/react_block.sh
sudo ./scripts/audit.sh
```

---

## 🤖 Extension — Analyse des alertes par IA

Le script `ia/ai_analyst.py` lit le fichier d'alertes de Wazuh
(`/var/ossec/logs/alerts/alerts.json`) et demande à l'API Claude un résumé
clair des événements de sécurité détectés.

> ⚠️ **Sécurité :** la clé API n'est **jamais** écrite dans le code.
> Elle est lue depuis la variable d'environnement `ANTHROPIC_API_KEY`.

```bash
# Linux / macOS
export ANTHROPIC_API_KEY="votre_cle_api"
python3 ia/ai_analyst.py

# Windows PowerShell
$env:ANTHROPIC_API_KEY = "votre_cle_api"
python ia\ai_analyst.py
```

---

## 📊 Documents du projet

- **Rapport complet** (`rapport/`) : toutes les étapes, captures et explications détaillées.
- **Présentation de soutenance** (`presentation/PFE.pptx`) : diaporama de 19 slides résumant le projet (contexte, architecture, scénario d'attaque, défense, SIEM, extension IA, conclusion).

---

## ⚠️ Avertissement

Ce projet est réalisé **à des fins pédagogiques**, dans un environnement
**isolé** (réseau host-only, sans accès à Internet pour la cible). Les
techniques d'attaque présentées ne doivent être utilisées que sur des systèmes
vous appartenant ou pour lesquels vous disposez d'une autorisation explicite.

---

## 👤 Auteure

**Soukaina DOUAZI** — [github.com/sousou1999406](https://github.com/sousou1999406)
