-- =====================================================
-- CRÉATION TABLE PROPERTIES POUR MULTI-LOGEMENTS
-- =====================================================
-- Cette table permet de gérer des centaines de logements
-- sans modifier le code n8n à chaque ajout
-- =====================================================

-- ÉTAPE 1 : Créer la table properties
CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id TEXT UNIQUE NOT NULL,
  names TEXT[] NOT NULL,
  display_name TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ÉTAPE 2 : Créer les index pour performance
CREATE INDEX IF NOT EXISTS idx_properties_property_id ON properties(property_id);
CREATE INDEX IF NOT EXISTS idx_properties_names ON properties USING gin(names);
CREATE INDEX IF NOT EXISTS idx_properties_active ON properties(active);

-- ÉTAPE 3 : Créer une fonction pour rechercher un logement
-- Cette fonction cherche dans tous les noms possibles d'un logement
CREATE OR REPLACE FUNCTION search_property(search_text TEXT)
RETURNS TABLE(property_id TEXT, display_name TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT p.property_id, p.display_name
  FROM properties p
  WHERE p.active = true
    AND EXISTS (
      SELECT 1
      FROM unnest(p.names) AS name
      WHERE LOWER(search_text) LIKE '%' || LOWER(name) || '%'
    )
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ÉTAPE 4 : Insérer vos logements actuels
INSERT INTO properties (property_id, names, display_name) VALUES
  (
    'anatole',
    ARRAY['logement_anatole', 'anatole', 'appartement anatole', 'appart anatole'],
    'Logement Anatole'
  ),
  (
    'chalet_flocon',
    ARRAY['chalet flocon', 'flocon', 'chalet', 'val thorens', 'val tho', 'chalet val thorens'],
    'Chalet Flocon'
  )
ON CONFLICT (property_id) DO UPDATE SET
  names = EXCLUDED.names,
  display_name = EXCLUDED.display_name,
  updated_at = now();

-- =====================================================
-- VÉRIFICATIONS
-- =====================================================

-- Voir tous les logements
SELECT * FROM properties ORDER BY property_id;

-- Tester la recherche
SELECT * FROM search_property('Je cherche le chalet flocon');
-- Devrait retourner : chalet_flocon | Chalet Flocon

SELECT * FROM search_property('Je veux réserver anatole');
-- Devrait retourner : anatole | Logement Anatole

SELECT * FROM search_property('Logement à Val Thorens');
-- Devrait retourner : chalet_flocon | Chalet Flocon

-- Compter les logements actifs
SELECT COUNT(*) as total_logements_actifs FROM properties WHERE active = true;
-- Devrait retourner : 2

-- =====================================================
-- EXEMPLES D'AJOUT DE NOUVEAUX LOGEMENTS
-- =====================================================

-- Ajouter un nouveau logement (exemple)
-- INSERT INTO properties (property_id, names, display_name) VALUES
--   (
--     'appartement_paris_marais',
--     ARRAY['marais', 'paris marais', 'appartement marais', 'appart paris', 'paris centre'],
--     'Appartement Paris Marais'
--   );

-- Modifier un logement existant
-- UPDATE properties
-- SET names = ARRAY['nouveau_nom', 'ancien_nom', 'autre_nom']
-- WHERE property_id = 'anatole';

-- Désactiver un logement (ne plus le proposer)
-- UPDATE properties
-- SET active = false
-- WHERE property_id = 'anatole';

-- Réactiver un logement
-- UPDATE properties
-- SET active = true
-- WHERE property_id = 'anatole';

-- Supprimer un logement (ATTENTION : irréversible)
-- DELETE FROM properties WHERE property_id = 'anatole';

-- =====================================================
-- STRUCTURE DE LA TABLE
-- =====================================================
--
-- Colonnes :
-- - id              : UUID unique (auto-généré)
-- - property_id     : Identifiant court (ex: 'chalet_flocon')
-- - names           : Liste des noms/mots-clés pour détecter le logement
-- - display_name    : Nom à afficher à l'utilisateur
-- - active          : true = logement disponible, false = désactivé
-- - created_at      : Date de création
-- - updated_at      : Date de dernière modification
--
-- Fonction search_property(text) :
-- - Cherche dans tous les "names" d'un logement
-- - Retourne le premier logement qui matche
-- - Insensible à la casse
-- - Utilise LIKE pour recherche partielle
--
-- =====================================================

-- =====================================================
-- TESTS DE ROBUSTESSE
-- =====================================================

-- Test avec variations d'écriture
SELECT * FROM search_property('CHALET FLOCON');      -- Majuscules
SELECT * FROM search_property('chalet   flocon');    -- Espaces multiples
SELECT * FROM search_property('le chalet flocon');   -- Avec article
SELECT * FROM search_property('flocon');             -- Nom court
SELECT * FROM search_property('val thorens');        -- Nom de station

-- Tous devraient retourner : chalet_flocon | Chalet Flocon

-- Test avec logement inexistant
SELECT * FROM search_property('villa nice');
-- Devrait retourner : (vide)

-- =====================================================
-- PERMISSIONS (optionnel)
-- =====================================================
-- Si vous utilisez Row Level Security (RLS) dans Supabase

-- ALTER TABLE properties ENABLE ROW LEVEL SECURITY;

-- Policy pour lecture publique (tout le monde peut voir les logements)
-- CREATE POLICY "Lecture publique des logements actifs"
-- ON properties FOR SELECT
-- USING (active = true);

-- Policy pour modification (seulement authenticated users)
-- CREATE POLICY "Modification par authenticated users"
-- ON properties FOR ALL
-- TO authenticated
-- USING (true)
-- WITH CHECK (true);
