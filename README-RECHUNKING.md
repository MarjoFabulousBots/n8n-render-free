# 🎯 Guide Complet : Rechunking de votre FAQ Airbnb

Ce guide vous accompagne étape par étape pour migrer de votre ancienne FAQ vers la nouvelle FAQ rechunkée et optimisée.

---

## 📁 Fichiers créés pour vous

| Fichier | Description | Utilité |
|---------|-------------|---------|
| `FAQ-RECHUNKEE-OPTIMALE.md` | Structure complète de la FAQ rechunkée | Template à remplir avec vos vraies données |
| `SQL-IMPORT-FAQ.sql` | Script SQL prêt à l'emploi | Import direct dans Supabase |
| `GUIDE-MIGRATION-FAQ.md` | Guide détaillé de migration | Instructions pas à pas |
| `EXEMPLES-AVANT-APRES.md` | Exemples concrets de conversations | Comprendre l'amélioration |
| `README-RECHUNKING.md` | Ce fichier | Vue d'ensemble et checklist |

---

## 🚀 Plan d'Action en 5 Étapes

### ✅ ÉTAPE 1 : Préparer votre FAQ (30 minutes)

1. **Ouvrir** : `FAQ-RECHUNKEE-OPTIMALE.md`

2. **Remplir les vraies données** : Remplacer tous les placeholders
   - `[X mètres]` → Distance réelle (ex: "500 mètres", "5 minutes à pied")
   - `[OUI/NON]` → Votre situation (ex: "OUI" pour animaux autorisés)
   - `[Adresse exacte]` → Adresse GPS complète
   - `[NOMBRE]` → Nombre de personnes (ex: "8 personnes")
   - `[NOM SSID]` → Nom de votre réseau WiFi
   - `[NUMÉRO]` → Vos numéros de téléphone
   - `[MONTANT]` → Montant de la caution

3. **Supprimer les chunks non pertinents** :
   - Pas de jacuzzi ? → Supprimer CHUNK 4
   - Pas de pistes de ski à proximité ? → Supprimer CHUNK 7
   - Pas d'activités été ? → Supprimer CHUNK 8

4. **Vérifier** : Chaque chunk doit contenir :
   - ✅ Un titre clair et descriptif
   - ✅ Une ligne "Mots-clés" avec synonymes
   - ✅ Des bullet points factuels (pas de blabla)
   - ✅ Aucun placeholder restant

**Conseil** : Gardez les chunks courts (100-200 mots maximum par chunk)

---

### ✅ ÉTAPE 2 : Préparer le script SQL (15 minutes)

1. **Ouvrir** : `SQL-IMPORT-FAQ.sql`

2. **Copier le contenu depuis votre FAQ remplie** :
   - Copier chaque chunk de `FAQ-RECHUNKEE-OPTIMALE.md`
   - Coller dans le INSERT correspondant de `SQL-IMPORT-FAQ.sql`

3. **Vérifier** : Les guillemets simples doivent être échappés
   - `d'arrivée` → `d''arrivée` (double guillemet simple en SQL)
   - `l'été` → `l''été`

4. **Supprimer les INSERT** pour les chunks non pertinents

**Exemple** :
```sql
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 1 : Transport et Accès au Logement

Mots-clés : navette, transport, bus, parking, voiture, accès

Navette gratuite :
- Navette GRATUITE depuis la gare de Moutiers
- Sur réservation : contacter au 06 12 34 56 78

Parking :
- Parking gratuit sur place
- 10 places sécurisées'
);
```

---

### ✅ ÉTAPE 3 : Backup de l'ancienne FAQ (5 minutes)

**IMPORTANT** : Avant de supprimer, sauvegardez !

1. **Aller dans Supabase** → Table `rag_test_for_charles_locabot`

2. **Exporter l'ancienne FAQ** :
   - SQL Editor → Nouvelle query
   - Exécuter :
   ```sql
   SELECT * FROM rag_test_for_charles_locabot;
   ```
   - Copier les résultats → Sauvegarder dans un fichier `FAQ_BACKUP_2025-11-04.txt`

3. **OU** utiliser l'export CSV de Supabase :
   - Table → Export → CSV

