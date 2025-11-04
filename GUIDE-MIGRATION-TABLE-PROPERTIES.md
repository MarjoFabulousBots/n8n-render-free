# 🏗️ Guide de Migration : Table Properties pour Multi-Logements

Ce guide vous explique comment migrer vos nodes Code avec listes en dur vers une architecture scalable avec table Supabase.

---

## 📊 Vue d'ensemble de la migration

### ❌ AVANT : Listes codées en dur

**Code - Detect Property (New User)** et **Code - Detect Property (Main)** contiennent :
```javascript
const properties = [
  { id: 'anatole', names: ['logement_anatole', 'anatole'], code: 'LOGEMENT_ANATOLE' },
  { id: 'chalet_flocon', names: ['chalet flocon', 'flocon'], code: 'CHALET_FLOCON' }
];
// Boucle pour chercher dans le message
```

**Problèmes** :
- ❌ Modifier le code à chaque ajout de logement
- ❌ Non scalable au-delà de 10-20 logements
- ❌ Erreurs possibles (typos, doublons)

### ✅ APRÈS : Table Supabase

**Table `properties`** dans Supabase + **Node Supabase** dans n8n :
```
Nouveau logement → INSERT SQL → Disponible immédiatement
```

**Avantages** :
- ✅ Ajout de logement en 30 secondes (INSERT SQL)
- ✅ Scalable à l'infini (1000+ logements)
- ✅ Pas de modification du workflow n8n
- ✅ Gestion centralisée

---

## 🎯 Plan de migration en 4 étapes

### ÉTAPE 1 : Créer la table properties dans Supabase ⏱️ 5 minutes

1. **Ouvrir Supabase** → SQL Editor
2. **Copier-coller** le contenu de `SQL-CREATE-TABLE-PROPERTIES.sql`
3. **Cliquer "Run"** ▶️
4. **Vérifier** :
   ```sql
   SELECT * FROM properties;
   ```
   Devrait afficher : anatole et chalet_flocon

---

### ÉTAPE 2 : Ajouter le node de recherche dans n8n ⏱️ 10 minutes

#### A) Dans le workflow pour NOUVEAUX utilisateurs

**Ajouter entre** : "IF User Exists" → "Code - Detect Property (New User)"

**Nouveau node** : "Supabase - Search Property (New)"

**Configuration** :
- **Node Type** : Supabase
- **Operation** : Custom Query
- **Query** :
```sql
SELECT property_id, display_name
FROM search_property($1::text)
```
- **Query Parameters** : `{{ $json.message || $json.chatInput }}`

**Ou avec query directe** :
```sql
SELECT p.property_id, p.display_name
FROM properties p
WHERE p.active = true
  AND EXISTS (
    SELECT 1
    FROM unnest(p.names) AS name
    WHERE LOWER($1::text) LIKE '%' || LOWER(name) || '%'
  )
LIMIT 1;
```
- **Query Parameters** : `{{ $json.message || $json.chatInput }}`

#### B) Dans le workflow pour utilisateurs EXISTANTS

**Ajouter entre** : "Merge User Data" → "Code - Detect Property (Main)"

**Nouveau node** : "Supabase - Search Property (Main)"

**Même configuration que ci-dessus**

---

### ÉTAPE 3 : Simplifier les nodes Code ⏱️ 15 minutes

#### A) Modifier "Code - Detect Property (New User)"

**AVANT (60 lignes)** :
```javascript
const message = $node['When chat message received'].json.chatInput.toLowerCase();

const properties = [
  { id: 'anatole', names: ['logement_anatole', 'anatole'], code: 'LOGEMENT_ANATOLE' },
  { id: 'chalet_flocon', names: ['chalet flocon', 'flocon'], code: 'CHALET_FLOCON' }
];

let detectedProperty = null;

for (const prop of properties) {
  for (const name of prop.names) {
    if (message.includes(name.toLowerCase())) {
      detectedProperty = prop.id;
      break;
    }
  }
  if (detectedProperty) break;
}

return {
  property_id: detectedProperty,
  message: $node['When chat message received'].json.chatInput,
  num_whatsapp: $node['When chat message received'].json.sessionId
};
```

**APRÈS (10 lignes)** :
```javascript
// Récupérer le résultat de la recherche Supabase
const searchResult = $('Supabase - Search Property (New)').first()?.json;

return {
  property_id: searchResult?.property_id || null,
  display_name: searchResult?.display_name || null,
  message: $node['When chat message received'].json.chatInput,
  num_whatsapp: $node['When chat message received'].json.sessionId
};
```

**Réduction : 60 lignes → 10 lignes** ✅

#### B) Modifier "Code - Detect Property (Main)"

