# 🚀 Guide de Déploiement Rapide

## Option 1 : Avec Supabase (Recommandé - Le Plus Simple)

### Étape 1 : Créer un Projet Supabase

1. Allez sur [supabase.com](https://supabase.com)
2. Créez un nouveau projet (gratuit)
3. Notez votre **Project URL** et **anon/public key**

### Étape 2 : Créer les Tables

Dans **SQL Editor** de Supabase :

```sql
-- Table guests
CREATE TABLE guests (
    id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    guest_name VARCHAR(100),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Index pour recherche rapide
CREATE INDEX idx_guests_phone ON guests(phone_number);

-- Table conversations
CREATE TABLE conversations (
    id BIGSERIAL PRIMARY KEY,
    phone_number VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    sender VARCHAR(10) NOT NULL CHECK (sender IN ('user', 'bot')),
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Index pour recherche par téléphone
CREATE INDEX idx_conversations_phone ON conversations(phone_number);
CREATE INDEX idx_conversations_timestamp ON conversations(timestamp DESC);

-- Fonction pour auto-update
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_guests_updated_at BEFORE UPDATE ON guests
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Étape 3 : Configurer N8N

Dans N8N, ajoutez ces variables d'environnement :

```bash
N8N_DB_API_URL=https://your-project.supabase.co/rest/v1
SUPABASE_KEY=your-anon-key
```

### Étape 4 : Modifier les Nœuds HTTP Request

Dans chaque nœud HTTP Request, configurez l'authentification :

**Type :** Header Auth
**Name :** `apikey`
**Value :** `={{ $env.SUPABASE_KEY }}`

**Header additionnel :**
**Name :** `Authorization`
**Value :** `Bearer {{ $env.SUPABASE_KEY }}`

### Étape 5 : Adapter les URLs

**Check Guest Exists :**
```
URL: {{ $env.N8N_DB_API_URL }}/guests?phone_number=eq.{{ $json.contacts[0].wa_id }}
Method: GET
```

**Save Guest (sub-workflow) :**
```
URL: {{ $env.N8N_DB_API_URL }}/guests
Method: POST
Headers:
  - Content-Type: application/json
  - Prefer: return=representation
```

**Save Conversation :**
```
URL: {{ $env.N8N_DB_API_URL }}/conversations
Method: POST
Headers:
  - Content-Type: application/json
  - Prefer: return=minimal
```

---

## Option 2 : API Express.js Custom

### Étape 1 : Créer le Projet

```bash
mkdir airbnb-api
cd airbnb-api
npm init -y
npm install express pg dotenv cors
```

### Étape 2 : Créer l'API (`server.js`)

```javascript
require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// Configuration PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Middleware d'authentification simple
const authenticate = (req, res, next) => {
  const apiKey = req.headers['x-api-key'];
  if (apiKey !== process.env.API_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
};

// GET /api/guests/:phone - Récupérer un invité
app.get('/api/guests/:phone', authenticate, async (req, res) => {
  try {
    const { phone } = req.params;
    const result = await pool.query(
      'SELECT * FROM guests WHERE phone_number = $1',
      [phone]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Guest not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/guests - Créer un invité
app.post('/api/guests', authenticate, async (req, res) => {
  try {
    const { phone_number, guest_name, check_in_date, check_out_date } = req.body;

    // Validation
    if (!phone_number || !check_in_date || !check_out_date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Vérifier que check_out > check_in
    if (new Date(check_out_date) <= new Date(check_in_date)) {
      return res.status(400).json({ error: 'Check-out date must be after check-in date' });
    }

    // Insert ou Update si existe déjà
    const result = await pool.query(
      `INSERT INTO guests (phone_number, guest_name, check_in_date, check_out_date)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (phone_number)
       DO UPDATE SET
         guest_name = EXCLUDED.guest_name,
         check_in_date = EXCLUDED.check_in_date,
         check_out_date = EXCLUDED.check_out_date,
         updated_at = NOW()
       RETURNING *`,
      [phone_number, guest_name, check_in_date, check_out_date]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/conversations - Sauvegarder un message
app.post('/api/conversations', authenticate, async (req, res) => {
  try {
    const { phone_number, message, sender, timestamp } = req.body;

    if (!phone_number || !message || !sender) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    if (!['user', 'bot'].includes(sender)) {
      return res.status(400).json({ error: 'Sender must be "user" or "bot"' });
    }

    await pool.query(
      'INSERT INTO conversations (phone_number, message, sender, timestamp) VALUES ($1, $2, $3, $4)',
      [phone_number, message, sender, timestamp || new Date()]
    );

    res.status(201).json({ success: true });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/conversations/:phone - Récupérer l'historique
app.get('/api/conversations/:phone', authenticate, async (req, res) => {
  try {
    const { phone } = req.params;
    const limit = parseInt(req.query.limit) || 50;

    const result = await pool.query(
      `SELECT * FROM conversations
       WHERE phone_number = $1
       ORDER BY timestamp DESC
       LIMIT $2`,
      [phone, limit]
    );

    res.json(result.rows.reverse());
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`API listening on port ${PORT}`);
});
```

### Étape 3 : Créer `.env`

```bash
DATABASE_URL=postgresql://user:password@localhost:5432/airbnb_db
API_KEY=your-secret-api-key-here
NODE_ENV=development
PORT=3000
```

### Étape 4 : Déployer sur Render

1. Push votre code sur GitHub
2. Créez un nouveau **Web Service** sur [render.com](https://render.com)
3. Connectez votre repo GitHub
4. Ajoutez les variables d'environnement
5. Render détectera automatiquement Node.js et déploiera

### Étape 5 : Configurer N8N

```bash
N8N_DB_API_URL=https://your-app.onrender.com/api
API_KEY=your-secret-api-key-here
```

Dans les nœuds HTTP Request :
- **Authentication :** Header Auth
- **Name :** `x-api-key`
- **Value :** `={{ $env.API_KEY }}`

---

## Option 3 : Google Sheets (Simple mais Limité)

### Avantages
- ✅ Gratuit
- ✅ Aucun code backend
- ✅ Interface visuelle pour voir les données

### Inconvénients
- ❌ Plus lent
- ❌ Limité à 100 requêtes/100 secondes
- ❌ Pas de recherche optimisée

### Configuration

1. Créez deux Google Sheets :
   - **Guests** : colonnes `phone_number`, `guest_name`, `check_in_date`, `check_out_date`
   - **Conversations** : colonnes `phone_number`, `message`, `sender`, `timestamp`

2. Dans N8N, utilisez les nœuds **Google Sheets** :
   - `Google Sheets > Look Up` pour chercher un invité
   - `Google Sheets > Append` pour ajouter un message

3. Remplacez les nœuds HTTP Request par des nœuds Google Sheets

**Exemple pour Check Guest Exists :**
```json
{
  "type": "n8n-nodes-base.googleSheets",
  "operation": "lookupByValue",
  "sheetId": "your-sheet-id",
  "range": "Guests",
  "lookupColumn": "A",
  "lookupValue": "={{ $json.contacts[0].wa_id }}"
}
```

---

## 🧪 Tests Post-Déploiement

### Test 1 : API Health Check

```bash
curl https://your-api.com/health
# Expected: {"status": "ok", "timestamp": "..."}
```

### Test 2 : Créer un Invité de Test

```bash
curl -X POST https://your-api.com/api/guests \
  -H "Content-Type: application/json" \
  -H "x-api-key: your-key" \
  -d '{
    "phone_number": "33600000000",
    "guest_name": "Test User",
    "check_in_date": "2025-12-15",
    "check_out_date": "2025-12-20"
  }'
```

### Test 3 : Récupérer l'Invité

```bash
curl https://your-api.com/api/guests/33600000000 \
  -H "x-api-key: your-key"
```

### Test 4 : Test WhatsApp Complet

1. Envoyez un message WhatsApp au numéro configuré
2. Vérifiez dans N8N les exécutions (Executions tab)
3. Vérifiez dans la base de données que tout est sauvegardé

---

## 📊 Monitoring

### Logs N8N

Dans l'interface N8N :
- **Executions** : Voir toutes les exécutions
- Filtrer par "Error" pour voir les échecs

### Logs API (si Express.js)

Ajoutez un logger :

```bash
npm install winston
```

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// Utilisation
logger.info('Guest created', { phone_number, guest_name });
logger.error('Database error', { error: error.message });
```

### Dashboard Supabase

Si vous utilisez Supabase :
- **Database > Tables** : Voir les données
- **Database > Logs** : Voir les requêtes
- **Auth** : Si vous ajoutez l'authentification plus tard

---

## 🔒 Sécurité

### 1. API Keys

**NE JAMAIS** committer vos clés dans Git :

```bash
# .gitignore
.env
*.key
credentials.json
```

### 2. Rate Limiting (si Express.js)

```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 60, // 60 requêtes par minute
  message: 'Too many requests'
});

app.use('/api/', limiter);
```

### 3. HTTPS

Toujours utiliser HTTPS en production (Render et Supabase le font automatiquement)

### 4. Validation des Données

Utilisez un validateur comme `joi` ou `zod` :

```bash
npm install zod
```

```javascript
const { z } = require('zod');

const guestSchema = z.object({
  phone_number: z.string().min(10).max(20),
  guest_name: z.string().min(1).max(100),
  check_in_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  check_out_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/)
});

// Utilisation
try {
  const validated = guestSchema.parse(req.body);
  // Continue...
} catch (error) {
  return res.status(400).json({ error: error.errors });
}
```

---

## 🆘 Troubleshooting

### Problème : "Guest not found" alors qu'il existe

**Causes possibles :**
- Format du numéro de téléphone différent (+33 vs 33)
- Espaces dans le numéro
- Casse différente

**Solution :**
Normaliser les numéros :

```javascript
function normalizePhone(phone) {
  // Enlever tous les caractères non-numériques
  phone = phone.replace(/\D/g, '');

  // Enlever le + au début si présent
  if (phone.startsWith('33')) {
    return phone;
  }
  if (phone.startsWith('0')) {
    return '33' + phone.substring(1);
  }
  return phone;
}
```

### Problème : L'AI ne sauvegarde pas les dates

**Causes possibles :**
- Le prompt système n'est pas clair
- Les paramètres de l'outil sont mal configurés
- L'AI ne reçoit pas la confirmation

**Solution :**
- Vérifier le nœud "Tool: Save Guest Dates"
- Activer les logs de l'AI Agent
- Tester avec un message contenant clairement les deux dates

### Problème : Timeout OpenAI

**Causes possibles :**
- Contexte trop long
- Modèle surchargé

**Solution :**
- Réduire `contextWindowLength` à 10
- Augmenter le timeout dans les settings N8N
- Utiliser `gpt-4o-mini` au lieu de `gpt-4o`

---

## 📈 Optimisations

### 1. Cache Redis (Avancé)

Pour les invités fréquents :

```bash
npm install redis
```

```javascript
const redis = require('redis');
const client = redis.createClient({ url: process.env.REDIS_URL });

app.get('/api/guests/:phone', authenticate, async (req, res) => {
  const { phone } = req.params;

  // Check cache
  const cached = await client.get(`guest:${phone}`);
  if (cached) {
    return res.json(JSON.parse(cached));
  }

  // Query DB
  const result = await pool.query('SELECT * FROM guests WHERE phone_number = $1', [phone]);

  if (result.rows.length > 0) {
    // Store in cache for 1 hour
    await client.setEx(`guest:${phone}`, 3600, JSON.stringify(result.rows[0]));
    res.json(result.rows[0]);
  } else {
    res.status(404).json({ error: 'Not found' });
  }
});
```

### 2. CDN pour les Images

Si vous envoyez des images du chalet, utilisez Cloudflare Images ou Cloudinary

### 3. Backup Automatique

**Script de backup quotidien :**

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y-%m-%d)
pg_dump $DATABASE_URL > backups/backup-$DATE.sql
gzip backups/backup-$DATE.sql

# Upload to S3
aws s3 cp backups/backup-$DATE.sql.gz s3://your-bucket/backups/
```

**Cron job :**
```bash
0 2 * * * /path/to/backup.sh
```

---

## ✅ Checklist de Déploiement

- [ ] Base de données créée et tables initialisées
- [ ] API déployée et testée (health check OK)
- [ ] Variables d'environnement configurées dans N8N
- [ ] Workflow principal importé et activé
- [ ] Sous-workflows créés et connectés
- [ ] Credentials N8N configurés (OpenAI, WhatsApp, DB)
- [ ] Test avec un numéro de téléphone de test
- [ ] Vérification sauvegarde dans la base de données
- [ ] Monitoring activé (logs + alertes)
- [ ] Backup configuré

---

Vous êtes maintenant prêt ! 🎉

**Besoin d'aide ?** Consultez `AMELIORATIONS_WORKFLOW.md` pour plus de détails techniques.
