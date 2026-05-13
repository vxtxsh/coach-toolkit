// api/batches.js — Vercel Serverless Function
// Handles GET (fetch all) and POST (upsert batch data from Excel upload)

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
    const { data, error } = await supabase
      .from('batches')
      .select('*')
      .order('cohort');
    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json(data);
  }

  if (req.method === 'POST') {
    const rows = req.body; // array of batch objects
    if (!Array.isArray(rows)) return res.status(400).json({ error: 'Expected array' });

    const mapped = rows.map(r => ({
      type:         r.type        || '',
      cohort:       r.cohort      || '',
      status:       r.status      || '',
      vertical:     r.vertical    || '',
      headcount:    r.headcount   || 0,
      exit_count:   r.exit        || 0,
      hold_count:   r.hold        || 0,
      in_training:  r.inTraining  || 0,
      track:        r.track       || '',
      start_date:   r.startDate   || null,
      coach:        r.coach       || '',
      qualifier1:   r.qualifier   || null,
      qualifier2:   r.qualifier2  || null,
      qualifier3:   r.qualifier3  || null,
      interim:      r.interim     || null,
      final_date:   r.final       || null,
      release_date: r.release     || null,
      trainer_name: r.trainerName || '',
      mode:         r.mode        || '',
      mentor_name:  r.mentorName  || '',
      bh_name:      r.bhName      || '',
      room:         r.room        || '',
    })).filter(r => r.cohort);

    const { data, error } = await supabase
      .from('batches')
      .upsert(mapped, { onConflict: 'cohort' });

    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json({ saved: mapped.length });
  }

  res.status(405).json({ error: 'Method not allowed' });
}