**AVANT (80 lignes)** :
```javascript
const originalMessage = $('When chat message received').first().json.chatInput;
const message = originalMessage?.toLowerCase() || '';

const userData = $input.first().json;

const properties = [
  { id: 'anatole', names: ['logement_anatole', 'anatole', 'appartement anatole'], code: 'LOGEMENT_ANATOLE' },
  { id: 'paris_center', names: ['logement_paris', 'paris', 'centre paris'], code: 'LOGEMENT_PARIS' },
  { id: 'bordeaux_villa', names: ['logement_bordeaux', 'bordeaux', 'villa bordeaux'], code: 'LOGEMENT_BORDEAUX' }
];

let detectedProperty = null;

if (userData.property_id) {
  detectedProperty = userData.property_id;
} else {
  for (const prop of properties) {
    for (const name of prop.names) {
      if (message.includes(name.toLowerCase())) {
        detectedProperty = prop.id;
        break;
      }
    }
    if (detectedProperty) break;
  }
}

return {
  property_id: detectedProperty,
  detected: detectedProperty !== null,
  message: originalMessage,
  user_id: userData.id,
  num_whatsapp: userData.num_whatsapp,
  conversation_state: userData.conversation_state,
  date_arrivee: userData.date_arrivee,
  date_depart: userData.date_depart
};
```

**APRÈS (20 lignes)** :
```javascript
const originalMessage = $('When chat message received').first().json.chatInput;
const userData = $input.first().json;

// Récupérer le property_id : soit depuis userData, soit depuis la recherche
let detectedProperty = null;
let displayName = null;

if (userData.property_id) {
  // L'utilisateur a déjà un property_id enregistré
  detectedProperty = userData.property_id;
} else {
  // Chercher dans la table properties via Supabase
  const searchResult = $('Supabase - Search Property (Main)').first()?.json;
  detectedProperty = searchResult?.property_id || null;
  displayName = searchResult?.display_name || null;
}

return {
  property_id: detectedProperty,
  detected: detectedProperty !== null,
  display_name: displayName,
  message: originalMessage,
  user_id: userData.id,
  num_whatsapp: userData.num_whatsapp,
  conversation_state: userData.conversation_state,
  date_arrivee: userData.date_arrivee,
  date_depart: userData.date_depart
};
```

**Réduction : 80 lignes → 20 lignes** ✅

---

### ÉTAPE 4 : Tester la migration ⏱️ 10 minutes

#### Test 1 : Détection avec "anatole"

**Utilisateur** : "Je cherche le logement anatole"

**Vérifications** :
1. Node "Supabase - Search Property" retourne :
   ```json
   {
     "property_id": "anatole",
     "display_name": "Logement Anatole"
   }
   ```
2. Node "Code - Detect Property" retourne :
   ```json
   {
     "property_id": "anatole",
     "detected": true
   }
   ```
3. Bot répond avec la FAQ de anatole ✅

#### Test 2 : Détection avec "chalet flocon"

**Utilisateur** : "Je veux réserver le chalet flocon"

**Vérifications** :
1. Node "Supabase - Search Property" retourne :
   ```json
   {
     "property_id": "chalet_flocon",
     "display_name": "Chalet Flocon"
   }
   ```
2. Node "Code - Detect Property" retourne :
   ```json
   {
     "property_id": "chalet_flocon",
     "detected": true
   }
   ```
3. Bot répond avec la FAQ de chalet_flocon ✅

#### Test 3 : Détection avec variante

**Utilisateur** : "Logement à Val Thorens"

**Vérifications** :
1. Devrait détecter `chalet_flocon` (car "val thorens" est dans les names)
2. Bot répond correctement ✅

#### Test 4 : Logement inexistant

**Utilisateur** : "Je cherche la villa à Nice"

**Vérifications** :
1. Node "Supabase - Search Property" retourne : `(vide)`
2. Node "Code - Detect Property" retourne :
   ```json
   {
     "property_id": null,
     "detected": false
   }
   ```
3. Bot demande de préciser le logement ✅

---

## 📐 Schéma du workflow modifié

### Pour NOUVEAUX utilisateurs

```
When chat message received
  ↓
Supabase - Get User
  ↓
IF User Exists → FALSE
  ↓
Supabase - Search Property (New) ← NOUVEAU NODE
  ↓
Code - Detect Property (New User) ← SIMPLIFIÉ (10 lignes)
  ↓
Supabase - Create User
  ↓
...
```

### Pour utilisateurs EXISTANTS

```
When chat message received
  ↓
Supabase - Get User
  ↓
IF User Exists → TRUE
  ↓
Merge User Data
  ↓
Supabase - Search Property (Main) ← NOUVEAU NODE
  ↓
Code - Detect Property (Main) ← SIMPLIFIÉ (20 lignes)
  ↓
IF Property Detected
  ↓
...
```

