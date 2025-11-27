# Chaîne UART – Servo – Télémètre sur FPGA (DE1)

Projet **personnel** entièrement décrit en **VHDL** sur carte **DE1 Cyclone II**.  
L’objectif est de construire une chaîne complète :

- communication série **UART** avec un PC,
- pilotage d’un **servomoteur** par PWM,
- acquisition d’une distance via un **télémètre ultrason**,
- intégration dans un **système complet** commandé par des interrupteurs (SW) de la DE1.

> 💡 Ce projet est inspiré d’un sujet de mini-projet universitaire, mais réalisé à titre personnel,
> sans processeur Nios II ni Qsys : tout est en logique VHDL.

---

## 🎯 Objectifs

- Implémenter une **liaison UART** complète (RX & TX) entre un PC (terminal série) et la carte DE1.
- Piloter un **servomoteur** standard via un signal PWM généré via une broche d'un des GPIO de la carte.
- Mesurer une distance avec un **télémètre ultrason** et renvoyer la mesure au PC.
- Intégrer le tout dans un **système multi-modes** sélectionné par les switchs de la carte DE1.

---

## 🧱 Architecture globale

### Plateforme matérielle

- FPGA : **Altera Cyclone II** (carte DE1),
- Horloge système : 50 MHz,
- Périphériques connectés :
  - UART ↔ PC (via interface série / USB-série),
  - Servo connecté à une sortie GPIO,
  - Télémètre ultrason (TRIG / ECHO) relié à des broches GPIO,
  - Switchs `SW1:SW0` pour choisir le mode de fonctionnement,
  - LEDs pour visualiser certains signaux.

### Blocs principaux (VHDL)

- `UART_TX`   : émission série vers PC,
- `UART_RX`   : réception série depuis PC,
- `SERVO`     : génération de PWM (≈20 ms de période, impulsion 1–2 ms),
- `TELEMETRE` : pilotage du télémètre ultrason (impulsion de trigger + mesure de la durée d’écho),
- `TOP_LEVEL` : intégration des blocs et gestion des modes en fonction de `SW1:SW0`,
- Divers blocs auxiliaires :
  - diviseur de fréquence,
  - registres de configuration,
  - logique de multiplexage des données UART.

Les fichiers associés sont dans le dossier `src/`.

---

## 🧠 Modes de fonctionnement (système complet)

Le comportement global est piloté par les interrupteurs `SW1:SW0` :

- `SW1 SW0 = 00` → **Mode 0 : Idle**  
  Tous les IP (UART, servo, télémètre) sont inactifs.  
  Le système est au repos (sécurité / debug).

- `SW1 SW0 = 01` → **Mode 1 : UART → Servo**  
  Le PC envoie via le terminal série (ex. PuTTY) une commande correspondant à une **position cible** de servo  
  (un angle codé sur 3 octets).  
  - `UART_RX` reçoit la donnée,
  - un bloc de décodage convertit cette valeur en rapport cyclique,
  - le bloc `SERVO` génère le signal PWM correspondante pour positionner physiquement le servomoteur.

- `SW1 SW0 = 10` → **Mode 2 : UART ↔ Télémètre**  
  Le FPGA pilote périodiquement le **télémètre ultrason** :
  - génération d’une impulsion de trigger,
  - mesure du temps d’écho pour calculer la distance (en cm).  
  La distance mesurée est :
  - stockée dans un registre interne,
  - envoyée vers le PC via `UART_TX`,  
  ce qui permet d’afficher en continu la distance sur le terminal série.

- `SW1 SW0 = 11` → **Mode 3 : Servo + télémètre synchronisés**  
  La distance donnée par le télémètre est traduite en un angle qui controle la position du servomoteur.

---

## 🔩 Détails des blocs

### UART (RX & TX)

- Paramétrage classique 8N1 (8 bits, pas de parité, 1 bit de stop),
- Fréquence d’horloge 50 MHz → diviseur pour obtenir le baudrate souhaité (ex. 115200 bauds),
- `UART_RX` :
  - échantillonnage du bit de start,
  - acquisition des 8 bits de données,
  - vérification du bit de stop,
  - mise à disposition de l’octet reçu + signal de “data ready”.
- `UART_TX` :
  - sérialisation du start bit, des 8 bits de données, puis du stop bit.

### SERVO

- Génération d’un signal PWM :
  - période = 20 ms,
  - durée de l’impulsion typiquement de 1 ms (angle min) à 2 ms (angle max),
- Entrée : valeur de consigne (sur 8 bits) convertie en temps d’impulsion,
- Sortie : signal vers la broche de commande du servomoteur.

### Télémètre ultrason

- Génération d’une impulsion de trigger (niveau haut pendant 10 µs),
- Mesure de la durée de l’impulsion d’écho à l’aide d’un compteur incrémenté à partir de l’horloge 50 MHz,
- Conversion du temps mesuré en distance,
- Signal de “mesure prête” pour le reste du système.

---

## 🧪 Simulation (ModelSim)

Le dossier `sim/` contient :

- des **testbenches** VHDL :
  - `UART_RX_tb.vhd`,
  - `UART_TX_tb.vhd`,
  - `SERVO_tb.vhd`,
  - `TELEMETRE_tb.vhd`,
- des **scripts `.do`** :
  - `simu_UART_RX.do`,
  - `simu_UART_TX.do`,
  - `simu_SERVO.do`,
  - `simu_TELEMETRE.do`.

Ces scripts automatisent la compilation et la simulation sous **ModelSim** pour valider :

- la trame UART (RX & TX),
- la forme du signal PWM du servo,
- la forme des signaux ECHO et TRIG et la valeur mesurée.

---

## 🛠 Outils & environnement

- **Intel Quartus Prime** (version 13.0sp1 dans ce projet) pour la synthèse et l’implantation sur DE1,
- **ModelSim** pour la simulation fonctionnelle,
- Carte **DE1 Cyclone II**,
- Un terminal série sur PC (ex. **Terminal**) configuré au même baudrate que l’UART.

---

## ⚙️ Mise en route (sur carte DE1)

1. Ouvrir le projet Quartus dans `fit/`.
2. Vérifier la bonne configuration de la carte (DE1, pin assigment, etc.).
3. Lancer :
   - `Analysis & Synthesis`,
   - `Fitter`,
   - `Assembler` / `Program Device`.
4. Programmer la carte avec le `.sof`.
5. Brancher l’UART vers le PC (via un adaptateur USB-série).
6. Configurer le terminal série (baudrate, 8N1).
7. Choisir un mode avec `SW1:SW0` et tester :
   - mode 1 : commandes de position du servo depuis le PC,
   - mode 2 : affichage en continu de la distance,
   - mode 3 : distance Télémètre vers angle servomoteur.

---

## 📂 Organisation du dépôt

```text
src/  # Blocs VHDL : UART_RX, UART_TX, SERVO, TELEMETRE, TOP_LEVEL, etc.
fit/  # Projet Quartus pour la carte DE1
simu/  # Testbenches & scripts ModelSim (.do)
