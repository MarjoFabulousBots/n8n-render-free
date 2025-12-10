# 🚀 Améliorations du Workflow Airbnb Assistant

## 📋 Résumé des Changements

### ✅ Problèmes Corrigés

1. **Mauvais type de nœuds pour la base de données**
   - ❌ Avant : Utilisation de `memoryVectorStore` (pour recherche sémantique)
   - ✅ Après : Utilisation de `httpRequest` vers une vraie API de base de données

2. **Connexions manquantes**
   - ❌ Avant : "Ask New Guest Dates" envoyait un message mais ne continuait pas
   - ✅ Après : Tout est connecté vers l'AI Agent qui gère la conversation complète

3. **Historique de conversation**
   - ❌ Avant : Sauvegarde via outils AI (incertain)
   - ✅ Après : Sauvegarde automatique en parallèle après chaque échange

4. **Logique incohérente**
   - ❌ Avant : Demander les dates sans laisser l'AI gérer la conversation
   - ✅ Après : L'AI Agent gère tout le dialogue de collecte des dates

---

## 🔄 Architecture Améliorée

### Flux Principal

```
WhatsApp Trigger
    ↓
Check Guest Exists in DB (HTTP Request)
    ↓
IF Guest Exists?
    ├── OUI → Format Guest Data
    │           ↓
    │       IF Past Checkout?
    │           ├── OUI → Send Access Denied Message (FIN)
    │           └── NON → Prepare Existing Guest Context
    │                       ↓
    │                   AI Agent → Send WhatsApp Response
    │
    └── NON → Prepare New Guest Context
                ↓
            AI Agent → Send WhatsApp Response
                ↓
        Log User Message & Bot Message (parallèle)
                ↓
        Save to DB (historique)
```

---

## 🎯 Améliorations Détaillées

### 1. Base de Données Réelle

**Avant :**
```json
{
  "type": "@n8n/n8n-nodes-langchain.memoryVectorStore",
  "operation": "getAll"
}
```

**Après :**
```json
{
  "type": "n8n-nodes-base.httpRequest",
  "url": "{{ $env.N8N_DB_API_URL }}/guests/{{ phone_number }}",
  "method": "GET"
}
```

**Avantages :**
- ✅ Vraie persistance des données
- ✅ Recherche par clé primaire (numéro de téléphone)
- ✅ Gestion des erreurs 404 (invité non trouvé)
- ✅ Compatible avec PostgreSQL, MySQL, Supabase, etc.

---

### 2. Gestion des Nouveaux Invités

**Changement majeur :** Au lieu d'envoyer un message isolé, on passe directement à l'AI Agent avec un contexte spécial.

**Contexte transmis à l'AI :**
```json
{
  "is_new_guest": true,
  "guest_name": "Nom depuis WhatsApp",
  "phone_number": "+33612345678",
  "check_in_date": null,
  "check_out_date": null,
  "guest_status": "NOUVEAU",
  "user_message": "Message de l'utilisateur"
}
```

**L'AI Agent sait alors :**
- Qu'il doit collecter les dates
- Comment analyser le premier message pour détecter des dates
- Poser les questions dans le bon ordre
- Utiliser l'outil `save_guest_dates` une fois les deux dates obtenues

---

### 3. Prompt Système Amélioré

**Nouvelles fonctionnalités :**

#### 🧠 Détection Intelligente des Dates

L'AI analyse TOUJOURS le premier message pour éviter de redemander :

**Exemples :**
```
User: "J'arrive demain pour 5 jours"
→ AI détecte : check_in = 2025-12-11, check_out = 2025-12-16
→ Appelle save_guest_dates immédiatement

User: "Je serai là du 15 au 20 décembre"
→ AI détecte : check_in = 2025-12-15, check_out = 2025-12-20
→ Appelle save_guest_dates immédiatement

User: "Bonjour"
→ Pas de dates détectées
→ AI demande : "Quelle est votre date d'arrivée ?"
```

#### 📅 Conversion des Dates Relatives

Le prompt inclut maintenant la date actuelle dynamique :

```
TODAY: {{ $now.format('yyyy-MM-dd') }}

Conversions automatiques :
- "demain" → 2025-12-11
- "après-demain" → 2025-12-12
- "dans 3 jours" → 2025-12-13
- "le 15 décembre" → 2025-12-15
```

#### 🔐 Gestion des Permissions par Statut

```
FUTUR (avant check-in) :
✅ Infos générales, équipements, parking
❌ Code WiFi (seulement 24h avant)

ACTUEL (pendant séjour) :
✅ Tout accès complet

PASSÉ (après check-out) :
⚠️ Message automatique de fin de séjour
```

---

### 4. Outils AI Correctement Configurés

#### 💾 save_guest_dates (Workflow Tool)

```json
{
  "type": "@n8n/n8n-nodes-langchain.toolWorkflow",
  "name": "save_guest_dates",
  "description": "Enregistrer les dates après collecte COMPLÈTE",
  "inputSchema": {
    "required": ["guest_name", "check_in_date", "check_out_date"]
  }
}
```

**Appelle un sous-workflow** qui fait :
1. Validation des dates
2. INSERT dans la base de données
3. Confirmation

#### 💬 save_conversation (Workflow Tool)

Permet à l'AI de sauvegarder manuellement si nécessaire.

#### 🌐 get_local_details (HTTP Tool vers Perplexity)

```json
{
  "type": "@n8n/n8n-nodes-langchain.toolHttpRequest",
  "url": "https://api.perplexity.ai/chat/completions",
  "description": "Recherche en temps réel (restaurants, météo, événements)"
}
```

