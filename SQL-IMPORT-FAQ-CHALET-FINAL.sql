-- ============================================
-- SCRIPT SQL - INJECTION FAQ CHALET DES AROLLES
-- PROPERTY_ID : CHALET
-- ============================================
--
-- PRÉREQUIS : Supprimer manuellement l'ancienne FAQ avant d'exécuter ce script
--
-- Ce script injecte les 12 chunks optimisés dans la table
-- ============================================

-- CHUNK 1 : Transport et Accès
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 1 : Transport et Accès au Logement

Mots-clés : navette, transport, bus, parking, voiture, accès, trajet, gare, aéroport

Navette gratuite

Navette GRATUITE depuis la gare de Moutiers.

Disponible uniquement sur réservation préalable.

Pour réserver : contacter le propriétaire avec vos horaires d''arrivée.

Parking

Places de parking gratuites disponibles.

Stationnement sécurisé à proximité immédiate du logement.

Accès en voiture

GPS : Chalet des Arolles, 73550 Méribel.

Parking gratuit sur place.

Route accessible toute l''année.',
'CHALET'
);

-- CHUNK 2 : Arrivée et Check-in
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 2 : Arrivée et Check-in

Mots-clés : check-in, arrivée, clés, heure arrivée, accès logement, remise clés

Horaires

Check-in : À partir de 16h00

Check-out : Avant 10h00

Procédure d''arrivée

Remise des clés en personne à l''arrivée.

Si arrivée tardive : prévoir la communication avec le propriétaire à l''avance.

Instructions d''accès envoyées 24h avant l''arrivée.

Contact propriétaire

Coordonnées fournies après réservation.

Disponible pour questions avant et pendant le séjour.',
'CHALET'
);

-- CHUNK 3 : Départ et Check-out
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 3 : Départ et Check-out

Mots-clés : check-out, départ, heure départ, ménage, état des lieux, clés

Horaires

Check-out : Avant 10h00

Prolongation possible sur demande (selon disponibilités).

Avant le départ

Laisser le logement propre et rangé.

Vaisselle faite et rangée.

Ordures sorties dans les containers prévus.

Restitution des clés au propriétaire.',
'CHALET'
);

-- CHUNK 4 : Équipements de Bien-être
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 4 : Équipements de Bien-être

Mots-clés : jacuzzi, spa, sauna, détente, relaxation, bien-être

Jacuzzi / Spa

Jacuzzi privatif disponible.

Utilisation incluse dans le prix de la réservation.

Température maintenue à 38°C.

Instructions d''utilisation dans le logement.

Conseils d''utilisation

Maximum 6 personnes simultanément.

Douche obligatoire avant utilisation.

Serviettes fournies.',
'CHALET'
);

-- CHUNK 5 : Cuisine et Équipements
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 5 : Cuisine et Équipements

Mots-clés : cuisine, équipements, vaisselle, électroménager, ustensiles, cafetière, four

Équipements cuisine

Cuisine entièrement équipée.

Four, micro-ondes, réfrigérateur, congélateur.

Lave-vaisselle.

Plaques de cuisson à induction.

Cafetière (Nespresso + cafetière filtre).

Bouilloire, grille-pain.

Vaisselle et ustensiles

Vaisselle complète pour 8 personnes.

Couverts, verres, assiettes.

Casseroles, poêles, plats de cuisson.

Ustensiles de cuisine (couteaux, spatules, etc.).',
'CHALET'
);

-- CHUNK 6 : Linge et Entretien
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 6 : Linge et Entretien

Mots-clés : draps, serviettes, linge, ménage, nettoyage, lessive, lave-linge

Linge fourni

Draps et couvertures fournis pour tous les lits.

Serviettes de toilette fournies (1 grande + 1 petite par personne).

Serviettes pour le jacuzzi disponibles.

Équipements ménagers

Lave-linge disponible.

Produits de nettoyage de base fournis.

