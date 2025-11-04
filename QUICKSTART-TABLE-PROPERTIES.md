# 🚀 Quick Start : Table Properties

Guide ultra-rapide pour migrer vers la table `properties`.

---

## ⏱️ Temps estimé : 30 minutes

---

## 📋 Étape 1 : Créer la table (5 min)

1. **Ouvrir Supabase** → SQL Editor
2. **Copier-coller** tout le contenu de `SQL-CREATE-TABLE-PROPERTIES.sql`
3. **Run** ▶️
4. **Vérifier** :
   ```sql
   SELECT * FROM properties;
   ```
   → Doit afficher : anatole et chalet_flocon ✅

---

## 🔧 Étape 2 : Ajouter 2 nodes Supabase dans n8n (10 min)

### Node 1 : Pour NOUVEAUX utilisateurs

**Position** : Entre "IF User Exists" (sortie FALSE) et "Code - Detect Property (New User)"

**Nom** : `Supabase - Search Property (New)`

**Configuration** :
- Type : Supabase
- Operation : Custom Query
- Query :
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
- Query Parameters : `{{ $json.message || $json.chatInput }}`

### Node 2 : Pour utilisateurs EXISTANTS

**Position** : Entre "Merge User Data" et "Code - Detect Property (Main)"

**Nom** : `Supabase - Search Property (Main)`

**Configuration** : Identique au Node 1

---

## 💻 Étape 3 : Simplifier les nodes Code (15 min)

### A) "Code - Detect Property (New User)"

**Remplacer tout le code par** :
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

### B) "Code - Detect Property (Main)"

**Remplacer tout le code par** :
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

---

## ✅ Étape 4 : Tester (5 min)

**Test 1** : "Je cherche le logement anatole"
→ Doit détecter `anatole` ✅

**Test 2** : "Je veux le chalet flocon"
→ Doit détecter `chalet_flocon` ✅

**Test 3** : "Logement à Val Thorens"
→ Doit détecter `chalet_flocon` ✅

---

## 🎉 C'est fait !

Maintenant pour ajouter un logement :

```sql
INSERT INTO properties (property_id, names, display_name) VALUES
  (
    'villa_nice',
    ARRAY['villa nice', 'nice', 'côte azur'],
    'Villa Nice'
  );
```

**30 secondes** au lieu de 10 minutes ! 🚀

---

## 📚 Ressources

- **Guide complet** : `GUIDE-MIGRATION-TABLE-PROPERTIES.md`
- **Architecture détaillée** : `ARCHITECTURE-MULTI-LOGEMENTS.md`
- **Script SQL** : `SQL-CREATE-TABLE-PROPERTIES.sql`

---

## 🆘 Problème ?

**Node Supabase ne retourne rien** :
→ Vérifier que les `names` dans la table contiennent bien les variantes

**Erreur SQL** :
→ Vérifier les guillemets simples échappés (`''` au lieu de `'`)

**Code JavaScript erreur** :
→ Copier-coller exactement le code du guide

---

Bon courage ! 💪
