# Guide Explicatif du Workflow - Assistant Airbnb WhatsApp

## 📊 Vue d'ensemble
Ce workflow gère un assistant WhatsApp multi-propriétés pour Airbnb avec 31 nœuds fonctionnels.

---

## 🔵 SECTION 1 : DÉCLENCHEMENT ET IDENTIFICATION UTILISATEUR

### 1. When chat message received
**Type** : Chat Trigger
**Rôle** : Point d'entrée du workflow. Reçoit les messages WhatsApp via webhook et déclenche tout le processus.

### 2. Supabase - Get User
**Type** : Supabase (getAll)
**Rôle** : Recherche l'utilisateur dans la table `voyageurs2` par son numéro WhatsApp (`num_whatsapp`).

### 3. IF User Exists
**Type** : IF
**Rôle** : Vérifie si l'utilisateur existe dans la base de données.
- **TRUE** → Utilisateur existant (vers Merge User Data)
- **FALSE** → Nouvel utilisateur (vers Code - Detect Property New User)

---

## 🔵 SECTION 2 : GESTION NOUVEL UTILISATEUR

### 4. Code - Detect Property (New User)
**Type** : Code
**Rôle** : Extrait le tag du logement depuis le message (ex: "CHALET_FLOCON : Bonjour") pour identifier la propriété.

### 5. Supabase - Create User
**Type** : Supabase (insert)
**Rôle** : Crée un nouvel enregistrement utilisateur dans `voyageurs2` avec le `property_id` détecté.

---

## 🔵 SECTION 3 : FUSION ET CONTRÔLE D'ACCÈS

### 6. Merge User Data
**Type** : Merge
**Rôle** : Fusionne les données de l'utilisateur existant ou nouvellement créé pour uniformiser le flux.

### 7. Code - Access Check
**Type** : Code
**Rôle** : Vérifie si le séjour de l'utilisateur est terminé en comparant `date_depart` avec la date actuelle.

### 8. IF Access Granted
**Type** : IF
**Rôle** : Détermine si l'utilisateur peut accéder au bot.
- **TRUE** → Accès autorisé (séjour en cours ou nouveau)
- **FALSE** → Accès refusé (séjour terminé)

### 9. Respond to Webhook1
**Type** : Respond to Webhook
**Rôle** : Envoie le message "Votre séjour est terminé" si l'accès est refusé, puis termine le workflow.

---

## 🔵 SECTION 4 : DÉTECTION ET VALIDATION PROPRIÉTÉ

### 10. Code - Detect Property (Main)
**Type** : Code
**Rôle** : Extrait ou récupère le `property_id` de l'utilisateur (depuis message ou base de données).

