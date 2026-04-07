-- ============================================================
-- LoyaltyOS — Migration v3 (bugfixes)
-- Coller dans Supabase > SQL Editor > Run
-- ============================================================

-- 1. Colonnes manquantes si pas encore appliqué migration_v2
ALTER TABLE clients ADD COLUMN IF NOT EXISTS total_points_earned integer DEFAULT 0;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS active boolean DEFAULT true;
ALTER TABLE merchants ADD COLUMN IF NOT EXISTS pts_min integer DEFAULT 1;
ALTER TABLE merchants ADD COLUMN IF NOT EXISTS pts_max integer DEFAULT 5000;

-- 2. Synchroniser total_points_earned depuis les transactions existantes
UPDATE clients c
SET total_points_earned = COALESCE((
  SELECT SUM(t.points) FROM transactions t
  WHERE t.client_id = c.id AND t.type = 'earn'
), c.points)
WHERE c.total_points_earned = 0;

-- 3. Recalculer le tier en fonction des points cumulés
UPDATE clients SET tier = CASE
  WHEN total_points_earned >= 5000 THEN 'Platinum'
  WHEN total_points_earned >= 1000 THEN 'Gold'
  ELSE 'Silver'
END;

-- 4. S'assurer que tous les clients ont active = true par défaut
UPDATE clients SET active = true WHERE active IS NULL;
UPDATE merchants SET pts_min = 1 WHERE pts_min IS NULL;
UPDATE merchants SET pts_max = 5000 WHERE pts_max IS NULL;

-- 5. Index pour accélérer la recherche par email (multi-cartes)
CREATE INDEX IF NOT EXISTS idx_clients_email_pass ON clients(email, pass);

-- ============================================================
-- Fin migration v3
-- ============================================================
