// api/attendance.js — Vercel Serverless Function
// Handles GET (fetch all) and POST (upsert attendance records)

import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method === 'GET') {
    const { cohort, date } = req.query;
    let query = supabase.from('attendance').select('*').order('att_date');
    if (cohort) query = query.eq('cohort', cohort);
    if (date)   query = query.eq('att_date', date);
    const { data, error } = await query;
    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json(data);
  }

  if (req.method === 'POST') {
    // Expects: array of { emp_id, candidate_name, cohort, track, att_date, status }
    const rows = req.body;
    if (!Array.isArray(rows)) return res.status(400).json({ error: 'Expected array' });

    const { data, error } = await supabase
      .from('attendance')
      .upsert(rows, { onConflict: 'emp_id,att_date' });

    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json({ saved: rows.length });
  }

  res.status(405).json({ error: 'Method not allowed' });
}
