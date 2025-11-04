-- =====================================================
-- IMPORT FAQ CHALET FLOCON DANS SUPABASE (MULTI-LOGEMENTS)
-- Table : rag_test_for_charles_locabot
-- =====================================================
-- ⚠️ Ce script ne touche QUE les chunks de chalet_flocon
-- Les chunks des autres propriétés (anatole, etc.) sont préservés

-- ÉTAPE 1 : Supprimer UNIQUEMENT l'ancienne FAQ de chalet_flocon
DELETE FROM rag_test_for_charles_locabot
WHERE property_id = 'chalet_flocon';

-- ÉTAPE 2 : Insérer les nouveaux chunks pour chalet_flocon

-- =====================================================
-- CHUNK 1 : Transport et Accès au Logement
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 1 : Transport et Accès au Logement

Mots-clés : navette, transport, bus, parking, voiture, accès, trajet, gare, aéroport

Navette gratuite :
- Navette GRATUITE depuis la gare de Moutiers
- Disponible uniquement sur réservation préalable
- Pour réserver : contacter le propriétaire avec vos horaires d''arrivée

Parking :
- Places de parking gratuites disponibles
- Stationnement sécurisé à proximité immédiate du logement

Accès en voiture :
- GPS : Chalet Flocon, Val Thorens
- Parking gratuit sur place
- Route accessible toute l''année',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 2 : Arrivée et Check-in
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 2 : Arrivée et Check-in

Mots-clés : check-in, arrivée, clés, heure arrivée, accès logement, remise clés

Horaires :
- Check-in : À partir de 16h00
- Check-out : Avant 10h00

Procédure d''arrivée :
- Remise des clés en personne à l''arrivée
- Si arrivée tardive : prévoir la communication avec le propriétaire à l''avance
- Instructions d''accès envoyées 24h avant l''arrivée

Contact propriétaire :
- Coordonnées fournies après réservation
- Disponible pour questions avant et pendant le séjour',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 3 : Départ et Check-out
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 3 : Départ et Check-out

Mots-clés : check-out, départ, heure départ, ménage, état des lieux, clés

Horaires :
- Check-out : Avant 10h00
- Prolongation possible sur demande (selon disponibilités)

Avant le départ :
- Laisser le logement propre et rangé
- Vaisselle faite et rangée
- Ordures sorties dans les containers prévus
- Restitution des clés au propriétaire',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 4 : Équipements de Bien-être
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 4 : Équipements de Bien-être

Mots-clés : jacuzzi, spa, sauna, détente, relaxation, bien-être

Jacuzzi / Spa :
- Jacuzzi privatif disponible
- Utilisation incluse dans le prix de la réservation
- Température maintenue à 38°C
- Instructions d''utilisation dans le logement

Conseils d''utilisation :
- Maximum 6 personnes simultanément
- Douche obligatoire avant utilisation
- Serviettes fournies',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 5 : Cuisine et Équipements
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 5 : Cuisine et Équipements

Mots-clés : cuisine, équipements, vaisselle, électroménager, ustensiles, cafetière, four

Équipements cuisine :
- Cuisine entièrement équipée
- Four, micro-ondes, réfrigérateur, congélateur
- Lave-vaisselle
- Plaques de cuisson (induction/gaz)
- Cafetière Nespresso + cafetière filtre
- Bouilloire, grille-pain

Vaisselle et ustensiles :
- Vaisselle complète pour 4 personnes
- Couverts, verres, assiettes
- Casseroles, poêles, plats de cuisson
- Ustensiles de cuisine (couteaux, spatules, etc.)',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 6 : Linge et Entretien
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 6 : Linge et Entretien

Mots-clés : draps, serviettes, linge, ménage, nettoyage, lessive, lave-linge

Linge fourni :
- Draps et couvertures fournis pour tous les lits
- Serviettes de toilette fournies (1 grande + 1 petite par personne)
- Serviettes pour le jacuzzi disponibles

Équipements ménagers :
- Lave-linge disponible
- Produits de nettoyage de base fournis
- Aspirateur, balai, serpillère',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 7 : Activités Ski et Montagne
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 7 : Activités Ski et Montagne