#### 📧 notify_owner (HTTP Tool)

Envoie un webhook pour alerter le propriétaire avec niveau d'urgence.

---

### 5. Historique Automatique

**Nouveauté :** Sauvegarde automatique en parallèle (pas via l'AI)

**Flux après réponse :**
```
Send WhatsApp Response
    ↓
Log User Message (Set) ──→ Save User Message to DB
    ‖
Log Bot Message (Set) ──→ Save Bot Message to DB
```

**Avantages :**
- ✅ Garantit la sauvegarde même si l'AI oublie
- ✅ Pas de tokens gaspillés sur des appels d'outils répétitifs
- ✅ Historique complet fiable

---

## 🛠️ Configuration Requise

### Variables d'Environnement

Ajoutez dans N8N :

```bash
N8N_DB_API_URL=https://votre-api.com/api
# ou
N8N_DB_API_URL=https://your-supabase-project.supabase.co/rest/v1
```

### Base de Données

**Table `guests` :**
```sql
CREATE TABLE guests (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    guest_name VARCHAR(100),
    check_in_date DATE,
    check_out_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Table `conversations` :**
```sql
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    sender VARCHAR(10) NOT NULL, -- 'user' ou 'bot'
    timestamp TIMESTAMP NOT NULL,
    FOREIGN KEY (phone_number) REFERENCES guests(phone_number)
);
```

### Endpoints API Requis

**GET** `/guests/{phone_number}`
- Retourne 200 + données si trouvé
- Retourne 404 si non trouvé

**POST** `/guests`
```json
{
  "phone_number": "33612345678",
  "guest_name": "Marie Dupont",
  "check_in_date": "2025-12-15",
  "check_out_date": "2025-12-20"
}
```

**POST** `/conversations`
```json
{
  "phone_number": "33612345678",
  "message": "Bonjour",
  "sender": "user",
  "timestamp": "2025-12-10T10:30:00Z"
}
```

---

## 🧪 Tests Recommandés

### Test 1 : Nouvel Invité avec Dates Complètes
```
User: "Bonjour, j'arrive demain pour 5 jours"
Expected:
1. AI détecte les dates
2. Appelle save_guest_dates
3. Confirme : "Parfait ! J'ai noté votre séjour du 11/12 au 16/12..."
```

### Test 2 : Nouvel Invité sans Dates
```
User: "Bonjour"
Expected:
1. AI demande : "Quelle est votre date d'arrivée ?"
2. User: "Demain"
3. AI demande : "Et votre date de départ ?"
4. User: "Dans 5 jours"
5. AI appelle save_guest_dates
6. AI confirme
```

### Test 3 : Invité Existant
```
User: "Où est le WiFi ?"
Expected:
1. Charge les données depuis DB
2. Vérifie le statut (ACTUEL)
3. Répond avec les infos WiFi
```

### Test 4 : Invité Passé (Check-out dépassé)
```
Expected:
1. Message automatique : "Votre séjour est terminé..."
2. Pas d'accès à l'AI Agent
```

### Test 5 : Historique
```
Après chaque conversation :
1. Vérifier que tous les messages sont dans `conversations`
2. Avec sender = 'user' ou 'bot'
3. Timestamps corrects
```

---

## 🚨 Points d'Attention

### 1. Sous-Workflows Requis

Le workflow principal appelle des sous-workflows pour :
- `save_guest_dates` : À créer séparément
- `save_conversation` : À créer séparément

**Alternative simple :** Remplacer les `toolWorkflow` par des `httpRequest` directs vers votre API.

### 2. Authentification

Les nœuds HTTP Request nécessitent des credentials :
- Basic Auth
- Bearer Token
- ou API Key

Configurez dans : **Settings > Credentials**

### 3. Gestion des Erreurs

Ajoutez des nœuds `Error Trigger` pour :
- API indisponible
- Échec de sauvegarde
- Timeout OpenAI

### 4. Coûts OpenAI

Avec `contextWindowLength: 15` et des conversations longues :
- Estimez 500-1000 tokens par échange
- Coût GPT-4o : ~$0.01-0.02 par conversation

**Optimisation :**
- Réduire `contextWindowLength` à 10
- Utiliser `gpt-4o-mini` (75% moins cher)
- Limiter la longueur des réponses avec `maxTokens: 500`

---

## 📊 Métriques de Succès

**Indicateurs à suivre :**
- ✅ Taux de collecte de dates réussies (objectif : >95%)
- ✅ Temps moyen de collecte (objectif : <2 min)
- ✅ Taux de sauvegarde historique (objectif : 100%)
- ✅ Satisfaction des invités (enquête post-séjour)

---

## 🔗 Prochaines Étapes

1. **Importer le workflow** dans N8N
2. **Créer la base de données** (PostgreSQL, Supabase, ou autre)
3. **Développer l'API REST** (ou utiliser Supabase REST API)
4. **Configurer les credentials** dans N8N
5. **Créer les sous-workflows** pour save_guest_dates et save_conversation
6. **Tester avec un numéro WhatsApp de test**
7. **Activer le workflow**

---

## 📚 Ressources

- [N8N Documentation](https://docs.n8n.io)
- [OpenAI API](https://platform.openai.com/docs)
- [Supabase](https://supabase.com/docs) (recommandé pour la DB)
- [Perplexity API](https://docs.perplexity.ai)

---

**Besoin d'aide ?** Les principaux changements sont :
1. HTTP Request au lieu de VectorStore
2. Tout passe par l'AI Agent
3. Historique automatique en parallèle
4. Prompt système beaucoup plus intelligent

Bon déploiement ! 🚀
