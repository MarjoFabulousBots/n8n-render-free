-- =====================================================
-- IMPORT FAQ RECHUNKÉE DANS SUPABASE
-- Table : rag_test_for_charles_locabot
-- =====================================================

-- ÉTAPE 1 : Supprimer l'ancienne FAQ
DELETE FROM rag_test_for_charles_locabot;

-- ÉTAPE 2 : Insérer les nouveaux chunks

-- =====================================================
-- CHUNK 1 : Transport et Accès au Logement
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 1 : Transport et Accès au Logement

Mots-clés : navette, transport, bus, parking, voiture, accès, trajet, gare, aéroport, shuttle

Navette gratuite :
- Navette GRATUITE depuis la gare de Moutiers
- Disponible uniquement sur réservation préalable
- Pour réserver : contacter le propriétaire avec vos horaires d''arrivée

Parking :
- Places de parking gratuites disponibles
- Stationnement sécurisé à proximité immédiate du logement

Accès en voiture :
- GPS : [REMPLACER PAR ADRESSE EXACTE]
- Parking gratuit sur place
- Route accessible toute l''année'
);

-- =====================================================
-- CHUNK 2 : Arrivée et Check-in
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 2 : Arrivée et Check-in

Mots-clés : check-in, arrivée, clés, heure arrivée, accès logement, remise clés, heure check-in

Horaires :
- Check-in : À partir de 16h00
- Check-out : Avant 10h00

Procédure d''arrivée :
- Remise des clés en personne à l''arrivée
- Si arrivée tardive : prévoir la communication avec le propriétaire à l''avance
- Instructions d''accès envoyées 24h avant l''arrivée

Contact propriétaire :
- Coordonnées fournies après réservation
- Disponible pour questions avant et pendant le séjour'
);

-- =====================================================
-- CHUNK 3 : Départ et Check-out
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 3 : Départ et Check-out

Mots-clés : check-out, départ, heure départ, ménage, état des lieux, clés, fin séjour

Horaires :
- Check-out : Avant 10h00
- Prolongation possible sur demande (selon disponibilités)

Avant le départ :
- Laisser le logement propre et rangé
- Vaisselle faite et rangée
- Ordures sorties dans les containers prévus
- Restitution des clés au propriétaire'
);

-- =====================================================
-- CHUNK 4 : Équipements de Bien-être
-- =====================================================
-- ⚠️ SUPPRIMER CE CHUNK SI VOUS N'AVEZ PAS DE JACUZZI/SPA
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 4 : Équipements de Bien-être

Mots-clés : jacuzzi, spa, sauna, détente, relaxation, bien-être, bain

Jacuzzi / Spa :
- Jacuzzi privatif disponible
- Utilisation incluse dans le prix de la réservation
- Température maintenue à 38°C
- Instructions d''utilisation dans le logement

Conseils d''utilisation :
- Maximum 6 personnes simultanément
- Douche obligatoire avant utilisation
- Serviettes fournies'
);

-- =====================================================
-- CHUNK 5 : Cuisine et Équipements
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 5 : Cuisine et Équipements

Mots-clés : cuisine, équipements, vaisselle, électroménager, ustensiles, cafetière, four, micro-ondes

Équipements cuisine :
- Cuisine entièrement équipée
- Four, micro-ondes, réfrigérateur, congélateur
- Lave-vaisselle
- Plaques de cuisson (induction/gaz)
- Cafetière Nespresso + cafetière filtre
- Bouilloire, grille-pain

Vaisselle et ustensiles :
- Vaisselle complète pour [NOMBRE] personnes
- Couverts, verres, assiettes
- Casseroles, poêles, plats de cuisson
- Ustensiles de cuisine (couteaux, spatules, etc.)'
);

-- =====================================================
-- CHUNK 6 : Linge et Entretien
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 6 : Linge et Entretien

Mots-clés : draps, serviettes, linge, ménage, nettoyage, lessive, lave-linge, machine laver

Linge fourni :
- Draps et couvertures fournis pour tous les lits
- Serviettes de toilette fournies (1 grande + 1 petite par personne)
- Serviettes pour le jacuzzi disponibles

Équipements ménagers :
- Lave-linge disponible
- Produits de nettoyage de base fournis
- Aspirateur, balai, serpillère'
);

-- =====================================================
-- CHUNK 7 : Activités Ski et Montagne
-- =====================================================
-- ⚠️ SUPPRIMER CE CHUNK SI NON PERTINENT (logement non ski)
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 7 : Activités Ski et Montagne

Mots-clés : ski, pistes, forfait, remontées, ski room, casier ski, matériel ski, station ski

