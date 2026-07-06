param(
    [string]$ReferenceDir = "..\FckSignups-main",
    [string]$DocsDir = "FckSignups-Docs"
)

$ErrorActionPreference = "Stop"

# Read tools.json
$rawJson = Get-Content -Raw -Path "$ReferenceDir\tools.json" -Encoding UTF8
$toolsJson = $rawJson | ConvertFrom-Json

$categories = $toolsJson.categories
$tools = $toolsJson.tools

function Format-Stars {
    param([int]$s)
    if ($s -ge 1000) { return $s.ToString('N0', [System.Globalization.CultureInfo]::InvariantCulture) }
    return $s
}

# Collect external URLs and GitHub repos
$extUrls = @{}
$githubRepos = @{}
$allTags = @{}

foreach ($t in $tools) {
    if ($t.url) {
        $key = $t.url.ToLower()
        if (-not $extUrls.ContainsKey($key)) {
            $extUrls[$key] = @{ Url = $t.url; Ref = @($t.name); Type = 'Tool Website' }
        } else {
            $extUrls[$key].Ref += $t.name
        }
    }
    if ($t.github) {
        $key = $t.github.ToLower()
        if (-not $githubRepos.ContainsKey($key)) {
            $githubRepos[$key] = @{ Url = $t.github; Ref = @($t.name); License = $t.license }
        } else {
            $githubRepos[$key].Ref += $t.name
        }
    }
    foreach ($tag in $t.tags) {
        $allTags[$tag] = $true
    }
}

# Add site links
$siteLinks = @(
    @{ Url = 'https://github.com/BraveOPotato/FckSignups'; Type = 'GitHub Repository (Site)' }
    @{ Url = 'https://github.com/BraveOPotato/FckSignups/issues/new'; Type = 'Report Issue' }
    @{ Url = 'https://fcksignups-submit.abdullahalkafajy.workers.dev/submit-tool'; Type = 'Submit Tool API' }
    @{ Url = 'https://fcksignups-submit.abdullahalkafajy.workers.dev/report-tool'; Type = 'Report Tool API' }
    @{ Url = 'https://fcksignups-submit.abdullahalkafajy.workers.dev/suggest-tool'; Type = 'Suggest Tool API' }
)

foreach ($l in $siteLinks) {
    $key = $l.Url.ToLower()
    if (-not $extUrls.ContainsKey($key)) {
        $extUrls[$key] = @{ Url = $l.Url; Ref = @('Site Footer/Header'); Type = $l.Type }
    }
}

# Stats
$toolCount = $tools.Count
$catCount = ($categories | Where-Object { $_.id -ne 'all' }).Count
$tagCount = $allTags.Count
$extUrlCount = $extUrls.Count
$githubCount = $githubRepos.Count
$featCount = ($tools | Where-Object { $_.featured -eq $true }).Count
$now = Get-Date -Format 'yyyy-MM-dd'

# Helper to write file
function Write-MarkdownFile {
    param([string]$Path, [string[]]$Lines)
    $content = $Lines -join "`r`n"
    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::new($false))
}

Write-Host 'Generating README.md...'
$lines = @()

$lines += '# FckSignups Documentation'
$lines += ''
$lines += '> A curated collection of open-source tools you can use instantly in your browser - no accounts, no emails, no tracking. Just tools that work.'
$lines += ''
$lines += '**Website:** [https://fcksignups.com/](https://fcksignups.com/)'
$lines += '**GitHub:** [https://github.com/BraveOPotato/FckSignups](https://github.com/BraveOPotato/FckSignups)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Table of Contents'
$lines += ''
$lines += '- [Overview](#overview)'
$lines += '- [Statistics](#statistics)'
$lines += '- [Categories](#categories)'
$lines += '- [All Tools](#all-tools)'
$lines += '- [External URLs](#external-urls)'
$lines += '- [GitHub Repositories](#github-repositories)'
$lines += '- [Resources & References](#resources--references)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Overview'
$lines += ''
$lines += 'FckSignups is a curated directory of tools that respect your time. No signups, no spam, no dark patterns. Every tool listed is free, open-source, and usable directly in your browser without creating an account.'
$lines += ''
$lines += 'The site is built as a single-page application (React + Vite + TypeScript) and loads tool data from a hosted JSON file with a fallback embedded dataset.'
$lines += ''
$lines += '### Site Structure'
$lines += ''
$lines += '- **Root URL:** `/` - Main page with search, category filters, and tool grid'
$lines += '- **Modals (JavaScript-triggered, no separate URLs):**'
$lines += '  - **Submit a Tool** - Form to submit a new tool for inclusion'
$lines += '  - **Report a Tool** - Form to report an issue with an existing tool'
$lines += '  - **Suggest a Tool** - Form to suggest a new tool to be built'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Statistics'
$lines += '| Metric | Count |'
$lines += '|--------|-------|'
$lines += "| Total Tools | $toolCount |"
$lines += "| Categories | $catCount |"
$lines += "| Tags | $tagCount |"
$lines += "| Featured Tools | $featCount |"
$lines += "| External URLs (tools) | $extUrlCount |"
$lines += "| GitHub Repositories | $githubCount |"
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Categories'
$lines += ''
$lines += '| Category | Icon | Description | Tools |'
$lines += '|----------|------|-------------|-------|'

