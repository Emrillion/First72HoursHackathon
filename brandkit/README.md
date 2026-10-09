# CareShare brand kit

Open `index.html` in a browser for the complete responsive brand and component guide. Assets and fonts are local, so the kit works offline. For full browser support for SVG icon sprites and clipboard copying, serve this directory with `python3 -m http.server 4173 --bind 127.0.0.1` and open `http://localhost:4173`.

This is a brand proposal and component showcase, not an implemented care marketplace. The CareShare name was provided by the project owner. Service examples, prices, funding, owners, and confirmation events are fictional illustrations based on the proposed hackathon journey.

## Included

- `assets/careshare-brand-board.{svg,png}` — visual overview, 1600 × 1130.
- `assets/careshare-logo.{svg,png}` — primary logo; transparent PNG at 3×.
- `assets/careshare-logo-mono.{svg,png}` — one-color dark logo.
- `assets/careshare-logo-reversed.{svg,png}` — light logo for a dark teal surface.
- `assets/careshare-symbol.{svg,png}` — standalone shared-loop symbol.
- `assets/careshare-app-icon.{svg,png}` — 512 × 512 preview icon with rounded corners. Platform delivery may need an unrounded mask-safe export.
- `assets/favicon-32.png` — 32px browser icon.
- `assets/careshare-banner.{svg,png}` — 1600 × 600 web/presentation banner.
- `assets/careshare-social.{svg,png}` — 1200 × 630 social sharing card.
- `assets/icons.svg` — original 24px meal, ride, people, home, wallet, clock, check, arrow, and help symbols.
- `tokens.css` and `tokens.json` — shared design values.
- `components.css` — reusable, framework-independent component styles.
- `index.html`, `showcase.css`, `showcase.js` — responsive brand guide with live examples.
- `fonts/` — Manrope variable and static fonts with the SIL Open Font License.
- `BRAND-GUIDE.md` — usage, accessibility, voice, and reference notes.
- `contrast-report.json` — measured contrast for prescribed text/surface pairs.

All SVG lettering in exported brand assets is outlined, so fonts are not required to view or import them. Vector shapes remain editable in Figma, Illustrator, or other SVG editors. Update copy in `build-assets.cjs` and regenerate for new wording.

## Use the components

Load `tokens.css`, then `components.css`. Wrap the component region in `class="cs"`.

```html
<link rel="stylesheet" href="brandkit/tokens.css">
<link rel="stylesheet" href="brandkit/components.css">
<div class="cs">
  <button class="cs-button" type="button">Review your plan</button>
  <span class="cs-badge cs-badge--requested">Requested</span>
  <label class="cs-field" for="budget">Your spending limit
    <input id="budget" type="number" min="0" aria-describedby="budget-help">
    <small id="budget-help">$0 is welcome.</small>
  </label>
</div>
```

The showcase interactions are demonstrations: day selectors change the visible card, swatches copy HEX values where clipboard permissions allow, inputs show validation guidance, and mock approval reports the simulated payer split. No network requests, payment integrations, real bookings, accounts, or data persistence are included.

## Regenerate assets

Use Node.js with `@napi-rs/canvas` and `sharp` available, then run `node build-assets.cjs`. For externally installed packages set `NODE_PATH` accordingly. The included static fonts ensure reliable weight selection when outlining SVG text. Source assets are code-native vectors; no stock imagery or third-party logos are embedded.