---

## 🚀 Ajouter un nouveau logement (après migration)

**Avant la migration** :
1. Ouvrir n8n
2. Trouver le node "Code - Detect Property (Main)"
3. Modifier le code JavaScript
4. Ajouter `{ id: 'nouveau', names: [...], code: '...' }`
5. Sauvegarder
6. Redéployer le workflow
⏱️ **10 minutes + risque d'erreur**

**Après la migration** :
1. Ouvrir Supabase → SQL Editor
2. Exécuter :
```sql
INSERT INTO properties (property_id, names, display_name) VALUES
  (
    'villa_nice',
    ARRAY['villa nice', 'nice', 'côte azur', 'villa côte d''azur'],
    'Villa Nice Côte d''Azur'
  );
```
3. C'est tout ! ✅
⏱️ **30 secondes + zéro risque d'erreur**

---

## 📊 Comparaison Avant/Après

| Aspect | Avant (code en dur) | Après (table properties) |
|--------|---------------------|--------------------------|
| **Ajout logement** | 10 min (modifier code n8n) | 30 sec (INSERT SQL) |
| **Risque d'erreur** | Élevé (erreur JS) | Faible (erreur SQL visible) |
| **Scalabilité** | Max 50 logements | Illimité (1000+) |
| **Maintenance** | 1 personne (dev n8n) | Toute l'équipe (SQL simple) |
| **Rollback** | Difficile (git) | Facile (UPDATE/DELETE SQL) |
| **Performance** | O(n) boucles JS | O(1) index SQL |
| **Lisibilité** | 80 lignes de code | 20 lignes de code |

---

## ⚠️ Points d'attention

### 1. Ne pas oublier le filtre property_id

Le node **"Supabase - Get Property FAQ"** doit avoir un filtre :
```
WHERE property_id = {{ $('Code - Detect Property (Main)').first().json.property_id }}
```

Sinon le bot récupérera TOUS les logements mélangés !

### 2. Tester avec les deux workflows

- **Nouvel utilisateur** : Test avec un nouveau `sessionId`
- **Utilisateur existant** : Test avec un `sessionId` déjà en base

### 3. Backup avant migration

Faites un backup de votre workflow n8n avant de modifier :
- Exporter le JSON du workflow
- Sauvegarder dans un fichier `workflow-backup-YYYY-MM-DD.json`

---

## ✅ Checklist de migration

### Avant de commencer
- [ ] Backup du workflow n8n actuel
- [ ] Lecture complète du guide
- [ ] Préparation du script SQL

### Étape 1 : Table properties
- [ ] Script SQL exécuté dans Supabase
- [ ] Vérification : `SELECT * FROM properties;` retourne 2 lignes
- [ ] Test fonction : `SELECT * FROM search_property('chalet');` retourne chalet_flocon

### Étape 2 : Nodes Supabase
- [ ] Node "Supabase - Search Property (New)" ajouté
- [ ] Node "Supabase - Search Property (Main)" ajouté
- [ ] Connexions correctement configurées

### Étape 3 : Nodes Code
- [ ] "Code - Detect Property (New User)" simplifié
- [ ] "Code - Detect Property (Main)" simplifié
- [ ] Pas d'erreurs de syntaxe JavaScript

### Étape 4 : Tests
- [ ] Test détection "anatole" ✅
- [ ] Test détection "chalet flocon" ✅
- [ ] Test détection "val thorens" ✅
- [ ] Test logement inexistant ✅
- [ ] FAQ correcte retournée pour chaque logement ✅

### Après migration
- [ ] Workflow sauvegardé
- [ ] Documentation mise à jour
- [ ] Équipe informée de la nouvelle procédure d'ajout de logements

---

## 🆘 Rollback en cas de problème

Si la migration pose problème, vous pouvez revenir en arrière :

1. **Restaurer le workflow** :
   - Importer le backup JSON dans n8n
   - Activer le workflow restauré

2. **Garder la table properties** :
   - Elle ne gêne pas même si non utilisée
   - Vous pourrez retenter plus tard

3. **Supprimer la table properties** (optionnel) :
   ```sql
   DROP TABLE IF EXISTS properties CASCADE;
   DROP FUNCTION IF EXISTS search_property(TEXT);
   ```

---

## 📞 Support

En cas de question sur la migration :
1. Relire ce guide
2. Consulter `ARCHITECTURE-MULTI-LOGEMENTS.md` pour comprendre le pourquoi
3. Vérifier les logs n8n en mode debug

---

Bon courage pour la migration ! 🚀

Une fois terminée, vous pourrez ajouter 100 logements en quelques minutes ! 💪
