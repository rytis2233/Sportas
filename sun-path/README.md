# Sun Path

A standalone web app (installable PWA) that draws the sun's path over the phone's camera view.

- **Live overlay** — the day's sun path (solid above the horizon, dashed below), hour dots, sunrise/sunset arrows, horizon with compass points, altitude scale and the current sun position. An edge arrow points to the sun when it is off screen.
- **Calibrate** — aim the crosshair at the sun and tap *Align to sun*, or drag to nudge; adjustable field of view.
- **Time Travel** — any date and time, with a slider and a play button.
- **Compare Dates** — a second path (e.g. a solstice) with sunrise, sunset, noon altitude and day length side by side.
- **Solstice Arcs** — June and December solstice and equinox paths.
- **Upcoming Eclipses** — solar eclipses visible from your location with local contact times and coverage; *Show in sky* replays the eclipse on the overlay.
- **Photo** — saves or shares the camera image with the overlay.
- English and Lithuanian.

Everything is computed on the device (`astro.js`): Sun from truncated VSOP87, Moon from Meeus' ELP-2000/82 series, eclipse contacts by searching topocentric disk overlap at each new moon, and magnetic declination from a degree-4 IGRF-13 model. Checked against Meeus' worked examples, 2024–2027 equinox/solstice times (±1 min) and the 8 April 2024 eclipse at Dallas (contacts within ~15 s of published times).

Orientation uses the gyroscope for smooth tracking; the compass only keeps it aligned to true north and is ignored while its readings are unreliable or jumping (gyro-only mode).

Needs HTTPS (camera and motion sensors). On iPhone open it in Safari, tap **Start** and allow motion and camera access; *Share → Add to Home Screen* installs it for offline use.

## Website preview

`?demo` shows a live preview for embedding (no camera, motion or location prompts): `<iframe src="https://rytis2233.github.io/Sportas/sun-path/?demo&lang=lt">`. Options: `&lang=lt|en`, `&body=moon`, `&lat=..&lon=..` (default Vilnius). The background is a 360° landscape photo (`sky.jpg`) drawn with WebGL so it turns with the overlay; the sky is computed from the real Sun and Moon (sunset colours, stars and moonlight at night). Sun shows daytime, Moon jumps to the nearest night with the Moon up. See `embed-example.html`.

360° sky panorama: "Sunflowers" by Sergej Majboroda, [Poly Haven](https://polyhaven.com/a/sunflowers), CC0. It is fetched by `.github/workflows/sky-panorama.yml`.
