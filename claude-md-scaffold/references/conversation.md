# Phase 2: The Conversation (5-6 turns)

After silent analysis, ask the questions whose answers you can't infer from code. One per turn. Save partial answers as you go.

---

## Turn 0: Confirm analysis

Show the analysis summary (see [`analysis.md`](analysis.md) bottom). Wait for user confirmation. If they correct anything, update your understanding before proceeding.

---

## Turn 1: The 30-second pitch

```
What does this project do, in one sentence?

(Pretend you're explaining it to a senior engineer who's never seen it.
"It's a {type} that {does what} for {who}.")
```

**Save**: `{{pitch}}`. Used in root CLAUDE.md "Quick Context" section.

If user gives a 5-paragraph essay, ask them to compress to one sentence. The discipline matters.

---

## Turn 2: The one big rule

```
If a new contributor was about to break ONE architectural rule,
which one would cause the most damage? Name the rule.

Examples from other codebases:
- "All DB writes go through the repository layer — never inline SQL"
- "Services don't import from each other — go through the event bus"
- "Components are pure — no fetch calls, those live in hooks"
```

**Save**: `{{loadBearingRule}}`. Goes into the root CLAUDE.md as the "## The Big Rule" section, marked load-bearing.

If user says "we don't really have one" — push gently: "Even if it's implicit. What's the convention you'd defend in a PR?"

---

## Turn 3: Gotchas

```
Name 1-3 things that surprised you when you first joined this codebase.
Things you wish someone had told you on day one.

Format each like:
- Symptom: {what you see when you trip on it}
- Fix: {what you actually do}
- Why: {root cause, if you understand it}

(Stuck? Examples: weird env var names, build that needs cache clear,
a service that has to start before another, a config file in an unexpected place.)
```

**Save**: `{{gotchas}}` as array of `{symptom, fix, why}` objects. Goes into root CLAUDE.md "## Gotchas" section.

If user says "no gotchas, it's clean" — accept it. Note that section will be omitted.

---

## Turn 4: Folder hierarchy

Show the candidate list from analysis:

```
I think these folders deserve their own CLAUDE.md:
  - src/auth/    — looks like authentication
  - src/api/     — looks like API layer
  - src/db/      — looks like database

Confirm, add, or remove?
```

**Save**: `{{subFolders}}` as array of `{path, hint}` objects. Each will get a per-folder conversation in Turn 4b.

### Turn 4b (per sub-folder, only if user confirmed any)

For each confirmed sub-folder, ask one question:

```
For `src/auth/` — give me one sentence on what this folder does,
and one rule that's specific to it (or "no special rules").
```

**Save**: per-folder `{purpose, rule}`. Used in [`feature-template.md`](feature-template.md).

---

## Turn 5: Operational commands

```
Quick — give me the main commands. One line each.

Dev:    {how to run locally}
Build:  {how to compile/bundle}
Test:   {how to run tests}
Deploy: (optional) {how to deploy}
```

**Save**: `{{commands}}`. Goes into root CLAUDE.md "## Development" section.

If `package.json` scripts are obvious, skip this turn — just show the user what was detected and ask "right?".

---

## Turn 6: Preview + iterate

Generate the files (root + sub-folders). Show preview. Offer: A) Save all, B) Expand a section, C) Trim a section, D) Restart.
