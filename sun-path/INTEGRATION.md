# Sun Path ("Saulės kelias") — how to add it to a website

This file is meant for whoever (person or AI assistant) is adding the Sun Path preview to a website.
Everything needed is in this public repository: <https://github.com/rytis2233/Sportas>, folder `sun-path/`.

## What it is

Sun Path is a small web app with no dependencies: plain HTML, CSS and JavaScript, no build step and no external libraries. It draws the Sun's (or the Moon's) path across the sky over a camera view, with hour marks, sunrise and sunset, the horizon and compass points. All astronomy is computed in the browser (`astro.js`).

For websites there is a **demo mode** (`?demo`):
- It never asks for camera, motion or location permission and skips the start screen.
- The background is a real 360° photo (`sky.jpg`, drawn with WebGL), which turns together with the overlay when the visitor drags.
- The view drifts gently when nobody touches it. Visitors can drag to look around, switch Sun/Moon, open time travel, etc.

Live demo: <https://rytis2233.github.io/Sportas/sun-path/?demo&lang=lt>
Example page (the app inside a phone frame): <https://rytis2233.github.io/Sportas/sun-path/embed-example.html>

## Option A — embed with an iframe (recommended, nothing to host)

```html
<iframe src="https://rytis2233.github.io/Sportas/sun-path/?demo&lang=lt"
        title="Saulės kelias — peržiūra" loading="lazy"
        style="width:min(360px,100%);aspect-ratio:9/19.5;border:0;border-radius:46px;background:#000;
               box-shadow:0 0 0 11px #16181c,0 0 0 12px #3a3d44,0 30px 80px rgba(0,0,0,.55)"></iframe>
```

URL parameters, combined with `&`:

| Parameter | Effect |
|---|---|
| `demo` | Website preview mode (required for embedding). |
| `lang=lt` / `lang=en` | Language of the interface (Lithuanian / English). |
| `body=moon` | Start on the Moon instead of the Sun. |
| `lat=54.90&lon=23.89` | Location of the sky shown (decimal degrees). Default: Vilnius (54.6872, 25.2797). |

Notes:
- **Size.** The app is designed for a phone-shaped area (about 9:19.5). It also works wider: the sky simply shows more. Keep it at least about 320 × 600 px so the controls fit.
- **Styling.** The `style` above draws a phone frame (rounded corners plus a dark ring made with `box-shadow`). It can be removed or changed freely to match the site.
- **Mobile scrolling.** Inside the iframe, dragging turns the sky, so a finger on the iframe does not scroll the page. On phones, don't make the iframe full width and full height. Leave page margins around it so visitors can still scroll.
- **Content-Security-Policy.** If the site has a CSP header, allow `frame-src https://rytis2233.github.io`.
- **Platforms.**
  - WordPress: "Custom HTML" block.
  - Wix: Embed → Embed HTML.
  - Squarespace: Code block.
  - Hostinger Website Builder: Embed code element.
  - Webflow: Embed element.
  - React/Next.js: use the same `<iframe>` with `style={{...}}` as an object.
- **Updates.** The iframe always shows the latest version from GitHub Pages.

## Option B — host the files on the website itself

Copy these files from `sun-path/` into one folder on the site, keeping their names:

`index.html`, `app.js`, `astro.js`, `sky.jpg`, `manifest.webmanifest`, `sw.js`, `icon-180.png`, `icon-192.png`, `icon-512.png`

Raw download base: `https://raw.githubusercontent.com/rytis2233/Sportas/main/sun-path/<file>`

Then embed `<that-folder>/?demo&lang=lt` with the iframe above, or link to it.
- No build or server code is needed; any static hosting works.
- The full app without `?demo` uses the camera and motion sensors, which browsers allow only over **HTTPS**.

## Customising (Option B, or a fork)

- **Interface colours.** Edit the CSS variables in `index.html` under `:root`: `--sun`, `--moon`, `--glass`, `--font`, …
- **Sky drawing colours.** Edit the `COL` object in `app.js` (search for `const COL =`). This covers the path, Moon, compare line and north marker.
- **Texts.** Edit the `STR` object in `app.js`. It has `en` and `lt` blocks, for example `appName` and `tagline`.
- **Default location in demo mode.** In `app.js`, search for `lat: 54.6872`. Or simply pass `&lat=..&lon=..` in the URL.
- **Background photo.**
  - Replace `sky.jpg` with any **equirectangular 360° photo** (2:1, e.g. 4096 × 2048 JPEG, about 1–2 MB).
  - In `app.js`, set `PANO_SUN_U` to the horizontal position (0…1 of the width) of the photo's own sun or brightest sky. The photo is turned so that spot faces the real Sun.
  - Pick a photo where the sun itself is hidden by clouds, so the drawn Sun is not doubled.
  - `.github/workflows/sky-panorama.yml` can fetch CC0 panoramas from Poly Haven.
- **Don't change:**
  - The astronomy in `astro.js`. It is validated against reference data (Meeus' examples, equinox times, NASA eclipse contacts).
  - The projection maths in `app.js`.

## Credits and licences

- Background photo: "Sunflowers" by Sergej Majboroda, Poly Haven (<https://polyhaven.com/a/sunflowers>), CC0. No attribution is required, but it is welcome.
- App code: by the repository owner (rytis2233).

## Related

- Full web app (camera, live sensors): <https://rytis2233.github.io/Sportas/sun-path/>
- Native iPhone version: `sun-path-ios/`. It is installed with Sideloadly; see that folder's README.