Mots-clés : ski, pistes, forfait, remontées, ski room, casier ski, matériel ski

Accès aux pistes :
- Distance aux pistes : 50 mètres
- Accès skis aux pieds : OUI
- Navette vers les pistes : Oui, navette gratuite toutes les 5 mn de 7h à 20h du lundi au dimanche

Équipements ski :
- Casier à ski sécurisé
- Chauffe-chaussures disponible
- Local à ski chauffé

Forfaits :
- Points de vente à 50 mètres
- Possibilité d''achat en ligne à l''avance',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 8 : Activités Été
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 8 : Activités Été

Mots-clés : randonnée, VTT, été, activités estivales, montagne été

Activités disponibles :
- Sentiers de randonnée à proximité
- Parcours VTT
- Via ferrata
- Lac de montagne accessible

Carte des sentiers :
- Disponible au logement
- Office de tourisme à 150 mètres',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 9 : Commerces et Services
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 9 : Commerces et Services

Mots-clés : courses, supermarché, commerces, restaurants, boulangerie, pharmacie

Commerces de proximité :
- Supermarché : 30 mètres
- Boulangerie : 40 mètres
- Restaurants : 60 mètres
- Pharmacie : 30 mètres

Horaires indicatifs :
- Supermarché : 8h-20h (vérifier selon saison)
- Boulangerie : 7h-13h et 16h-19h',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 10 : WiFi et Connectivité
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 10 : WiFi et Connectivité

Mots-clés : wifi, internet, connexion, réseau, mot de passe wifi

WiFi :
- WiFi haut débit inclus
- Nom du réseau : CHALET FLOCON
- Mot de passe : Fourni dans le livret d''accueil disponible dans le chalet
- Couverture dans tout le logement',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 11 : Règlement Intérieur
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 11 : Règlement Intérieur

Mots-clés : règles, interdictions, bruit, fête, animaux, fumeur, caution

Règles importantes :
- Non fumeur à l''intérieur
- Animaux : AUTORISÉS s''il est calme et propre
- Fêtes non autorisées
- Respect du voisinage (pas de bruit après 22h)

Caution :
- Montant : 300 euros
- Restitution sous 7 jours après départ
- Déduction en cas de dégâts',
'chalet_flocon'
);

-- =====================================================
-- CHUNK 12 : Contact et Urgences
-- =====================================================
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 12 : Contact et Urgences

Mots-clés : urgence, problème, contact, téléphone, assistance, panne

Contact propriétaire :
- Téléphone : 06 01 02 03 04
- Disponible 7j/7 pour urgences

Numéros utiles :
- Urgences : 112
- Médecin : 06 06 06 06 06
- Pharmacie de garde : 06 07 07 07 07

En cas de problème :
- Chauffage, eau chaude : Contacter le propriétaire immédiatement
- Panne électrique : Vérifier le disjoncteur puis contacter le propriétaire
- Problème internet : Redémarrer la box puis contacter le propriétaire',
'chalet_flocon'
);

-- =====================================================
-- VÉRIFICATION : Compter les chunks de chalet_flocon
-- =====================================================
SELECT COUNT(*) as total_chunks_chalet_flocon
FROM rag_test_for_charles_locabot
WHERE property_id = 'chalet_flocon';
-- Devrait retourner : 12

-- =====================================================
-- VÉRIFICATION : Compter TOUS les chunks (toutes propriétés)
-- =====================================================
SELECT
  property_id,
  COUNT(*) as nb_chunks
FROM rag_test_for_charles_locabot
GROUP BY property_id
ORDER BY property_id;
-- Devrait montrer : chalet_flocon (12), anatole (X), etc.

-- =====================================================
-- VÉRIFICATION : Voir les chunks de chalet_flocon
-- =====================================================
SELECT
  id,
  property_id,
  LEFT(content, 60) as chunk_preview
FROM rag_test_for_charles_locabot
WHERE property_id = 'chalet_flocon'
ORDER BY id;
