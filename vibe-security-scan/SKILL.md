---
name: vibe-security-scan
description: "Scans the current project for the 5 most common vibe-coding security mistakes before going live. Read-only."
allowed-tools: Bash, Grep, Glob, Read
---

Announce: "Running Vibe Security Scan on the current project..."

Then follow these 6 steps in order. Collect all findings, then print the full report at the end.

---

## Step 1 — Detect Stack

Check which of the following exist in the current working directory:
- `package.json` → JavaScript/TypeScript project
- `requirements.txt` or `Pipfile` → Python project
- `composer.json` → PHP project
- `supabase/` directory or `supabase` in `package.json` dependencies → Supabase project
- `firestore.rules` or `firebase.json` → Firebase project

Record what was found. Use it to run only the relevant checks below.

---

## Step 2 — Scan: Hardcoded Secrets (CRITICAL)

Use the Grep tool to search all source files (exclude `node_modules/`, `.git/`, `dist/`, `build/`, `.next/`) for these patterns:

**Pattern A — explicit secret assignments:**
Search for: `(api_key|apiKey|api_secret|secret_key|secretKey|password|passwd|supabaseKey|serviceRoleKey|anonKey|DATABASE_URL|STRIPE_SECRET|OPENAI_API_KEY)\s*[:=]\s*['"][^'"$({][^'"]{6,}['"]`
In files: `*.js`, `*.jsx`, `*.ts`, `*.tsx`, `*.py`, `*.php`, `*.rb`, `*.java`, `*.json`, `*.config.js`, `*.config.ts`

**Pattern B — known key prefixes:**
Search for: `(AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36,}|eyJhbGciO)`
In all files except `node_modules/`, `.git/`

**Pattern C — .env file committed to repo:**
Check if `.env` or `.env.local` exists AND is NOT listed in `.gitignore`. If it exists and is not ignored, flag it.

For each match: note the file path, line number, and matched text. Skip matches where the value is `process.env.`, `os.environ`, `import.meta.env`, or an obvious placeholder like `"your-api-key-here"`.

---

## Step 3 — Scan: Broken Auth / IDOR (HIGH)

Use the Grep tool to search for API route patterns where a user-controlled ID is passed directly to a database query without a visible auth/ownership check in the same file.

**Pattern A — Express/Next.js API routes:**
Search for files in `pages/api/`, `app/api/`, `routes/`, `src/api/` containing both:
- `req.params` OR `req.query` OR `req.body` (extracting an id/userId)
- AND a database call (`.findOne`, `.find(`, `.eq(`, `db.query`, `prisma.`, `knex.`)
- WITHOUT a nearby check like `session`, `auth`, `getUser`, `verifyToken`, `currentUser`, `userId ===`

**Pattern B — Supabase client queries:**
Search for `.eq('id',` or `.eq('user_id',` in frontend files (`*.jsx`, `*.tsx`, `*.js`, `*.ts` outside of `api/` directories) without a nearby `session` or `user.id` ownership check.

**Pattern C — Python Flask/FastAPI:**
Search for `@app.route` or `@router.` with `<` path params, followed by a direct DB call without `current_user` or `get_current_user` nearby.

For each match: note file, line number, and describe what was found. Add "(review manually — may be a false positive)" to each finding.

---

## Step 4 — Scan: Missing RLS (CRITICAL for Supabase/Firebase)

**Only run if Supabase or Firebase was detected in Step 1.**

**Supabase:**
1. Search for `.sql` files in `supabase/migrations/` or `supabase/` for the string `ENABLE ROW LEVEL SECURITY`
2. Also search for `CREATE POLICY` statements
3. If Supabase is detected but NO `.sql` files exist with `ENABLE ROW LEVEL SECURITY` → flag as CRITICAL: "No RLS policies found. All tables may be publicly readable."
4. Search all frontend files (`*.js`, `*.jsx`, `*.ts`, `*.tsx`) for `service_role` — if found, flag as CRITICAL: "service_role key detected in frontend code — bypasses all RLS."

**Firebase:**
1. Read `firestore.rules` if it exists
2. If it contains `allow read, write: if true` → flag as CRITICAL: "Firestore rules allow unrestricted public read/write."
3. If it contains `allow read: if true` → flag as HIGH: "Firestore allows public reads."

---

## Step 5 — Scan: Source Maps in Production (HIGH)

**Pattern A — Build config files:**
- Read `vite.config.js` or `vite.config.ts` if it exists. Flag if it contains `sourcemap: true` or `sourcemap: 'inline'` inside a `build:` block.
- Read `next.config.js` or `next.config.ts` if it exists. Flag if it contains `productionBrowserSourceMaps: true`.
- Read `webpack.config.js` if it exists. Flag if it contains `devtool: 'source-map'` or `devtool: 'inline-source-map'` outside of a condition checking `NODE_ENV !== 'production'`.

**Pattern B — Build scripts in package.json:**
Read `package.json` if it exists. Check the `scripts` section for `--sourcemap` in the `build` script.

**Pattern C — Committed .map files:**
Use Glob to check for `*.map` files inside `dist/`, `build/`, `.next/`, or `out/`. If any exist, flag: ".map files committed to repo — remove from .gitignore or delete before deploying."

---

## Step 6 — Scan: Insecure Dependencies (HIGH)

**JavaScript:** If `package.json` exists, run:
```
npm audit --json 2>/dev/null || npm audit 2>/dev/null
```
Parse for `high` and `critical` vulnerabilities. Report count and package names.

**Python:** If `requirements.txt` or `Pipfile` exists, run:
```
pip audit 2>/dev/null || echo "pip audit not available — run: pip install pip-audit && pip-audit"
```

**PHP:** If `composer.json` exists, run:
```
composer audit 2>/dev/null || echo "composer audit not available"
```

If audit tools are not available, report: "Could not run audit — install [tool] and run manually."

---

## Final Report

Print this exact format with your findings filled in:

```
🔍 Vibe Security Scan — Results
================================

[For each category, print one of these:]

🚨 CRITICAL — [Category Name] ([N] found)
  [file]:[line] — [description]

⚠️  HIGH — [Category Name] ([N] found)
  [file]:[line] — [description]

✅  PASS — [Category Name]

[Skip categories not applicable to this stack, e.g. RLS if no Supabase/Firebase]

================================
Summary: [N] CRITICAL · [N] HIGH
[If any CRITICAL or HIGH found]: Fix these before going live.
[If nothing found]: ✅ No critical issues found. Good to go.
```

**Rules for the report:**
- Never print a finding for a match where the value clearly comes from an environment variable (`process.env.*`, `os.environ.*`, `import.meta.env.*`)
- For IDOR findings, always add "(review manually)" — these have the highest false positive rate
- Keep descriptions short and plain — the user is not a security expert
- If a category is not applicable (e.g. no Supabase project), skip it entirely — don't print PASS for it
