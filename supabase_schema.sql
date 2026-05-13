-- ============================================================
--  QEA Coach Toolkit — Supabase Schema
--  Run this entire file in Supabase → SQL Editor → New Query
-- ============================================================

-- 1. BATCH DATA (mirrors Excel base file columns)
CREATE TABLE IF NOT EXISTS batches (
  id              BIGSERIAL PRIMARY KEY,
  type            TEXT,
  cohort          TEXT NOT NULL UNIQUE,
  status          TEXT,
  vertical        TEXT,
  headcount       INT DEFAULT 0,
  exit_count      INT DEFAULT 0,
  hold_count      INT DEFAULT 0,
  in_training     INT DEFAULT 0,
  track           TEXT,
  start_date      DATE,
  coach           TEXT,
  qualifier1      DATE,
  qualifier2      DATE,
  qualifier3      DATE,
  interim         DATE,
  final_date      DATE,
  release_date    DATE,
  trainer_name    TEXT,
  mode            TEXT,
  mentor_name     TEXT,
  bh_name         TEXT,
  room            TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ATTENDANCE (per candidate per date)
CREATE TABLE IF NOT EXISTS attendance (
  id              BIGSERIAL PRIMARY KEY,
  emp_id          TEXT NOT NULL,
  candidate_name  TEXT,
  cohort          TEXT,
  track           TEXT,
  att_date        DATE NOT NULL,
  status          TEXT CHECK (status IN ('P','AB','EXAM')) DEFAULT 'P',
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(emp_id, att_date)
);

-- 3. CANDIDATES (from attendance template upload)
CREATE TABLE IF NOT EXISTS candidates (
  id              BIGSERIAL PRIMARY KEY,
  emp_id          TEXT NOT NULL UNIQUE,
  candidate_name  TEXT,
  cohort          TEXT,
  track           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── Indexes for fast lookup ──
CREATE INDEX IF NOT EXISTS idx_batches_cohort    ON batches(cohort);
CREATE INDEX IF NOT EXISTS idx_batches_status    ON batches(status);
CREATE INDEX IF NOT EXISTS idx_attendance_emp    ON attendance(emp_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date   ON attendance(att_date);
CREATE INDEX IF NOT EXISTS idx_attendance_cohort ON attendance(cohort);
CREATE INDEX IF NOT EXISTS idx_candidates_cohort ON candidates(cohort);

-- ── Auto-update updated_at ──
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER batches_updated_at
  BEFORE UPDATE ON batches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER attendance_updated_at
  BEFORE UPDATE ON attendance
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Row Level Security (RLS) — allow public read, authenticated write ──
ALTER TABLE batches    ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE candidates ENABLE ROW LEVEL SECURITY;

-- Public read access (dashboard is view-only for unauthenticated)
CREATE POLICY "Public read batches"    ON batches    FOR SELECT USING (true);
CREATE POLICY "Public read attendance" ON attendance FOR SELECT USING (true);
CREATE POLICY "Public read candidates" ON candidates FOR SELECT USING (true);

-- Anon key can insert/update (for uploads from the dashboard)
CREATE POLICY "Anon insert batches"    ON batches    FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon update batches"    ON batches    FOR UPDATE USING (true);
CREATE POLICY "Anon insert attendance" ON attendance FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon update attendance" ON attendance FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Anon insert candidates" ON candidates FOR INSERT WITH CHECK (true);
CREATE POLICY "Anon update candidates" ON candidates FOR UPDATE USING (true) WITH CHECK (true);
