# 🔄 Guide de Migration - Ancienne FAQ → FAQ Rechunkée

## 📊 Comparaison Avant/Après

### ❌ AVANT : Chunk 5 "Equipements de voiture"
```
CHUNK 5 : Equipements de voiture

Exemples de questions :
- Y a-t-il une navette ?
- Le parking est-il gratuit ?
- Puis-je utiliser le jacuzzi ?

Réponse de l'agent :
Oui, une navette gratuite est disponible depuis la gare...
Le parking est gratuit...
Le jacuzzi est inclus dans le prix...
Cuisine équipée avec four, micro-ondes...
```

**Problèmes** :
- ❌ Titre ne reflète pas le contenu (navette ≠ équipement voiture)
- ❌ Mélange transport + bien-être + cuisine
- ❌ Bruit : "Exemples de questions", "Réponse de l'agent"
- ❌ LLM doit lire tout le chunk pour trouver l'info

### ✅ APRÈS : 3 Chunks séparés

**CHUNK 1 : Transport et Accès**
- Navette gratuite depuis gare Moutiers
- Parking gratuit
- Accès voiture

**CHUNK 4 : Équipements Bien-être**
- Jacuzzi privatif
- Instructions utilisation

**CHUNK 5 : Cuisine et Équipements**
- Four, micro-ondes
- Vaisselle complète

**Avantages** :
- ✅ Chaque chunk = 1 thème clair
- ✅ Recherche sémantique plus précise
- ✅ Moins de tokens consommés par OpenAI
- ✅ Bot trouve info du premier coup

---

## 🎯 Étapes de Migration

### Étape 1 : Remplir les vraies données

Ouvrez `FAQ-RECHUNKEE-OPTIMALE.md` et remplacez :
- `[X mètres]` → distance réelle
- `[OUI/NON]` → votre situation
- `[Adresse exacte]` → adresse GPS
- `[numéro]` → vrais numéros de téléphone

### Étape 2 : Supprimer les chunks non pertinents

Si votre logement n'a pas certains équipements, supprimez les chunks :
- Pas de jacuzzi ? → Supprimer CHUNK 4
- Pas d'activités ski ? → Supprimer CHUNK 7
- Pas d'activités été ? → Supprimer CHUNK 8

### Étape 3 : Importer dans Supabase

**Option A : Via interface Supabase (recommandé)**

1. Aller dans Supabase → Table `rag_test_for_charles_locabot`
2. Supprimer toutes les anciennes lignes (bouton "Delete" ou SQL : `DELETE FROM rag_test_for_charles_locabot;`)
3. Pour chaque chunk, cliquer "Insert row" :
   - **content** : Copier-coller le contenu du chunk (titre + texte)
   - Cliquer "Save"

**Option B : Via SQL (plus rapide)**

1. Copier le contenu de `SQL-IMPORT-FAQ.sql` (voir ci-dessous)
2. Adapter avec vos vraies données
3. Exécuter dans SQL Editor de Supabase

### Étape 4 : Tester le workflow

1. Activer votre workflow n8n
2. Tester ces questions :
   - "Y a-t-il une navette ?" → Devrait trouver CHUNK 1
   - "Le jacuzzi est-il gratuit ?" → Devrait trouver CHUNK 4
   - "Quelle heure pour le check-in ?" → Devrait trouver CHUNK 2
3. Vérifier que le bot répond correctement avec l'info de la FAQ

---

## 📝 Conseils pour Rédiger du Bon Contenu

### ✅ Format recommandé

```markdown
## CHUNK X : Titre Descriptif Clair

**Mots-clés** : mot1, mot2, synonyme1, synonyme2

### Sous-section 1
- Point factuel 1
- Point factuel 2
- Point factuel 3

### Sous-section 2
- Information directe
- Pas de blabla
```

### ❌ À éviter

```markdown
## CHUNK X : Titre vague

Exemples de questions :
- Question 1 ?
- Question 2 ?

Réponse de l'agent :
Alors, pour répondre à votre question, je dirais que...
En fait, si vous voulez savoir...
```