Accès aux pistes :
- Distance aux pistes : [DISTANCE EN MÈTRES OU MINUTES]
- Accès skis aux pieds : [OUI/NON]
- Navette vers les pistes : [INFORMATIONS SI APPLICABLE]

Équipements ski :
- Casier à ski sécurisé
- Chauffe-chaussures disponible
- Local à ski chauffé

Forfaits :
- Points de vente à [DISTANCE]
- Possibilité d''achat en ligne à l''avance'
);

-- =====================================================
-- CHUNK 8 : Activités Été
-- =====================================================
-- ⚠️ SUPPRIMER CE CHUNK SI NON PERTINENT
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 8 : Activités Été

Mots-clés : randonnée, VTT, été, activités estivales, montagne été, balade, trail

Activités disponibles :
- Sentiers de randonnée à proximité
- Parcours VTT
- Via ferrata
- Lac de montagne accessible

Carte des sentiers :
- Disponible au logement
- Office de tourisme à [DISTANCE]'
);

-- =====================================================
-- CHUNK 9 : Commerces et Services
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 9 : Commerces et Services

Mots-clés : courses, supermarché, commerces, restaurants, boulangerie, pharmacie, magasins

Commerces de proximité :
- Supermarché : [DISTANCE]
- Boulangerie : [DISTANCE]
- Restaurants : [DISTANCE]
- Pharmacie : [DISTANCE]

Horaires indicatifs :
- Supermarché : 8h-20h (vérifier selon saison)
- Boulangerie : 7h-13h et 16h-19h'
);

-- =====================================================
-- CHUNK 10 : WiFi et Connectivité
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 10 : WiFi et Connectivité

Mots-clés : wifi, internet, connexion, réseau, mot de passe wifi, password wifi

WiFi :
- WiFi haut débit inclus
- Nom du réseau : [NOM SSID]
- Mot de passe : Fourni dans le livret d''accueil
- Couverture dans tout le logement'
);

-- =====================================================
-- CHUNK 11 : Règlement Intérieur
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 11 : Règlement Intérieur

Mots-clés : règles, interdictions, bruit, fête, animaux, fumeur, caution, règlement

Règles importantes :
- Non fumeur à l''intérieur
- Animaux : [AUTORISÉS/NON AUTORISÉS]
- Fêtes non autorisées
- Respect du voisinage (pas de bruit après 22h)

Caution :
- Montant : [MONTANT] euros
- Restitution sous 7 jours après départ
- Déduction en cas de dégâts'
);

-- =====================================================
-- CHUNK 12 : Contact et Urgences
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content) VALUES (
'CHUNK 12 : Contact et Urgences

Mots-clés : urgence, problème, contact, téléphone, assistance, panne, help

Contact propriétaire :
- Téléphone : [NUMÉRO]
- Disponible 7j/7 pour urgences

Numéros utiles :
- Urgences : 112
- Médecin : [NUMÉRO LOCAL]
- Pharmacie de garde : [NUMÉRO]

En cas de problème :
- Chauffage, eau chaude : [INSTRUCTIONS]
- Panne électrique : [INSTRUCTIONS]
- Problème internet : [INSTRUCTIONS]'
);

-- =====================================================
-- VÉRIFICATION : Compter les chunks insérés
-- =====================================================
SELECT COUNT(*) as total_chunks FROM rag_test_for_charles_locabot;
-- Devrait retourner : 12 (ou moins si vous avez supprimé des chunks)

-- =====================================================
-- VÉRIFICATION : Voir tous les chunks
-- =====================================================
SELECT
  id,
  LEFT(content, 100) as chunk_preview
FROM rag_test_for_charles_locabot
ORDER BY id;

-- =====================================================
-- INSTRUCTIONS D'UTILISATION
-- =====================================================
--
-- 1. REMPLACER LES PLACEHOLDERS :
--    - [REMPLACER PAR ADRESSE EXACTE]
--    - [DISTANCE EN MÈTRES OU MINUTES]
--    - [OUI/NON]
--    - [NOMBRE]
--    - [NOM SSID]
--    - [NUMÉRO]
--    - [MONTANT]
--    - etc.
--
-- 2. SUPPRIMER LES CHUNKS NON PERTINENTS :
--    - Pas de jacuzzi ? → Supprimer CHUNK 4
--    - Pas d'activités ski ? → Supprimer CHUNK 7
--    - Pas d'activités été ? → Supprimer CHUNK 8
--
-- 3. EXÉCUTER DANS SUPABASE :
--    - Aller dans Supabase → SQL Editor
--    - Copier-coller ce fichier (après modifications)
--    - Cliquer "Run"
--
-- 4. VÉRIFIER :
--    - Les requêtes de vérification à la fin montrent les chunks insérés
--
-- =====================================================