foreach ($c in $categories) {
    if ($c.id -eq 'all') { continue }
    $cnt = ($tools | Where-Object { $_.category -eq $c.id }).Count
    $catName = $c.name
    $catIcon = $c.icon
    $catDesc = $c.description
    $catLink = "./categories/$($c.id).md"
    $lines += "| [$catName]($catLink) | $catIcon | $catDesc | $cnt |"
}

$lines += ''
$lines += '[Browse all categories ->](./categories/)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## All Tools'
$lines += ''
$lines += "Below is the complete list of all $toolCount tools indexed on FckSignups."
$lines += ''
$lines += '| # | Tool | Category | Description | License | Stars |'
$lines += '|---|------|----------|-------------|---------|-------|'

$i = 1
foreach ($t in $tools) {
    $catObj = $categories | Where-Object { $_.id -eq $t.category }
    $catName = if ($catObj) { $catObj[0].name } else { $t.category }
    $lic = if ($t.license) { $t.license } else { '?' }
    $starStr = if ($t.stars) { Format-Stars $t.stars } else { '-' }
    $feat = if ($t.featured) { ' :star:' } else { '' }
    $name = $t.name
    $desc = $t.description
    $url = $t.url
    $lines += "| $i | [$name]($url)$feat | $catName | $desc | $lic | $starStr |"
    $i++
}

$lines += ''
$lines += '[Full tools listing ->](./tools/)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## External URLs'
$lines += ''
$lines += 'All external tool websites referenced on FckSignups.'
$lines += ''
$lines += '| # | URL | Type | Referenced In |'
$lines += '|---|-----|------|---------------|'

$i = 1
foreach ($key in ($extUrls.Keys | Sort-Object)) {
    $info = $extUrls[$key]
    $refs = ($info.Ref | Select-Object -Unique) -join ', '
    $url = $info.Url
    $type = $info.Type
    $lines += "| $i | [$url]($url) | $type | $refs |"
    $i++
}

$lines += ''
$lines += '[Full links listing ->](./links/)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## GitHub Repositories'
$lines += ''
$lines += 'All open-source repositories linked from tool entries.'
$lines += ''
$lines += '| # | Repository | License | Referenced In |'
$lines += '|---|------------|---------|---------------|'

$i = 1
foreach ($key in ($githubRepos.Keys | Sort-Object)) {
    $info = $githubRepos[$key]
    $refs = ($info.Ref | Select-Object -Unique) -join ', '
    $url = $info.Url
    $lic = if ($info.License -and $info.License -ne '?') { $info.License } else { 'Various' }
    $lines += "| $i | [$url]($url) | $lic | $refs |"
    $i++
}

$lines += ''
$lines += '[Full GitHub listing ->](./github/)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Resources & References'
$lines += ''
$lines += '- **Website:** [https://fcksignups.com/](https://fcksignups.com/)'
$lines += '- **Source Code:** [https://github.com/BraveOPotato/FckSignups](https://github.com/BraveOPotato/FckSignups)'
$lines += '- **Report Issue:** [https://github.com/BraveOPotato/FckSignups/issues/new](https://github.com/BraveOPotato/FckSignups/issues/new)'
$lines += '- **Tools Data Source:** `tools.json` hosted on GitHub raw'
$lines += '- **Fallback Data:** Embedded in `src/constants/fallbackData.ts`'
$lines += '- **API Endpoints (Cloudflare Workers):**'
$lines += '  - Submit Tool: `https://fcksignups-submit.abdullahalkafajy.workers.dev/submit-tool`'
$lines += '  - Report Tool: `https://fcksignups-submit.abdullahalkafajy.workers.dev/report-tool`'
$lines += '  - Suggest Tool: `https://fcksignups-submit.abdullahalkafajy.workers.dev/suggest-tool`'
$lines += ''
$lines += '---'
$lines += ''
$lines += "*Generated documentation from [FckSignups](https://fcksignups.com/)* | *Last updated: $now*"