**Pourquoi ?** Au cas où vous auriez besoin de revenir en arrière.

---

### ✅ ÉTAPE 4 : Importer dans Supabase (10 minutes)

**Option A : Via SQL Editor (recommandé - plus rapide)**

1. **Aller dans Supabase** → SQL Editor

2. **Copier-coller** tout le contenu de votre `SQL-IMPORT-FAQ.sql` modifié

3. **Cliquer "Run"**

4. **Vérifier** : La requête finale devrait afficher
   ```
   total_chunks: 12
   (ou votre nombre de chunks)
   ```

**Option B : Via interface Supabase (plus lent)**

1. **Aller dans Supabase** → Table `rag_test_for_charles_locabot`

2. **Supprimer toutes les lignes** :
   - Sélectionner toutes → Delete

3. **Pour chaque chunk** :
   - Cliquer "Insert row"
   - Champ `content` → Coller le contenu du chunk
   - Cliquer "Save"
   - Répéter 12 fois

---

### ✅ ÉTAPE 5 : Tester le workflow (20 minutes)

1. **Activer votre workflow n8n**

2. **Tester ces 10 questions** (une par une) :

| # | Question | Chunk attendu | Devrait trouver ? |
|---|----------|---------------|-------------------|
| 1 | "Y a-t-il une navette ?" | CHUNK 1 | ✅ OUI |
| 2 | "C'est gratuit la navette ?" | CHUNK 1 | ✅ OUI |
| 3 | "À quelle heure le check-in ?" | CHUNK 2 | ✅ OUI |
| 4 | "Le jacuzzi est payant ?" | CHUNK 4 | ✅ OUI (si vous avez ce chunk) |
| 5 | "Y a-t-il une cuisine équipée ?" | CHUNK 5 | ✅ OUI |
| 6 | "Les draps sont fournis ?" | CHUNK 6 | ✅ OUI |
| 7 | "C'est loin des pistes ?" | CHUNK 7 | ✅ OUI (si vous avez ce chunk) |
| 8 | "Quel est le mot de passe WiFi ?" | CHUNK 10 | ✅ OUI |
| 9 | "Les animaux sont autorisés ?" | CHUNK 11 | ✅ OUI |
| 10 | "J'ai un problème de chauffage" | CHUNK 12 | ✅ OUI |

3. **Pour chaque question** :
   - ✅ Le bot trouve l'info dans la FAQ
   - ✅ La réponse est complète et correcte
   - ✅ Pas de message "Je n'ai pas cette information"

4. **Vérifier les logs n8n** :
   - Aucun node en erreur
   - "Code - Prepare OpenAI Context" reçoit bien TOUTE la FAQ
   - "Supabase - Get Property FAQ" retourne bien tous les chunks

---

## 🔍 Troubleshooting : Problèmes courants

### ❌ Problème 1 : "Le bot dit qu'il n'a pas l'info alors qu'elle est dans la FAQ"

**Causes possibles** :
1. Le chunk n'a pas été importé dans Supabase
2. Le titre du chunk est trop vague
3. Pas assez de mots-clés

**Solution** :
1. Vérifier dans Supabase que le chunk existe bien
2. Ajouter des synonymes dans les mots-clés
3. Rendre le titre plus descriptif

**Exemple** :
```
❌ Titre trop vague : "Équipements"
✅ Titre clair : "Équipements de Cuisine"
```

---

### ❌ Problème 2 : Erreur SQL lors de l'import

**Erreur** : `syntax error at or near "d"`

**Cause** : Guillemet simple non échappé

**Solution** : Échapper tous les guillemets simples
```sql
-- ❌ INCORRECT
'l'arrivée'

-- ✅ CORRECT
'l''arrivée'
```

**Astuce** : Utilisez un éditeur de texte avec "Rechercher/Remplacer"
- Rechercher : `'`
- Remplacer par : `''`
- **ATTENTION** : Ne remplacez pas les guillemets au début/fin des INSERT !

---

### ❌ Problème 3 : "Supabase - Get Property FAQ" ne retourne rien

**Cause** : Mauvaise configuration du node Supabase

