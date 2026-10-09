# CareShare / Brand guidelines v1.0

**Brand line:** Care, made easier together.

**Campaign line:** A little support. A lot less to carry.

**Purpose:** Help a family caregiver organize practical, non-clinical support during the first 72 hours after a hospital stay. The brand should feel calm, capable, and human. This kit is a proposed visual identity, not an approved product specification.

## Identity

The original shared-loop mark uses two open interlocking forms to suggest giving and receiving support. The wordmark uses Manrope Bold. It avoids a medical cross or a hospital emblem: CareShare helps coordinate everyday support.

Use the primary mark on white or Cloud. Use the reversed logo on Care teal or Deep ink. The monochrome dark logo supports one-color applications. Transparent PNGs are available for presentation tools; SVGs are preferred for interface and large-format use.

Clear space: at least one quarter of the displayed symbol height around the complete lockup. Minimum primary wordmark width: 144 CSS px. Minimum standalone symbol: 24 CSS px. The favicon has a dedicated 32px export. Do not stretch, rotate, outline, add shadows, recolor arbitrarily, or place on busy imagery. Preserve the supplied spacing between mark and wordmark.

## Palette

| Token | HEX | Role |
| --- | --- | --- |
| Care teal | #176B62 | Primary action, links, selected controls |
| Deep teal | #104C46 | Hover/pressed emphasis |
| Deep ink | #173C38 | Primary text |
| Muted | #526B65 | Supporting text |
| Cloud | #F7F9F5 | Main background |
| White | #FFFFFF | Cards and inputs |
| Soft mint | #DFF0E8 | Supportive panels and decorative fields |
| Apricot | #F4C7A5 | Small decorative highlights |
| Lilac | #EBE8F4 | Secondary accent and completed-state background |
| Border | #D7E2DC | Decorative card dividers |
| Input border | #789087 | Visible form boundaries |

Aim for roughly 75% white/Cloud, 15% mint, 8% teal/ink, and 2% apricot/lilac on marketing surfaces. This is a visual balance guide, not a rigid requirement. App screens should prioritize meaning: reserve error colors for actual problems; do not encode service categories or urgency only through color.

White text is for teal/ink fills, not mint or apricot. Use ink on pale accents. Use semantic tokens for requested (amber), confirmed (green), completed (lilac), and needs-attention (red). Show a word label and, where useful, a distinct icon. An accepted task and a completed task are different states.

## Type and layout

Manrope is bundled under the SIL Open Font License. Use the variable font in the browser and system sans-serif fallback. For scripts unsupported by Manrope, choose and test an appropriate language-specific font before release.

| Style | Desktop | Mobile | Weight / line height |
| --- | --- | --- | --- |
| Marketing display | 56–64px | 40–44px | 600 / 1.1–1.15 |
| Section heading | 32–40px | 28–32px | 600 / 1.2 |
| App heading | 28–32px | 26–30px | 600 / 1.2 |
| Body | 16–18px | 16px | 400–500 / 1.6 |
| Button | 16px | 16px | 700 / 1.4 |
| Label/support | 13–14px | 13–14px | 500–700 / 1.5 |

Use sentence case. Reserve spaced uppercase labels for short, secondary signposts. The brand-board image is a presentation composition, not a UI size specification. Keep critical interface copy at 16px and supporting copy at 13px or larger. Use tabular numerals for prices. Let translations wrap instead of shrinking them.

Build on a 4px base with common gaps of 8, 12, 16, 24, 32, 48, and 64px. Cards use 24px corners; inputs use 10px; pills use a full radius. Use a 1200–1280px maximum content width with generous outer margins. Collapse paired columns on mobile. Inputs and actions should be at least 48px high. Focus rings are 3px with 4px offset.

## Components and behavior

- **Primary button:** one main action per decision area. Verb + object: “Review your plan,” “Request this ride.” Teal default, deep teal hover, outlined focus, muted disabled.
- **Secondary button:** teal outline on white. Use for alternatives rather than a competing primary action.
- **Input:** visible persistent label, help below, and specific text feedback. Keep $0 available; never use a placeholder as the only label.
- **Service card:** task, time window, accountable owner, actual status, family cost, and next action. Provider acceptance and completion evidence must remain distinct.
- **Status:** Requested = awaiting acceptance. Confirmed = an owner/provider accepted. Completed = completion recorded with reporter. Needs attention = show a concrete next step. Planned reminders are not confirmed services.
- **Payment:** itemize services and fee, show total, each payer, and funding status. The demo uses $36 meals + $48 ride + $10 coordination = $94; family $20, assumed authorized demo sponsor $74. A payment approval does not confirm provider availability.
- **Recovery:** keep canceled needs visible, show alternatives and any changed family cost, and request approval before a replacement charge. Brand components only illustrate these behaviors.
- **Loading:** preserve button width, announce progress, prevent duplicate submission, and return an actionable failure message. No indefinite celebratory or urgent animation.
- **Empty state:** name what is missing and offer a single useful action. “No ride requested yet. Review ride options.”

Use the original icon sprite with 24 × 24 view boxes, 1.8px strokes, rounded caps, and no decorative fills. Pair unfamiliar icons with labels. Do not use an icon as a replacement for a status word.

## Voice and inclusion

Be specific before being cheerful. Use “You pay $20” rather than “Affordable care.” Say “Waiting for a reply” rather than “All set” when a task is pending. Avoid guilt, urgency countdowns, promises of health outcomes, and assumptions about family support.

Ask “Where will you be staying?” rather than assuming a permanent home. Accept self-coordination and no available helper. Put language selection early in the eventual product; do not show a language option as functional until the full flow is translated and reviewed. A housing referral is not proof of a place to stay. A funding lead is not authorized funding.

Any future photography should portray ordinary acts of support, diverse caregivers, and real daily environments with consent and appropriate image rights. Keep visual emphasis on agency and connection. The delivered kit uses original vectors only.

## Accessibility checks and limits

The included contrast report measures intended text/background combinations and input/focus boundaries. It is not a complete accessibility audit. Test real screens with keyboard navigation, screen readers, text enlargement, 320px layouts, and long/translated content. Labels and status words supplement color. Motion respects reduced-motion preferences. Read the full error message near the affected input; do not rely on a toast alone for a blocking issue.

## Design references

Reviewed October 9, 2026. These are inspiration references, not partners or endorsements; their logos, copy, and assets are not reused.

- [One Medical](https://www.onemedical.com/) — reference for generous whitespace, restrained surfaces, reassuring hierarchy, and prominent rounded actions. CareShare adopts these general layout principles while using its own typography and original mark.
- [Oscar](https://www.hioscar.com/) — reference for consumer-friendly healthcare navigation and clear paths to care, coverage, and member tasks.
- [Headspace](https://www.headspace.com/) — reference for approachable language and a human tone in a health-adjacent product.

The final visual choices are design judgments for CareShare, not claims about clinical effectiveness or a reproduction of any reference brand.