### 11. IF Property Detected
**Type** : IF
**Rôle** : Vérifie si le logement a été identifié.
- **TRUE** → Propriété connue (vers Update Property)
- **FALSE** → Propriété inconnue (demande à l'utilisateur)

### 12. Ask Property Selection
**Type** : Respond to Webhook
**Rôle** : Demande à l'utilisateur de préciser pour quel logement il a une question.

### 13. Supabase - Save Ask Property
**Type** : Supabase (insert)
**Rôle** : Sauvegarde la question du bot dans l'historique (`n8n_chat_histories`).

---

## 🔵 SECTION 5 : RÉCUPÉRATION CONTEXTE (FAQ + HISTORIQUE)

### 14. Supabase - Update Property
**Type** : Supabase (update)
**Rôle** : Met à jour le `property_id` et `derniere_activite` de l'utilisateur dans `voyageurs2`.

### 15. Supabase - Get Property FAQ
**Type** : Supabase (getAll)
**Rôle** : Récupère tous les chunks FAQ de la table `rag_test_for_charles_locabot` (sera filtré par `property_id` dans le code).

### 16. Supabase - Get History
**Type** : Supabase (getAll)
**Rôle** : Récupère l'historique des conversations de l'utilisateur depuis `n8n_chat_histories`.

### 17. Merge
**Type** : Merge
**Rôle** : Fusionne les données FAQ et historique pour éviter les doublons avant de préparer le contexte OpenAI.

---

## 🔵 SECTION 6 : PRÉPARATION ET APPEL IA

### 18. Code - Prepare OpenAI Context
**Type** : Code
**Rôle** : Prépare le prompt système avec :
- FAQ filtrée par `property_id`
- Historique de conversation
- Dates utilisateur
- Instructions vouvoiement et recherche stricte

### 19. Prepare OpenAI Messages
**Type** : Code
**Rôle** : Formate les messages au format OpenAI : système + historique + nouveau message utilisateur.

### 20. HTTP Request - OpenAI API
**Type** : HTTP Request
**Rôle** : Appelle l'API OpenAI (gpt-4.1-mini) pour obtenir la réponse du bot.

---

## 🔵 SECTION 7 : TRAITEMENT RÉPONSE IA

### 21. Code - Parse OpenAI Response
**Type** : Code
**Rôle** : Parse la réponse OpenAI :
- Extrait le texte pour l'utilisateur
- Extrait les données structurées (`<data>` JSON) : dates, besoin humain
- Corrige les années si nécessaire

### 22. IF Structured Data Exists
**Type** : IF
**Rôle** : Vérifie si OpenAI a extrait des données structurées (dates ou demande humaine).
- **TRUE** → Il y a des données à traiter
- **FALSE** → Pas de données, juste mise à jour activité

---

## 🔵 SECTION 8 : GESTION ESCALADE HUMAINE

### 23. IF Needs Human
**Type** : IF
**Rôle** : Vérifie si le bot a détecté un besoin d'intervention humaine (`needs_human: true`).
- **TRUE** → Alerte propriétaire
- **FALSE** → Mise à jour données utilisateur

### 24. Send a message to owner
**Type** : Gmail (désactivé)
**Rôle** : Envoie un email au propriétaire pour signaler une demande complexe.

### 25. Send Message To User
**Type** : WhatsApp (désactivé)
**Rôle** : Envoie un message WhatsApp à l'utilisateur pour confirmer l'escalade.

---

## 🔵 SECTION 9 : SAUVEGARDE ET RÉPONSE FINALE

### 26. Supabase - Update User Data
**Type** : Supabase (update)
**Rôle** : Met à jour les données utilisateur dans `voyageurs2` : `date_arrivee`, `date_depart`, `pending_data`, `property_id`.

### 27. Supabase - Update Activity Only
**Type** : Supabase (update)
**Rôle** : Met à jour uniquement `derniere_activite` si aucune donnée structurée n'a été extraite.

### 28. Supabase - Save User Message
**Type** : Supabase (insert)
**Rôle** : Sauvegarde le message de l'utilisateur dans l'historique (`n8n_chat_histories`).

### 29. Supabase - Save Bot Message
**Type** : Supabase (insert)
**Rôle** : Sauvegarde la réponse du bot dans l'historique (`n8n_chat_histories`).

### 30. Respond to Webhook
**Type** : Respond to Webhook
**Rôle** : Envoie la réponse finale au chat WhatsApp pour l'afficher à l'utilisateur.

---

## 🔵 SECTION 10 : NOTES INFORMATIVES

### 31. Sticky Note
**Type** : Note adhésive
**Rôle** : Note explicative sur la variable WhatsApp à modifier pour le trigger.

### 32. Sticky Note2
**Type** : Note adhésive
**Rôle** : Instructions pour ajouter un nouveau logement dans le code (format du property object).

---

## 📊 Flux Simplifié

```
Message WhatsApp
    ↓
Identification utilisateur (Get User)
    ↓
Nouvel utilisateur ? → Créer / Existant ? → Charger
    ↓
Vérification accès (date séjour)
    ↓
Accès refusé ? → Fin / Accès OK ? → Continue
    ↓
Détection propriété (tag message)
    ↓
Récupération FAQ + Historique
    ↓
Préparation contexte IA (prompt + FAQ filtrée)
    ↓
Appel OpenAI API
    ↓
Parse réponse (texte + données structurées)
    ↓
Besoin humain ? → Alerte / Données à sauver ? → Update
    ↓
Sauvegarde historique (message user + bot)
    ↓
Réponse finale au chat WhatsApp
```

---

## 🎯 Points Clés

- **Multi-propriétés** : Gestion automatique via tag extraction
- **Sécurité** : Contrôle d'accès par date de départ
- **Mémoire** : Historique complet des conversations
- **FAQ contextuelle** : Filtrée par logement
- **Extraction de données** : Dates et besoins détectés automatiquement
- **Vouvoiement** : Imposé dans le prompt système

---

## 📝 Tables Supabase Utilisées

1. **voyageurs2** : Données utilisateurs (dates, property_id, activité)
2. **n8n_chat_histories** : Historique conversations (session_id, message, date)
3. **rag_test_for_charles_locabot** : FAQ chunks par logement (content, property_id)
