-- ================================================================
--  Planner Nutricional · Belén Tauzin Romeo
--  Ejecutar en: Supabase → SQL Editor → New query
-- ================================================================

-- Pacientes (sincronizado desde Clerk al hacer login)
CREATE TABLE IF NOT EXISTS patients (
  id            TEXT PRIMARY KEY,       -- Clerk user ID
  email         TEXT,
  first_name    TEXT,
  goal_type     TEXT,                   -- 'bajar-peso' | 'mantener-peso' | 'subir-peso' | 'mejorar-habitos'
  restrictions  TEXT[]  DEFAULT '{}',  -- ['sin-tacc', 'vegano', ...]
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  last_seen     TIMESTAMPTZ DEFAULT NOW()
);

-- Planes semanales (uno por paciente por semana)
CREATE TABLE IF NOT EXISTS weekly_plans (
  id            UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id    TEXT    REFERENCES patients(id) ON DELETE CASCADE,
  week_key      TEXT    NOT NULL,        -- '2026-06-01' (lunes de la semana)
  meals_count   INTEGER DEFAULT 0,       -- comidas cargadas
  meals_possible INTEGER DEFAULT 28,     -- 7 días × 4 comidas
  plan_data     JSONB,                   -- snapshot del planner completo
  updated_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(patient_id, week_key)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_weekly_plans_patient ON weekly_plans(patient_id);
CREATE INDEX IF NOT EXISTS idx_weekly_plans_week    ON weekly_plans(week_key);
CREATE INDEX IF NOT EXISTS idx_patients_created     ON patients(created_at);

-- ================================================================
--  VISTAS para el admin dashboard
-- ================================================================

-- Pacientes activos: tienen un plan cargado esta semana
CREATE OR REPLACE VIEW active_this_week AS
SELECT COUNT(DISTINCT patient_id) AS count
FROM weekly_plans
WHERE week_key = to_char(
  date_trunc('week', NOW()) + INTERVAL '0 days',
  'YYYY-MM-DD'
)
AND meals_count > 0;

-- Completitud promedio global
CREATE OR REPLACE VIEW avg_completion AS
SELECT ROUND(
  AVG(meals_count::NUMERIC / NULLIF(meals_possible, 0) * 100), 1
) AS pct
FROM weekly_plans
WHERE meals_count > 0;

-- Distribución de objetivos
CREATE OR REPLACE VIEW goal_distribution AS
SELECT
  COALESCE(goal_type, 'sin configurar') AS goal_type,
  COUNT(*) AS count
FROM patients
GROUP BY goal_type
ORDER BY count DESC;

-- Restricciones más comunes
CREATE OR REPLACE VIEW top_restrictions AS
SELECT
  UNNEST(restrictions) AS restriction,
  COUNT(*) AS count
FROM patients
WHERE restrictions IS NOT NULL AND array_length(restrictions, 1) > 0
GROUP BY restriction
ORDER BY count DESC
LIMIT 8;

-- Registros por semana (últimas 8 semanas)
CREATE OR REPLACE VIEW weekly_signups AS
SELECT
  to_char(date_trunc('week', created_at), 'DD/MM') AS week_start,
  COUNT(*) AS signups
FROM patients
WHERE created_at >= NOW() - INTERVAL '56 days'
GROUP BY date_trunc('week', created_at)
ORDER BY date_trunc('week', created_at);

-- ================================================================
--  RLS — desactivado para simplificar (app privada)
--  Activar en producción con políticas basadas en clerk_id
-- ================================================================
-- ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE weekly_plans ENABLE ROW LEVEL SECURITY;
