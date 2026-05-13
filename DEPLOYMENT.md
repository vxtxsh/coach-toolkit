# 🚀 Coach Tool Kit — Deployment Guide
## Vercel (Hosting) + Supabase (Database)
### Both are FREE — no credit card needed

---

## OVERVIEW

```
Your Browser → Vercel (hosts the HTML + API)
                    ↕
              Supabase (stores batch data + attendance)
```

- **Vercel** hosts your HTML dashboard and serverless API endpoints
- **Supabase** is a free Postgres database that stores all batch and attendance data persistently

---

## STEP 1 — Set Up Supabase (Database)

1. Go to **https://supabase.com** → click **Start your project**
2. Sign up with GitHub (free)
3. Click **New Project**
   - Name: `coach-toolkit`
   - Database Password: (save this somewhere safe)
   - Region: pick nearest (e.g. Singapore for India)
4. Wait ~2 minutes for project to spin up
5. In the left sidebar → click **SQL Editor** → **New Query**
6. Copy the **entire contents** of `supabase_schema.sql` and paste it → click **Run**
7. You should see: `Success. No rows returned`

### Get Your Supabase Keys
1. In Supabase → left sidebar → **Settings** → **API**
2. Copy two values:
   - **Project URL** → looks like `https://abcdefgh.supabase.co`
   - **anon / public key** → long string starting with `eyJ...`
3. **Save both** — you'll need them in Step 3

---

## STEP 2 — Push Code to GitHub

1. Go to **https://github.com** → **New Repository**
   - Name: `coach-toolkit`
   - Visibility: **Private** (recommended)
   - Click **Create Repository**

2. On your computer, open Terminal (Mac/Linux) or Command Prompt (Windows):

```bash
# Navigate to the project folder
cd path/to/coach-toolkit

# Initialize Git
git init
git add .
git commit -m "Initial Coach Toolkit deployment"

# Connect to GitHub (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/coach-toolkit.git
git branch -M main
git push -u origin main
```

> **Don't have Git?** Download from https://git-scm.com

---

## STEP 3 — Deploy to Vercel

1. Go to **https://vercel.com** → **Sign Up with GitHub** (free)
2. Click **Add New Project** → **Import Git Repository**
3. Select your `coach-toolkit` repository → click **Import**
4. In **Configure Project**:
   - Framework Preset: **Other**
   - Root Directory: `./` (leave as default)
5. Expand **Environment Variables** → add these two:

   | Name | Value |
   |------|-------|
   | `SUPABASE_URL` | `https://YOUR_PROJECT_ID.supabase.co` |
   | `SUPABASE_ANON_KEY` | `eyJ...your anon key...` |

6. Click **Deploy** → wait ~1 minute
7. Vercel gives you a URL like: `https://coach-toolkit-abc123.vercel.app`

---

## STEP 4 — Connect the Dashboard to Your API

After deploying, you need to tell the HTML where your API lives:

1. Open `public/index.html` in any text editor
2. Find this section near the bottom (around line 1020):
   ```js
   const SUPABASE_URL     = window.__SUPABASE_URL__     || '';
   const SUPABASE_ANON_KEY= window.__SUPABASE_ANON_KEY__|| '';
   const API_BASE         = window.__API_BASE__          || '';
   ```
3. Replace the empty strings with your values:
   ```js
   const SUPABASE_URL     = 'https://YOUR_PROJECT_ID.supabase.co';
   const SUPABASE_ANON_KEY= 'eyJ...your_anon_key...';
   const API_BASE         = 'https://coach-toolkit-abc123.vercel.app';
   ```
4. Save → commit → push:
   ```bash
   git add public/index.html
   git commit -m "Add Supabase connection"
   git push
   ```
5. Vercel auto-redeploys in ~30 seconds ✅

---

## STEP 5 — Test Your Deployment

1. Open your Vercel URL in a browser
2. The dashboard loads with preloaded batch data
3. Click **⬆ Upload Excel** → upload your `QEA_26_Base_File_-HIPO_batch.xlsx`
4. Data saves to Supabase — next time you open the app, it loads from the database

---

## PROJECT STRUCTURE

```
coach-toolkit/
│
├── public/
│   └── index.html          ← Main dashboard (all-in-one HTML)
│
├── api/
│   ├── batches.js          ← GET/POST batch data
│   ├── attendance.js       ← GET/POST attendance records
│   └── candidates.js       ← GET/POST candidate list
│
├── supabase_schema.sql     ← Run this in Supabase SQL Editor (Step 1)
├── vercel.json             ← Vercel deployment config
├── package.json            ← Node dependencies
├── .env.example            ← Template for environment variables
├── .gitignore              ← Excludes secrets from Git
└── DEPLOYMENT.md           ← This file
```

---

## FREE TIER LIMITS

| Service | Free Tier |
|---------|-----------|
| **Vercel** | 100GB bandwidth/month, unlimited deployments |
| **Supabase** | 500MB database, 2GB file storage, 50,000 MAU |

Both are more than enough for internal HR tooling.

---

## TROUBLESHOOTING

**Dashboard shows "preloaded data" not database data**
→ Check `API_BASE` is set correctly in `index.html`

**Vercel deploy fails**
→ Check Build Logs in Vercel dashboard → usually a missing env variable

**Supabase API returns 401**
→ Your anon key is wrong — re-copy it from Supabase → Settings → API

**CORS error in browser console**
→ The API files already include CORS headers — check Vercel redeploy happened

---

## QUICK COMMANDS REFERENCE

```bash
# Push an update
git add .
git commit -m "Update description"
git push
# Vercel auto-deploys within 30 seconds

# Check Vercel logs
npx vercel logs your-deployment-url

# Test API locally
npx vercel dev
# Open http://localhost:3000
```

---

## SUPPORT

- Vercel Docs: https://vercel.com/docs
- Supabase Docs: https://supabase.com/docs
- Supabase SQL Editor: your-project.supabase.co → SQL Editor