**Solution** :
1. Vérifier le node **"Supabase - Get Property FAQ"** dans n8n
2. Configuration devrait être :
   ```json
   {
     "operation": "Get all",
     "table": "rag_test_for_charles_locabot",
     "returnAll": true
   }
   ```
3. Pas de filtres (WHERE) configurés

---

### ❌ Problème 4 : Le bot répond trop long ou hors sujet

**Cause** : Trop de chunks ou chunks trop longs

**Solution** :
1. Limiter à 10-12 chunks maximum
2. Chaque chunk max 200 mots
3. Fusionner les chunks trop similaires

**Exemple** :
```
❌ 2 chunks séparés :
- CHUNK 5 : Cuisine
- CHUNK 6 : Électroménager

✅ 1 chunk fusionné :
- CHUNK 5 : Cuisine et Équipements
```

---

### ❌ Problème 5 : Erreur "invalid input syntax for type timestamp"

**Cause** : Champ `created_at` mal formaté

**Solution** : Supprimer le champ `created_at` du INSERT (Supabase le génère auto)

**Dans votre SQL** :
```sql
-- ❌ NE PAS faire ça
INSERT INTO rag_test_for_charles_locabot (content, created_at) VALUES (...);

-- ✅ FAIRE ça
INSERT INTO rag_test_for_charles_locabot (content) VALUES (...);
```

---

## 📊 Checklist Finale

Avant de considérer la migration terminée :

### Préparation
- [ ] FAQ-RECHUNKEE-OPTIMALE.md remplie (aucun [X] restant)
- [ ] SQL-IMPORT-FAQ.sql adapté avec mes vraies données
- [ ] Guillemets simples échappés (`l'été` → `l''été`)
- [ ] Chunks non pertinents supprimés
- [ ] Backup de l'ancienne FAQ créé

### Import
- [ ] Ancienne FAQ supprimée de Supabase
- [ ] Nouvelle FAQ importée dans Supabase
- [ ] Nombre de chunks correct (SELECT COUNT(*) retourne le bon nombre)
- [ ] Aperçu des chunks correct (SELECT * montre les bons titres)

### Test
- [ ] Workflow n8n activé
- [ ] 10 questions de test posées
- [ ] Toutes les réponses correctes (100% de succès)
- [ ] Aucune erreur dans les logs n8n
- [ ] Node "Supabase - Get Property FAQ" retourne tous les chunks
- [ ] Node "Code - Prepare OpenAI Context" reçoit toute la FAQ

### Optimisation
- [ ] Prompt système à jour (`prompt-optimise.txt`)
- [ ] Instruction 5 détaillée pour recherche dans FAQ
- [ ] Test avec questions variées (synonymes, fautes, anglais)
- [ ] Temps de réponse acceptable (< 5 secondes)

---

## 🎉 Résultat attendu

Après cette migration, vous devriez observer :

| Métrique | Objectif |
|----------|----------|
| Taux de réponse correcte FAQ | **> 90%** |
| Messages "Je n'ai pas l'info" (alors que si) | **< 5%** |
| Temps de réponse | **< 4 secondes** |
| Satisfaction utilisateur | **"Le bot a trouvé l'info"** |

---

## 📞 Besoin d'aide ?

Si vous rencontrez des problèmes :

1. **Relire** : `GUIDE-MIGRATION-FAQ.md` section Troubleshooting
2. **Vérifier** : `EXEMPLES-AVANT-APRES.md` pour comprendre ce qui devrait se passer
3. **Logs n8n** : Activer le mode debug sur les nodes de code
4. **Supabase** : Vérifier que les données sont bien insérées

---

## 📚 Pour aller plus loin

Une fois la FAQ rechunkée fonctionnelle :

1. **Optimiser les mots-clés** : Ajouter des synonymes si le bot ne trouve toujours pas certaines infos
2. **Tester en conditions réelles** : Avec de vrais utilisateurs
3. **Analyser les logs** : Quelles questions reviennent souvent ?
4. **Enrichir la FAQ** : Ajouter des chunks pour les questions fréquentes non couvertes

---

Bon rechunking ! 🚀

**Prochaine étape** : Commencer par ÉTAPE 1 dans `FAQ-RECHUNKEE-OPTIMALE.md`
