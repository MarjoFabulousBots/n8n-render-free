# 🔧 Configuration des Tools pour Database N8N

## ⚠️ IMPORTANT

Les sub-workflows que j'ai créés (`sub-workflow-save-guest-db-n8n.json` et `sub-workflow-save-conversation-db-n8n.json`) **ne fonctionneront PAS directement** car ils contiennent des nœuds placeholder.

**SOLUTION SIMPLE :** Transforme tes tools en **Tools Database directs** au lieu d'utiliser des sub-workflows.

---

## 🎯 Configuration Tool "save_guest_dates"

### Étape 1 : Supprime le tool actuel

Supprime le nœud tool "save_guest_dates" actuel (type `toolWorkflow`).

### Étape 2 : Ajoute un nouveau tool

**Type de nœud :** Cherche dans la liste des tools AI un tool de type **Database** ou crée un nœud custom.

**Si ton N8N a un "Tool Database N8N" :**
1. Ajoute ce nœud
2. Configure :
   - **Name :** `save_guest_dates`
   - **Description :**
     ```
     🚨 OBLIGATOIRE : Enregistrer un nouveau voyageur avec ses dates de séjour.

     QUAND l'utiliser :
     - Dès que vous détectez une date d'arrivée ET une date de départ
     - Exemple : "J'arrive demain pour 3 jours" → calculer les dates → APPELER CE TOOL

     Paramètres requis :
     - check_in_date : Format YYYY-MM-DD (ex: 2025-12-15)
     - check_out_date : Format YYYY-MM-DD (ex: 2025-12-20)
     ```
   - **Operation :** `upsert`
   - **Table :** `voyageurs`
   - **Colonnes à mapper :**
     - `phone_number` : `={{ $('WhatsApp Trigger').item.json.contacts[0].wa_id }}`
     - `check_in_date` : `={{ $fromAI('check_in_date', 'Date arrivée YYYY-MM-DD', 'string') }}`
     - `check_out_date` : `={{ $fromAI('check_out_date', 'Date départ YYYY-MM-DD', 'string') }}`

3. **Connecte via `ai_tool`** à l'AI Agent

---

## 🎯 Alternative : Utiliser Tool Code

**Si pas de "Tool Database N8N" disponible :**

### Créer un Tool Code

1. Ajoute un nœud **"Tool Code"** ou **"Tool Function"**
2. Configure :

```javascript
const phone_number = $('WhatsApp Trigger').item.json.contacts[0].wa_id;
const check_in_date = $fromAI('check_in_date', 'Date YYYY-MM-DD', 'string');
const check_out_date = $fromAI('check_out_date', 'Date YYYY-MM-DD', 'string');

// Validation
if (!check_in_date || !check_out_date) {
  return { error: 'Dates manquantes' };
}

if (!/^\d{4}-\d{2}-\d{2}$/.test(check_in_date) || !/^\d{4}-\d{2}-\d{2}$/.test(check_out_date)) {
  return { error: 'Format invalide. Utilisez YYYY-MM-DD' };
}

// Appeler le nœud Database N8N via une connexion interne
// (Cette partie dépend de la façon dont N8N gère les appels internes)

return {
  success: true,
  message: 'Dates enregistrées',
  phone_number,
  check_in_date,
  check_out_date
};
```

---

## 🎯 Solution Temporaire Simple

**En attendant de configurer correctement les tools :**

### Supprime les tools de sauvegarde

1. **Supprime** le tool "save_guest_dates"
2. **Supprime** le tool "save_conversation"

### Sauvegarde manuelle après l'AI Agent

**Flux :**
```
AI Agent → Nœud DB "Upsert Voyageur" → Nœud DB "Insert Conversation"
```

**Nœud "Upsert Voyageur" :**
- Type : Database N8N
- Operation : `upsert`
- Table : `voyageurs`
- Colonnes :
  - `phone_number` : `={{ $('WhatsApp Trigger').item.json.contacts[0].wa_id }}`
  - `check_in_date` : Extraire manuellement depuis `$json.output` de l'AI Agent
  - `check_out_date` : Idem

**Problème :** L'AI ne structure pas sa réponse, donc difficile d'extraire les dates.

---

## ✅ Recommandation Finale

**OPTION LA PLUS SIMPLE :**

1. **Garde le workflow actuel** sans les tools de sauvegarde
2. **L'AI collecte les dates** via dialogue
3. **Toi, manuellement**, tu ajoutes les dates dans la DB après validation

**OU**

**Demande à l'AI de retourner un JSON structuré :**

Dans le prompt système, ajoute :

```
## FORMAT DE RÉPONSE POUR NOUVEAUX VOYAGEURS

Quand vous collectez les dates, TERMINEZ votre réponse par ce JSON (sur une nouvelle ligne) :

```json
{
  "action": "save_guest",
  "check_in_date": "YYYY-MM-DD",
  "check_out_date": "YYYY-MM-DD"
}
```

Exemple :
"Parfait ! J'ai noté votre séjour du 15/12 au 20/12.

```json
{"action": "save_guest", "check_in_date": "2025-12-15", "check_out_date": "2025-12-20"}
```"
```

Puis ajoute un nœud **Extract JSON** après l'AI Agent qui parse cette structure et insère en DB.

---

## 🆘 Besoin d'Aide ?

**Dis-moi :**
1. Est-ce que tu as un nœud "Tool Database N8N" dans ta liste de tools AI ?
2. Ou préfères-tu la solution avec JSON structuré ?

Je t'aide à configurer la solution choisie.