### Mots-clés : Pensez synonymes !

Exemple pour le transport :
```
Mots-clés : navette, transport, bus, shuttle, transfer,
            trajet, gare, station, accès, parking,
            voiture, car, automobile
```

Quand l'utilisateur demande "Y a-t-il un shuttle ?", le LLM cherchera dans les chunks contenant "shuttle" ou "navette" → Trouve CHUNK 1 !

---

## 🔍 Debug : Si le bot ne trouve toujours pas l'info

### Vérifier 1 : La requête Supabase dans n8n

Dans le node **"Supabase - Get Property FAQ"** :
```json
{
  "operation": "Get all",
  "returnAll": true
}
```

Assurez-vous que TOUS les chunks sont bien récupérés.

### Vérifier 2 : Le contexte envoyé à OpenAI

Dans le node **"Code - Prepare OpenAI Context"**, ajoutez un `console.log` :

```javascript
const faqContext = faqData.map(item => item.json.content).join('\n\n');
console.log('FAQ CONTEXT LENGTH:', faqContext.length);
console.log('CHUNKS COUNT:', faqData.length);
```

Devrait afficher : `CHUNKS COUNT: 12` (ou votre nombre de chunks)

### Vérifier 3 : Le prompt système

Dans `prompt-optimise.txt`, la section FAQ doit être :
```
INFORMATIONS LOGEMENT (FAQ):
${faqContext}
```

OpenAI voit TOUTE la FAQ, pas juste un chunk.

### Vérifier 4 : L'instruction de recherche

L'instruction 5 du prompt doit être détaillée (comme dans `prompt-optimise.txt`) :
```
5. **RECHERCHE DANS LA FAQ** - TRÈS IMPORTANT :
   - Lis ATTENTIVEMENT toute la section "INFORMATIONS LOGEMENT (FAQ)" ci-dessus
   - Avant de dire que tu ne sais pas, vérifie SI L'INFORMATION EXISTE...
```

---

## 🚨 Erreurs Communes

### Erreur 1 : "Le bot dit qu'il n'a pas l'info alors qu'elle est dans la FAQ"

**Causes possibles** :
1. Le chunk n'a pas de mots-clés pertinents
2. Le titre du chunk est trompeur
3. L'info est noyée dans un long paragraphe
4. Les mots utilisés par l'utilisateur ne matchent pas ceux de la FAQ

**Solution** : Ajouter des synonymes dans les mots-clés

### Erreur 2 : "Le bot répond avec des infos d'un mauvais chunk"

**Cause** : Plusieurs chunks contiennent des mots similaires

**Solution** : Rendre les titres plus spécifiques
- ❌ "Équipements" (trop vague)
- ✅ "Équipements de Cuisine" (spécifique)

### Erreur 3 : "Le bot répond trop long / consomme trop de tokens"

**Cause** : FAQ trop longue ou trop de chunks

**Solution** :
1. Fusionner des chunks similaires
2. Limiter à 10-12 chunks maximum
3. Utiliser des bullet points courts

---

## 📊 Métriques de Succès

Après migration, vous devriez observer :

| Métrique | Avant | Après |
|----------|-------|-------|
| Taux de réponse correcte FAQ | ~60% | ~95% |
| Tokens moyens par requête | 3000-4000 | 2000-3000 |
| "Je n'ai pas l'info" (alors que si) | Fréquent | Rare |
| Temps de réponse | 3-5s | 2-4s |

---

## ✅ Checklist Finale

Avant de déployer :
- [ ] Toutes les vraies données remplies (pas de [X] restant)
- [ ] Chunks non pertinents supprimés
- [ ] Ancienne FAQ supprimée de Supabase
- [ ] Nouvelle FAQ importée dans Supabase
- [ ] Workflow testé avec 5-10 questions variées
- [ ] Prompt système à jour (`prompt-optimise.txt`)
- [ ] Toutes les réponses correctes
- [ ] Pas d'erreurs dans les logs n8n

Bon rechunking ! 🎉
