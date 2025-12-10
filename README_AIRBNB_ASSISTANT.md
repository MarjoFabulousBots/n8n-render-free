# 🏔️ Assistant WhatsApp Airbnb - Documentation Complète

Un assistant AI intelligent pour gérer les conversations WhatsApp avec vos invités Airbnb, avec détection automatique des nouveaux utilisateurs, collecte de dates, et historique de conversation.

---

## 📂 Fichiers du Projet

### 🎯 Workflows N8N

1. **`workflow-airbnb-improved.json`** (Principal)
   - Workflow principal amélioré
   - Gère la détection des invités
   - Route vers l'AI Agent
   - Sauvegarde automatique de l'historique

2. **`sub-workflow-save-guest.json`**
   - Sous-workflow pour enregistrer un nouvel invité
   - Validation des dates
   - Sauvegarde en base de données

3. **`sub-workflow-save-conversation.json`**
   - Sous-workflow pour sauvegarder les messages
   - Validation des données
   - Historique complet

### 📖 Documentation

4. **`AMELIORATIONS_WORKFLOW.md`**
   - Explication détaillée des améliorations
   - Comparaison avant/après
   - Architecture technique

5. **`GUIDE_DEPLOIEMENT.md`**
   - Guide pas-à-pas pour déployer
   - 3 options de backend (Supabase / Express.js / Google Sheets)
   - Configuration complète
   - Troubleshooting

6. **`README_AIRBNB_ASSISTANT.md`** (ce fichier)
   - Vue d'ensemble du projet
   - Quick start
   - Liens vers les autres docs

---

## 🚀 Quick Start (5 minutes)

### Option la Plus Rapide : Supabase

1. **Créer un compte Supabase**
   ```
   → Allez sur supabase.com
   → Créez un nouveau projet
   → Notez votre Project URL et API Key
   ```

2. **Créer les tables**
   ```sql
   -- Copiez le SQL depuis GUIDE_DEPLOIEMENT.md section "Option 1"
   -- Exécutez dans SQL Editor de Supabase
   ```

3. **Importer les workflows dans N8N**
   ```
   → Import workflow-airbnb-improved.json
   → Import sub-workflow-save-guest.json
   → Import sub-workflow-save-conversation.json
   ```

4. **Configurer les variables d'environnement**
   ```bash
   N8N_DB_API_URL=https://your-project.supabase.co/rest/v1
   SUPABASE_KEY=your-anon-key
   ```

