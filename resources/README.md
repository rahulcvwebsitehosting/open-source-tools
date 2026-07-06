# Resources & References

Additional resources and references related to the source site ([fcksignups.com](https://fcksignups.com/)).

[<- Back to README](README.md)

---

## Site Information

| Property | Value |
|----------|-------|
| Website URL | [https://fcksignups.com/](https://fcksignups.com/) |
| Source Code | [https://github.com/BraveOPotato/FckSignups](https://github.com/BraveOPotato/FckSignups) |
| Report Issue | [https://github.com/BraveOPotato/FckSignups/issues/new](https://github.com/BraveOPotato/FckSignups/issues/new) |
| Data Source | `tools.json` hosted on GitHub raw (`https://raw.githubusercontent.com/BraveOPotato/FckSignups/refs/heads/main/tools.json`) |
| Fallback Data | Embedded in `src/constants/fallbackData.ts` |
| Framework | React + Vite + TypeScript |
| Hosting | Cloudflare Pages (likely) |

## API Endpoints (Cloudflare Workers)

These are used for form submissions from the modals:

- **Submit Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/submit-tool`
- **Report Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/report-tool`
- **Suggest Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/suggest-tool`

## Modals

The site has three modals (no separate URLs, triggered via JavaScript):

### 1. Submit a Tool
- **Title:** TOOL
- **Fields:**
  - Name (text, required)
  - Description (textarea, required)
  - URL (text, required)
  - Tags (text)
  - GitHub (text)
  - Category (select: Productivity, Design & Graphics, Development, Writing & Docs, Privacy, Utilities, Data & Analytics, Media)

### 2. Report a Tool
- **Title:** REPORT
- **Fields:**
  - Tool ID (text, required)
  - Report (textarea, required)

### 3. Suggest a Tool
- **Title:** SUGGESTION
- **Fields:**
  - Your tool idea (textarea, required)

## Site Text Content

### Header
- **Title:** "F*CK Signups"
- **Tagline:** "Open Source Tools. No Signups. Right in your browser"
- **Sub-tagline:** "A curated collection of open-source tools you can use instantly in your browser. no accounts, no emails, no tracking. Just tools that work."

### Footer
- **About:** "FckSignups is a curated directory of tools that respect your time. No signups, no spam, no dark patterns."
- **Contribute:** "Submit a tool" (opens modal), "Report an issue" (GitHub)
- **Legal:** "All tools are independently verified. We don't track you. We don't sell data. We don't care about your email."
- **Bottom Bar:** "AC 2026 FCKSIGNUPS /// CURATED WITH SPITE /// [GITHUB](https://github.com/BraveOPotato/FckSignups)"

## robots.txt

The source site's `robots.txt` contains content signals (search, ai-input, ai-train) but no disallowed paths.

## Sitemap

The site does not have a `sitemap.xml` (returns 404).

---

*Documentation sourced from [fcksignups.com](https://fcksignups.com/)* | *Last updated: 2026-07-06*
