# Resources & References

Additional resources and references for this tool directory.

[<- Back to Directory](README.md)

---

## API Endpoints

These are used for form submissions from the modals:

- **Submit Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/submit-tool`
- **Report Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/report-tool`
- **Suggest Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/suggest-tool`

## Modals

The user interface has three modals (no separate URLs, triggered via JavaScript):

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

## robots.txt

The site's obots.txt contains content signals (search, ai-input, ai-train) but no disallowed paths.

## Sitemap

The site does not have a `sitemap.xml` (returns 404).

---

*Last updated: 2026-07-06*