Write-MarkdownFile -Path "$DocsDir\README.md" -Lines $lines
Write-Host 'README.md generated.'

# --- Category files ---
Write-Host 'Generating category files...'
foreach ($c in $categories) {
    if ($c.id -eq 'all') { continue }
    $catTools = $tools | Where-Object { $_.category -eq $c.id }
    $filename = "$DocsDir\categories\$($c.id).md"
    $catName = $c.name
    $catIcon = $c.icon
    $catDesc = $c.description
    $cnt = $catTools.Count
    
    $lines = @()
    $lines += "# $catIcon $catName"
    $lines += ''
    $lines += "> $catDesc"
    $lines += ''
    $lines += "**Tools:** $cnt"
    $lines += ''
    $lines += '[<- Back to Categories](../README.md#categories)'
    $lines += ''
    $lines += '---'
    $lines += ''
    $lines += '| # | Tool | Description | License | Stars |'
    $lines += '|---|------|-------------|---------|-------|'
    
    $i = 1
    foreach ($t in $catTools) {
        $name = $t.name
        $url = $t.url
        $desc = $t.description
        $lic = if ($t.license) { $t.license } else { '?' }
        $starStr = if ($t.stars) { Format-Stars $t.stars } else { '-' }
        $feat = if ($t.featured) { ' :star:' } else { '' }
        $lines += "| $i | [$name]($url)$feat | $desc | $lic | $starStr |"
        $i++
    }
    
    Write-MarkdownFile -Path $filename -Lines $lines
}
Write-Host 'Category files generated.'

# --- Tools master listing ---
Write-Host 'Generating tools listing...'
$lines = @()
$lines += '# All Tools'
$lines += ''
$lines += "Complete list of all $toolCount tools indexed on FckSignups."
$lines += ''
$lines += '[<- Back to README](../README.md)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '| # | Tool | Category | Description | URL | GitHub | License | Stars |'
$lines += '|---|------|----------|-------------|-----|--------|---------|-------|'

$i = 1
foreach ($t in $tools) {
    $catObj = $categories | Where-Object { $_.id -eq $t.category }
    $catName = if ($catObj) { $catObj[0].name } else { $t.category }
    $name = $t.name
    $url = $t.url
    $desc = $t.description
    $lic = if ($t.license) { $t.license } else { '?' }
    $starStr = if ($t.stars) { Format-Stars $t.stars } else { '-' }
    $feat = if ($t.featured) { ' :star:' } else { '' }
    $ghLink = if ($t.github) { "[GitHub]($($t.github))" } else { '-' }
    $lines += "| $i | [$name]($url)$feat | $catName | $desc | [Link]($url) | $ghLink | $lic | $starStr |"
    $i++
}

Write-MarkdownFile -Path "$DocsDir\tools\README.md" -Lines $lines
Write-Host 'Tools listing generated.'

# --- Links listing ---
Write-Host 'Generating links listing...'
$lines = @()
$lines += '# All External URLs'
$lines += ''
$lines += 'Every external URL referenced on FckSignups.'
$lines += ''
$lines += '[<- Back to README](../README.md)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '| # | URL | Type | Referenced In |'
$lines += '|---|-----|------|---------------|'

$i = 1
foreach ($key in ($extUrls.Keys | Sort-Object)) {
    $info = $extUrls[$key]
    $refs = ($info.Ref | Select-Object -Unique) -join ', '
    $url = $info.Url
    $type = $info.Type
    $lines += "| $i | [$url]($url) | $type | $refs |"
    $i++
}

Write-MarkdownFile -Path "$DocsDir\links\README.md" -Lines $lines
Write-Host 'Links listing generated.'

# --- GitHub repos listing ---
Write-Host 'Generating GitHub repos listing...'
$lines = @()
$lines += '# GitHub Repositories'
$lines += ''
$lines += 'All open-source GitHub repositories linked from tool entries.'
$lines += ''
$lines += '[<- Back to README](../README.md)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '| # | Repository | License | Referenced In |'
$lines += '|---|------------|---------|---------------|'

$i = 1
foreach ($key in ($githubRepos.Keys | Sort-Object)) {
    $info = $githubRepos[$key]
    $refs = ($info.Ref | Select-Object -Unique) -join ', '
    $url = $info.Url
    $lic = if ($info.License -and $info.License -ne '?') { $info.License } else { 'Various' }
    $lines += "| $i | [$url]($url) | $lic | $refs |"
    $i++
}

