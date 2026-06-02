---
notice: "Maintained by the rules plugin. Source: github.com/cameronsjo/rules"
---
# Web Research

## Blocked-Source Fallback

Link-heavy research (multi-source fact-finding, product research, deep-research workflows) reliably hits bot-blocked sources: retailers, review sites, paywalls. The fallback is a user decision, not an improvisation.

- **MUST** establish the blocked-source fallback via `AskUserQuestion` BEFORE starting link-heavy research, offering:
  1. Open blocked links in default browser — sane only (recommended)
  2. Open all in browser — no filter
  3. Save the list to a markdown file for manual pull
  4. Skip blocked sources and note the gap
- **MUST NOT** silently drop blocked sources from research results — list them with what each would have answered
- **MUST** apply the sanity filter before auto-opening any URL: the test is *"does this domain have any business being in this research?"*

## URL Sanity Filter

- **MAY** auto-open: HTTPS URLs whose domain matches the research subject (manufacturer, retailer, major publication) and which surfaced from a reputable search
- **MUST NOT** auto-open: URL shorteners, IP-literal URLs, punycode/homoglyph domains, off-context TLDs, or sources the research itself scored unreliable *and* unfamiliar
- **SHOULD** treat origin context, not country code, as the signal — a `.cn` domain is sane in a Chinese-manufacturer spec hunt and suspicious in a US appliance search

## Manual-Pull Recovery Loop

When the user pulls blocked pages manually (browser → clip → markdown):

- **SHOULD** ingest clips as raw sources following the project's source-layer conventions before folding findings into synthesis documents
- **MUST** record which blocked sources were recovered and what each changed, so the research's verification trail stays honest
