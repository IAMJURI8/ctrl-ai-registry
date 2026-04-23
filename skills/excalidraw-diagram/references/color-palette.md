# Color Palette & Brand Style — Ctrl+AI v0

**This is the single source of truth for all colors and brand-specific styles in Ctrl+AI diagrams.** To customize for a different brand, edit this file — everything else in the skill is universal.

Ctrl+AI's product surfaces (Monitor, Registry) use a dark restrained palette. Diagrams live in Notion docs on light backgrounds, so this palette translates the same muted, professional tone to a white canvas: stone-slate neutrals, desaturated semantic accents, generous whitespace.

---

## Shape Colors (Semantic)

Colors encode meaning, not decoration. Each semantic purpose has a fill/stroke pair.

| Semantic Purpose | Fill | Stroke |
|------------------|------|--------|
| Primary/Neutral | `#e5e7eb` | `#374151` |
| Secondary | `#cbd5e1` | `#334155` |
| Tertiary | `#f1f5f9` | `#475569` |
| Start/Trigger | `#fde68a` | `#b45309` |
| End/Success | `#bbf7d0` | `#047857` |
| Warning/Reset | `#fecaca` | `#b91c1c` |
| Decision | `#fef3c7` | `#a16207` |
| AI/LLM | `#ddd6fe` | `#6d28d9` |
| Inactive/Disabled | `#e5e7eb` | `#9ca3af` (use dashed stroke) |
| Error | `#fecaca` | `#991b1b` |

**Rule**: Always pair a darker stroke with a lighter fill for contrast. Keep fills muted — saturated colors break the Ctrl+AI tone.

---

## Text Colors (Hierarchy)

Use color on free-floating text to create visual hierarchy without containers.

| Level | Color | Use For |
|-------|-------|---------|
| Title | `#111827` | Section headings, major labels |
| Subtitle | `#374151` | Subheadings, secondary labels |
| Body/Detail | `#6b7280` | Descriptions, annotations, metadata |
| On light fills | `#1f2937` | Text inside light-colored shapes |
| On dark fills | `#f9fafb` | Text inside dark-colored shapes |

---

## Evidence Artifact Colors

Used for code snippets, data examples, and other concrete evidence inside technical diagrams. Mirror the Monitor's dark surface tone.

| Artifact | Background | Text Color |
|----------|-----------|------------|
| Code snippet | `#0f172a` | Syntax-colored (language-appropriate) |
| JSON/data example | `#0f172a` | `#4ade80` (green) |
| Terminal output | `#0a0a0a` | `#e8e8e8` |

---

## Default Stroke & Line Colors

| Element | Color |
|---------|-------|
| Arrows | Use the stroke color of the source element's semantic purpose |
| Structural lines (dividers, trees, timelines) | Slate (`#374151`) or muted (`#9ca3af`) |
| Marker dots (fill + stroke) | Primary stroke (`#374151`) |

---

## Background

| Property | Value |
|----------|-------|
| Canvas background | `#ffffff` |

---

## Monitor Dashboard Reference (for alignment, not direct use)

The Ctrl+AI Monitor uses these tokens — diagrams should feel like they came from the same product, not identical:

- Background: `#0a0a0a` / `#141414` / `#171717`
- Foreground: `#e8e8e8` (primary), `#8a8a8a` (dim), `#5a5a5a` (faint)
- Success: `#7dd3a0` · Warning: `#d4a847` · Critical: `#d4756b`
- Lines: `#222222` / `#1b1b1b`

When a diagram shows a screenshot or mock of the Monitor, use these exact values. When it describes a system or process, use the shape/text tables above.