Write-MarkdownFile -Path "$DocsDir\github\README.md" -Lines $lines
Write-Host 'GitHub repos listing generated.'

# --- Resources ---
Write-Host 'Generating resources...'
$lines = @()
$lines += '# Resources & References'
$lines += ''
$lines += 'Additional resources and references related to FckSignups.'
$lines += ''
$lines += '[<- Back to README](../README.md)'
$lines += ''
$lines += '---'
$lines += ''
$lines += '## Site Information'
$lines += ''
$lines += '| Property | Value |'
$lines += '|----------|-------|'
$lines += '| Website URL | [https://fcksignups.com/](https://fcksignups.com/) |'
$lines += '| Source Code | [https://github.com/BraveOPotato/FckSignups](https://github.com/BraveOPotato/FckSignups) |'
$lines += '| Report Issue | [https://github.com/BraveOPotato/FckSignups/issues/new](https://github.com/BraveOPotato/FckSignups/issues/new) |'
$lines += '| Data Source | `tools.json` hosted on GitHub raw (`https://raw.githubusercontent.com/BraveOPotato/FckSignups/refs/heads/main/tools.json`) |'
$lines += '| Fallback Data | Embedded in `src/constants/fallbackData.ts` |'
$lines += '| Framework | React + Vite + TypeScript |'
$lines += '| Hosting | Cloudflare Pages (likely) |'
$lines += ''
$lines += '## API Endpoints (Cloudflare Workers)'
$lines += ''
$lines += 'These are used for form submissions from the modals:'
$lines += ''
$lines += '- **Submit Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/submit-tool`'
$lines += '- **Report Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/report-tool`'
$lines += '- **Suggest Tool:** `https://fcksignups-submit.abdullahalkafajy.workers.dev/suggest-tool`'
$lines += ''
$lines += '## Modals'
$lines += ''
$lines += 'The site has three modals (no separate URLs, triggered via JavaScript):'
$lines += ''
$lines += '### 1. Submit a Tool'
$lines += '- **Title:** TOOL'
$lines += '- **Fields:**'
$lines += '  - Name (text, required)'
$lines += '  - Description (textarea, required)'
$lines += '  - URL (text, required)'
$lines += '  - Tags (text)'
$lines += '  - GitHub (text)'
$lines += '  - Category (select: Productivity, Design & Graphics, Development, Writing & Docs, Privacy, Utilities, Data & Analytics, Media)'
$lines += ''
$lines += '### 2. Report a Tool'
$lines += '- **Title:** REPORT'
$lines += '- **Fields:**'
$lines += '  - Tool ID (text, required)'
$lines += '  - Report (textarea, required)'
$lines += ''
$lines += '### 3. Suggest a Tool'
$lines += '- **Title:** SUGGESTION'
$lines += '- **Fields:**'
$lines += '  - Your tool idea (textarea, required)'
$lines += ''
$lines += '## Site Text Content'
$lines += ''
$lines += '### Header'
$lines += '- **Title:** "F*CK Signups"'
$lines += '- **Tagline:** "Open Source Tools. No Signups. Right in your browser"'
$lines += '- **Sub-tagline:** "A curated collection of open-source tools you can use instantly in your browser. no accounts, no emails, no tracking. Just tools that work."'
$lines += ''
$lines += '### Footer'
$lines += '- **About:** "FckSignups is a curated directory of tools that respect your time. No signups, no spam, no dark patterns."'
$lines += '- **Contribute:** "Submit a tool" (opens modal), "Report an issue" (GitHub)'
$lines += '- **Legal:** "All tools are independently verified. We don''t track you. We don''t sell data. We don''t care about your email."'
$lines += '- **Bottom Bar:** "AC 2026 FCKSIGNUPS /// CURATED WITH SPITE /// [GITHUB](https://github.com/BraveOPotato/FckSignups)"'
$lines += ''
$lines += '## robots.txt'
$lines += ''
$lines += "The site's `robots.txt` contains content signals (search, ai-input, ai-train) but no disallowed paths."
$lines += ''
$lines += '## Sitemap'
$lines += ''
$lines += 'The site does not have a `sitemap.xml` (returns 404).'
$lines += ''
$lines += '---'
$lines += ''
$lines += "*Generated documentation from [FckSignups](https://fcksignups.com/)* | *Last updated: $now*"

Write-MarkdownFile -Path "$DocsDir\resources\README.md" -Lines $lines
Write-Host 'Resources generated.'

Write-Host 'All documentation files generated successfully!'