5. **Configurer les credentials**
   - OpenAI API (pour l'AI Agent)
   - WhatsApp Business API
   - Supabase (Header Auth)

6. **Activer le workflow**
   ```
   → Toggle "Active" dans N8N
   → Testez avec un message WhatsApp
   ```

✅ **Terminé !** Votre assistant est opérationnel.

---

## 🏗️ Architecture Globale

```
┌─────────────────────────────────────────────────────────────┐
│                     WhatsApp Business API                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                         N8N Workflow                         │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Trigger    │───▶│ Check Guest  │───▶│  IF Exists?  │  │
│  │  (WhatsApp)  │    │   in DB      │    │              │  │
│  └──────────────┘    └──────────────┘    └───┬──────┬───┘  │
│                                              │      │       │
│                                        ┌─────┘      └─────┐ │
│                                        ▼                   ▼ │
│                              ┌─────────────┐    ┌──────────┴┐│
│                              │  Existing   │    │    New    ││
│                              │   Guest     │    │   Guest   ││
│                              │  Context    │    │  Context  ││
│                              └──────┬──────┘    └─────┬─────┘│
│                                     │                 │      │
│                                     └────────┬────────┘      │
│                                              ▼               │
│                               ┌──────────────────────────┐   │
│                               │       AI Agent           │   │
│                               │  (OpenAI GPT-4o)         │   │
│                               │  + Conversation Memory   │   │
│                               │  + Tools:                │   │
│                               │    - save_guest_dates    │   │
│                               │    - save_conversation   │   │
│                               │    - get_local_details   │   │
│                               │    - notify_owner        │   │
│                               └───────────┬──────────────┘   │
│                                           ▼                  │
│                               ┌──────────────────────────┐   │
│                               │   Send WhatsApp Response │   │
│                               └───────────┬──────────────┘   │
│                                           ▼                  │
│                        ┌──────────────────────────────────┐  │
│                        │    Save to Conversation History  │  │
│                        └──────────────────────────────────┘  │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │  Database (Supabase/PG)  │
                    │  - guests table          │
                    │  - conversations table   │
                    └──────────────────────────┘
```

---

## 🎭 Scénarios d'Utilisation

### Scénario 1 : Nouvel Invité avec Dates Complètes

```
User: "Bonjour, j'arrive demain pour 5 jours"

Flow:
1. WhatsApp Trigger reçoit le message
2. Check Guest in DB → 404 Not Found
3. IF Guest Exists → False (nouveau)
4. Prepare New Guest Context:
   {
     "is_new_guest": true,
     "guest_name": "John Doe",
     "phone_number": "+33612345678",
     "check_in_date": null,
     "check_out_date": null,
     "user_message": "Bonjour, j'arrive demain pour 5 jours"
   }
5. AI Agent analyse le message:
   - Détecte "demain" = 2025-12-11
   - Détecte "5 jours" = check_out 2025-12-16
   - Appelle save_guest_dates(name="John Doe", check_in="2025-12-11", check_out="2025-12-16")
6. Sub-workflow Save Guest Dates:
   - Valide les dates
   - INSERT dans la base
   - Retourne success
7. AI Agent répond:
   "Parfait ! J'ai bien noté votre séjour du 11/12 au 16/12. Comment puis-je vous aider ? 🏔️"
8. Send WhatsApp Response
9. Save to Conversation History (user + bot messages)
```

### Scénario 2 : Nouvel Invité sans Dates

```
User: "Bonjour"

Flow:
1-4. Identique au scénario 1
5. AI Agent analyse le message:
   - Pas de dates détectées
   - Répond: "Bonjour ! 👋 Pour mieux vous aider, quelle est votre date d'arrivée au Chalet Flocon ?"
6. Send WhatsApp Response
7. Save to Conversation History

---

User: "Le 15 décembre"

Flow:
1. WhatsApp Trigger reçoit le nouveau message
2. Check Guest in DB → 404 (pas encore enregistré car pas de dates complètes)
3. AI Agent (avec mémoire de conversation):
   - Se rappelle qu'il a déjà demandé la date d'arrivée
   - Détecte "le 15 décembre" = 2025-12-15
   - Répond: "Merci ! Et quelle est votre date de départ ?"
4. ...

---

User: "Le 20 décembre"

Flow:
1-3. Identique
4. AI Agent:
   - Se rappelle check_in = 2025-12-15
   - Détecte check_out = 2025-12-20
   - Appelle save_guest_dates(check_in="2025-12-15", check_out="2025-12-20")
   - Confirme: "Parfait ! J'ai bien noté votre séjour du 15/12 au 20/12..."
```

### Scénario 3 : Invité Existant (Normal)

```
User: "Où est le WiFi ?"

Flow:
1. WhatsApp Trigger
2. Check Guest in DB → 200 OK
   {
     "phone_number": "+33612345678",
     "guest_name": "John Doe",
     "check_in_date": "2025-12-15",
     "check_out_date": "2025-12-20"
   }
3. IF Guest Exists → True
4. Format Guest Data:
   {
     "guest_name": "John Doe",
     "check_in_date": "2025-12-15",
     "check_out_date": "2025-12-20",
     "today": "2025-12-10",
     "is_before_checkin": true,
     "is_past_checkout": false,
     "is_current_guest": false
   }
5. IF Past Checkout → False (séjour futur)
6. Prepare Existing Guest Context
7. AI Agent (avec contexte invité):
   - Voit que guest_status = "FUTUR"
   - Consulte les permissions: ❌ Code WiFi (seulement 24h avant)
   - Répond: "Le code WiFi vous sera communiqué 24h avant votre arrivée. Le réseau s'appelle CHALET_FLOCON_5G. En attendant, puis-je vous aider avec autre chose ?"
8. Send WhatsApp Response
9. Save to Conversation History
```

### Scénario 4 : Invité Passé (Check-out Dépassé)

```
User: "Bonjour"

Flow:
1-4. Identique à Scénario 3
5. IF Past Checkout → True (today > check_out_date)
6. Send Access Denied Message:
   "Merci de votre message ! Votre séjour est maintenant terminé. Pour toute question, veuillez contacter directement le propriétaire au 06 01 02 03 04. 🏔️"
7. FIN (pas d'accès à l'AI Agent)
```

### Scénario 5 : Recommandation Restaurant (Perplexity)

```
User: "Quel restaurant recommandez-vous ce soir ?"

Flow:
1-7. Flux normal (invité existant)
8. AI Agent:
   - Détecte que c'est une question locale
   - Consulte la base de connaissances (liste de restaurants)
   - Si besoin d'infos actualisées, appelle get_local_details(query="Meilleurs restaurants Val Thorens ouverts décembre 2025")
9. Perplexity API retourne des résultats en temps réel
10. AI Agent synthétise:
    "Je vous recommande Le Galoubet (pizzas, grillades) à 100m, ou La Table du Sherpa (fondue savoyarde) à 150m. Réservation fortement conseillée ! Voulez-vous que je vous envoie leur position GPS ?"
11. Send WhatsApp Response
```

---

## 🛠️ Configuration Détaillée

### Variables d'Environnement Requises

```bash
# Database
N8N_DB_API_URL=https://your-project.supabase.co/rest/v1
SUPABASE_KEY=your-anon-key

# OpenAI
OPENAI_API_KEY=sk-...

# WhatsApp Business
WHATSAPP_PHONE_NUMBER_ID=813228818532969
WHATSAPP_ACCESS_TOKEN=your-token

# Perplexity (optionnel)
PERPLEXITY_API_KEY=your-key

# Email (optionnel, pour notify_owner)
GMAIL_CLIENT_ID=...
GMAIL_CLIENT_SECRET=...
```

### Credentials N8N à Configurer

1. **OpenAI API**
   - Type: OpenAI
   - API Key: `sk-...`

2. **WhatsApp Business**
   - Type: WhatsApp
   - Phone Number ID: `813228818532969`
   - Access Token: `your-token`

3. **Supabase / Database**
   - Type: Header Auth
   - Name: `apikey`
   - Value: `your-supabase-key`
   - Additional Header:
     - Name: `Authorization`
     - Value: `Bearer your-supabase-key`

4. **Perplexity API** (optionnel)
   - Type: Perplexity
   - API Key: `your-key`

5. **Gmail OAuth2** (optionnel, pour notify_owner)
   - Type: Gmail OAuth2
   - Client ID / Secret: depuis Google Cloud Console

---

## 📊 Base de Données

### Schéma `guests`

| Colonne          | Type         | Description                       |
|------------------|--------------|-----------------------------------|
| id               | BIGSERIAL    | Clé primaire auto-incrémentée     |
| phone_number     | VARCHAR(20)  | Numéro WhatsApp (UNIQUE)          |
| guest_name       | VARCHAR(100) | Nom complet de l'invité           |
| check_in_date    | DATE         | Date d'arrivée                    |
| check_out_date   | DATE         | Date de départ                    |
| created_at       | TIMESTAMP    | Date de création                  |
| updated_at       | TIMESTAMP    | Date de dernière modification     |

**Index :**
- `idx_guests_phone` sur `phone_number`

### Schéma `conversations`

| Colonne          | Type         | Description                       |
|------------------|--------------|-----------------------------------|
| id               | BIGSERIAL    | Clé primaire auto-incrémentée     |
| phone_number     | VARCHAR(20)  | Numéro WhatsApp                   |
| message          | TEXT         | Contenu du message                |
| sender           | VARCHAR(10)  | 'user' ou 'bot'                   |
| timestamp        | TIMESTAMP    | Date/heure du message             |
| created_at       | TIMESTAMP    | Date de sauvegarde                |

**Index :**
- `idx_conversations_phone` sur `phone_number`
- `idx_conversations_timestamp` sur `timestamp DESC`

---

## 🎨 Personnalisation

### Modifier les Informations du Chalet

Éditez le prompt système dans le nœud **AI Agent** :

```javascript
// Changez les informations de contact
**Contact propriétaire:** 06 01 02 03 04 (disponible 7j/7, 8h-22h)

// Changez les informations WiFi
**Réseau:** CHALET_FLOCON_5G
**Mot de passe:** Indiqué dans le livret d'accueil

// Ajoutez des équipements
### NOUVEAUX ÉQUIPEMENTS
**Sauna:** Disponible 24h/24, température 80°C

// Modifiez les règles
- 💰 Caution : 500€ (au lieu de 300€)
```

### Ajouter un Nouvel Outil AI

1. Créez un nouveau nœud `Tool: Your Tool Name`
2. Configurez les paramètres avec `$fromAI()`
3. Connectez-le à l'AI Agent via `ai_tool`
4. Documentez l'outil dans le prompt système

**Exemple : Outil de réservation de navette**

```json
{
  "name": "book_shuttle",
  "description": "Réserver la navette gratuite depuis Moutiers",
  "parameters": {
    "guest_name": "={{ $fromAI('name', 'Nom du voyageur', 'string') }}",
    "arrival_date": "={{ $fromAI('date', 'Date d\\'arrivée YYYY-MM-DD', 'string') }}",
    "arrival_time": "={{ $fromAI('time', 'Heure d\\'arrivée HH:MM', 'string') }}",
    "train_number": "={{ $fromAI('train', 'Numéro de train (optionnel)', 'string') }}"
  }
}
```

### Changer la Langue

Modifiez le prompt système :

```javascript
// Anglais
"You are the virtual assistant for Chalet Flocon in Val Thorens. You help guests with information about their stay."

// Espagnol
"Eres el asistente virtual del Chalet Flocon en Val Thorens. Ayudas a los huéspedes con información sobre su estancia."
```

### Ajuster le Ton de l'AI

Dans le prompt système, section **TONE & STYLE** :

```javascript
// Plus formel
"Utilisez un ton professionnel et courtois. Vouvoiement obligatoire. Pas d'emojis."

// Plus décontracté
"Sois sympa et décontracté ! Tutoie l'invité et utilise des emojis 😊"

// Minimaliste
"Réponses ultra-courtes. Maximum 2 phrases par message. Pas d'emojis."
```

---

## 🐛 Debugging

### Activer les Logs Détaillés

Dans N8N, ajoutez un nœud **Set** après chaque étape importante :

```json
{
  "name": "Debug Log",
  "parameters": {
    "mode": "raw",
    "jsonOutput": "={{ { step: 'Check Guest', input: $input.all(), output: $json } }}"
  }
}
```

### Tester l'AI Agent Isolément

1. Désactivez temporairement le WhatsApp Trigger
2. Ajoutez un nœud **Manual Trigger**
3. Ajoutez un nœud **Set** pour simuler les données :

```json
{
  "is_new_guest": true,
  "guest_name": "Test User",
  "phone_number": "+33600000000",
  "check_in_date": null,
  "check_out_date": null,
  "user_message": "Bonjour, j'arrive demain"
}
```

4. Connectez directement au nœud **AI Agent**
5. Testez manuellement

### Vérifier les Appels d'Outils

Dans les exécutions N8N, cliquez sur le nœud **AI Agent** pour voir :
- Les outils appelés
- Les paramètres passés
- Les réponses reçues

---

## 📈 Métriques & Analytics

### KPIs à Suivre

1. **Taux de collecte de dates réussies**
   ```sql
   SELECT
     COUNT(*) FILTER (WHERE check_in_date IS NOT NULL) * 100.0 / COUNT(*) as success_rate
   FROM guests
   WHERE created_at >= NOW() - INTERVAL '30 days';
   ```

2. **Temps moyen de collecte**
   ```sql
   SELECT
     AVG(EXTRACT(EPOCH FROM (second_message.timestamp - first_message.timestamp)) / 60) as avg_minutes
   FROM conversations first_message
   JOIN conversations second_message
     ON first_message.phone_number = second_message.phone_number
   WHERE first_message.sender = 'user'
     AND second_message.sender = 'user'
     AND second_message.timestamp > first_message.timestamp;
   ```

3. **Questions les plus fréquentes**
   ```sql
   SELECT message, COUNT(*) as frequency
   FROM conversations
   WHERE sender = 'user'
     AND created_at >= NOW() - INTERVAL '30 days'
   GROUP BY message
   ORDER BY frequency DESC
   LIMIT 10;
   ```

### Dashboard Metabase (Optionnel)

1. Installez [Metabase](https://www.metabase.com/)
2. Connectez-le à votre base PostgreSQL
3. Créez des dashboards avec :
   - Nombre d'invités par mois
   - Taux d'occupation
   - Satisfaction (via enquête post-séjour)
   - Temps de réponse moyen

---

## 🚀 Optimisations Avancées

### 1. Cache Redis pour les Invités Fréquents

Si vous avez des invités qui reviennent souvent, mettez en cache leurs données :

```javascript
// Pseudo-code
const cachedGuest = await redis.get(`guest:${phone_number}`);
if (cachedGuest) {
  return JSON.parse(cachedGuest);
}

const guest = await db.query('SELECT * FROM guests WHERE phone_number = $1', [phone_number]);
await redis.setEx(`guest:${phone_number}`, 3600, JSON.stringify(guest));
```

### 2. Webhook pour Notifications Instantanées

Au lieu d'envoyer des emails, utilisez Telegram ou Slack :

```javascript
// Tool: notify_owner via Telegram
{
  "url": "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage",
  "body": {
    "chat_id": "YOUR_CHAT_ID",
    "text": "🚨 Nouveau message de {{ guest_name }}: {{ message }}"
  }
}
```

### 3. Analyse de Sentiment

Détectez les invités mécontents automatiquement :

```javascript
// Dans le prompt système
"Si le message de l'utilisateur exprime une forte insatisfaction ou une urgence, appelle immédiatement notify_owner avec urgency='high'."
```

### 4. Multi-Langues Automatique

Détectez la langue du message et répondez dans la même langue :

```javascript
// Dans le prompt système
"Détecte automatiquement la langue du message (français, anglais, espagnol, italien, allemand) et réponds dans cette même langue. Adapte les informations culturellement."
```

---

## 🆘 Support & Communauté

### Ressources Officielles

- [N8N Documentation](https://docs.n8n.io)
- [N8N Community Forum](https://community.n8n.io)
- [OpenAI API Docs](https://platform.openai.com/docs)
- [Supabase Docs](https://supabase.com/docs)

### Problèmes Courants

Consultez la section **Troubleshooting** dans `GUIDE_DEPLOIEMENT.md`

---

## 📄 Licence

Ce projet est fourni tel quel à des fins éducatives et commerciales.

---

## 🎉 Prochaines Étapes

1. ✅ Importer les workflows
2. ✅ Configurer la base de données
3. ✅ Tester avec un numéro de test
4. 📊 Créer des dashboards analytics
5. 🌐 Ajouter d'autres langues
6. 🔔 Configurer les alertes propriétaire
7. 📸 Ajouter l'envoi d'images du chalet
8. 🗓️ Intégrer un calendrier de réservation

---

**Besoin d'aide pour démarrer ?**

1. Lisez le **Quick Start** ci-dessus (5 min)
2. Suivez le **GUIDE_DEPLOIEMENT.md** pour votre backend préféré
3. Consultez **AMELIORATIONS_WORKFLOW.md** pour comprendre la logique

**Bonne chance avec votre assistant Airbnb ! 🏔️**