Aspirateur, balai, serpillère.',
'CHALET'
);

-- CHUNK 7 : Activités Ski et Montagne
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 7 : Activités Ski et Montagne

Mots-clés : ski, pistes, forfait, remontées, ski room, casier ski, matériel ski

Accès aux pistes

Distance aux pistes : 150 mètres.

Accès skis aux pieds : NON.

Navette vers les pistes : arrêt à 50 mètres du logement.

Équipements ski

Casier à ski sécurisé.

Chauffe-chaussures disponible.

Local à ski chauffé.

Forfaits

Points de vente à 200 mètres.

Possibilité d''achat en ligne à l''avance sur le site de la station.',
'CHALET'
);

-- CHUNK 8 : Activités Été
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 8 : Activités Été

Mots-clés : randonnée, VTT, été, activités estivales, montagne été

Activités disponibles

Sentiers de randonnée à proximité immédiate.

Parcours VTT balisés accessibles depuis le chalet.

Via ferrata à 15 minutes.

Lac de montagne accessible en 25 minutes de route.

Carte des sentiers

Disponible au logement.

Office de tourisme à 400 mètres.',
'CHALET'
);

-- CHUNK 9 : Commerces et Services
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 9 : Commerces et Services

Mots-clés : courses, supermarché, commerces, restaurants, boulangerie, pharmacie

Commerces de proximité

Supermarché : 600 mètres.

Boulangerie : 350 mètres.

Restaurants : 400 mètres.

Pharmacie : 500 mètres.

Horaires indicatifs

Supermarché : 8h00 – 20h00 (vérifier selon saison).

Boulangerie : 7h00 – 13h00 et 16h00 – 19h00.',
'CHALET'
);

-- CHUNK 10 : WiFi et Connectivité
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 10 : WiFi et Connectivité

Mots-clés : wifi, internet, connexion, réseau, mot de passe wifi

WiFi

WiFi haut débit inclus.

Nom du réseau : ChaletArolles.

Mot de passe : fourni dans le livret d''accueil.

Couverture dans tout le logement.',
'CHALET'
);

-- CHUNK 11 : Règlement Intérieur
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 11 : Règlement Intérieur

Mots-clés : règles, interdictions, bruit, fête, animaux, fumeur, caution

Règles importantes

Non fumeur à l''intérieur.

Animaux : NON AUTORISÉS.

Fêtes non autorisées.

Respect du voisinage (pas de bruit après 22h00).

Caution

Montant : 300 euros.

Restitution sous 7 jours après départ.

Déduction possible en cas de dégâts.',
'CHALET'
);

-- CHUNK 12 : Contact et Urgences
INSERT INTO rag_test_for_charles_locabot (content, property_id) VALUES (
'CHUNK 12 : Contact et Urgences

Mots-clés : urgence, problème, contact, téléphone, assistance, panne

Contact propriétaire

Téléphone : +33 6 12 34 56 78.

Disponible 7j/7 pour urgences.

Numéros utiles

Urgences : 112.

Médecin : +33 4 79 00 11 22.

Pharmacie de garde : +33 4 79 00 22 33.

En cas de problème

Chauffage, eau chaude : vérifier le tableau électrique puis contacter le propriétaire.

Panne électrique : vérifier le disjoncteur principal situé à l''entrée.

Problème internet : redémarrer la box WiFi, puis prévenir le propriétaire si le problème persiste.',
'CHALET'
);

-- ============================================
-- FIN DU SCRIPT
-- ============================================
--
-- ✅ VÉRIFICATION APRÈS IMPORT :
--
-- SELECT COUNT(*) FROM rag_test_for_charles_locabot
-- WHERE property_id = 'CHALET';
--
-- Résultat attendu : 12 lignes
--
-- ✅ VOIR LE CONTENU :
--
-- SELECT * FROM rag_test_for_charles_locabot
-- WHERE property_id = 'CHALET'
-- ORDER BY id;
--
-- ============================================
