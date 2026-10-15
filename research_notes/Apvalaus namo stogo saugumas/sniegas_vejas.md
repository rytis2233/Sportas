# Snow and wind loads for a small round house with a conical roof in Žuvininkai, Lithuania (Eurocode + Lithuanian NA)

Research method note: the web-fetch tool and direct downloads were blocked in this session (DNS/proxy errors for lt.wikipedia.org, klaipeda.lt, elaba.lt, dlubal.com). All findings below come from search-engine extracts of the cited pages, not from reading the full documents. The official NA texts (LST EN 1991-1-3:2004/NA:2012, LST EN 1991-1-4:2005/NA:2012, LST EN 1990 NA) are paid documents and were not read directly. Values marked "verify" must be checked against those texts or the project engineer.

Hand-calculation assumptions under review: sk = 1.5 kN/m², μ = 0.8 for a ~35–40° cone, roof plan area ~86 m², outer wall diameter ~9.8 m, ~6 m to the top ring.

## Q0. Which Žuvininkai?

### Takeaway
Only one village called Žuvininkai turned up: Ginkūnai eldership, Šiauliai district municipality, northern Lithuania. It touches Šiauliai city, on the west shore of the Švedė pond / Lake Talša, about 55.94 N, 23.36 E. I found no Žuvininkai in Klaipėda county (Klaipėda district, Kretinga, Šilutė, Palanga, Neringa, Skuodas). Western-Lithuania values are still given below in case the site really is on the coast or the name is a near-match (for example Žibininkai near Palanga).

### Cited Findings
- Žuvininkai is a village in Šiauliai district municipality and also part of Šiauliai city, 1 km north of Salduvė hill — [lt.wikipedia: Žuvininkai (Šiauliai)](https://lt.wikipedia.org/wiki/%C5%BDuvininkai_(%C5%A0iauliai)); it is on the western shore of the Švedė pond — [lt.wikipedia: Švedės tvenkinys](https://lt.wikipedia.org/wiki/%C5%A0ved%C4%97s_tvenkinys)
- The Ginkūnai eldership lists Žuvininkai among its villages — [ginkunai.lt](https://www.ginkunai.lt/apie-seniunija/kaimai/zuvininkai/); Wikidata gives Ginkūnai eldership, Šiauliai District Municipality, 48 residents (2001) — [Wikidata Q12680890](https://www.wikidata.org/wiki/Q12680890), [Commons category](https://commons.wikimedia.org/wiki/Category:%C5%BDuvininkai)
- Weather services place it at Ginkūnai, Šiauliai District, about 55.94 N, 23.36 E — [weather.com](https://weather.com/lt/siauliai-district/ginkunai/locality/zuvininkai/today), [ventusky](https://www.ventusky.com/55.94;23.36)
- A similarly named village, Žibininkai, is in Kretinga district municipality, 4 km NE of Palanga — [en.wikipedia: Žibininkai](https://en.wikipedia.org/wiki/%C5%BDibininkai)
- Searches limited to Klaipėda, Kretinga, Šilutė and Palanga found no "Žuvininkai" in those areas (negative search result, see Gaps).

### Inferences
- The most likely site is Žuvininkai in Šiauliai district: inland, about 120 km from the Baltic coast, low and flat (about 100–130 m a.s.l. near Šiauliai; altitude not sourced).
- If "Klaipėda region" was meant loosely, the site may be another village, such as Žibininkai near Palanga. Confirm with the owner or the cadastral address (registrucentras.lt).

### Gaps
- Lithuanian Wikipedia's disambiguation page (lt.wikipedia.org/wiki/Žuvininkai) and the Gyvenamųjų vietovių registras could not be fetched. I cannot rule out a second, very small Žuvininkai (for example a hamlet or homestead name) elsewhere.

## Q1. Characteristic ground snow load sk in Lithuania (NA to LST EN 1991-1-3 / STR 2.05.04:2003)

### Takeaway
Lithuania has two snow-load regions. Region I is sk = 1.2 kN/m² and Region II is sk = 1.6 kN/m². Klaipėda (and Klaipėda county) and Šiauliai city are both in Region I, so sk = 1.2 kN/m². The assumed sk = 1.5 kN/m² matches neither region. It is about 25% conservative for Šiauliai or Klaipėda, and about 6% unconservative if the site were in Region II (Telšiai county: Plungė, Telšiai, Mažeikiai, Rietavas; Vilnius and Utena counties).

### Cited Findings
- STR 2.05.04:2003 "Poveikiai ir apkrovos" (Ministry of Environment order No. 233, 15 May 2003, in force 1 July 2003; consolidated edition from 2006-02-12 after order D1-622) gives the snow-region map in Annex 1. Region boundaries follow administrative district boundaries — [e-seimas TAIS.213447](https://e-seimas.lrs.lt/rs/legalact/TAD/TAIS.213447/), [Temidy](https://www.temidy.lt/teises-aktas/56642), [esavadai](https://www.esavadai.lt/dokumentai/1291/)
- Region I is 1.2 kN/m² (for example Kaunas, Klaipėda, Šiauliai, Panevėžys counties). Region II is 1.6 kN/m² (for example Vilnius, Utena, Telšiai counties) — [profa.lt "Paprastai ir aiškiai apie sniego apkrovą"](https://www.profa.lt/paprastai-ir-aiskiai-apie-sniego-apkrova) (a secondary, commercial source)
- Klaipėda project documents state Klaipėda is in snow region I, sk = 1.2 kN/m² — [klaipeda.lt project PP 2019](https://www.klaipeda.lt/data/public/uploads/2019/09/2.-projektiniu-pasiulymu-projektas.pdf), [klaipeda.lt J. Janonio g. 16 project](https://www.klaipeda.lt/data/public/uploads/2020/05/1-bd-dalis_nuasmeninta_2020-03-05.pdf)
- A Šiauliai project document states: "Pastatas projektuojamas Šiaulių mieste, kuris priskiriamas I sniego apkrovos rajonui. Sniego antžeminės apkrovos charakteristinė reikšmė sk = 1,2 kN/m²" — [siauliai.lt LITGRID Serbentų 49B PP](https://www.siauliai.lt/upload/media/user/170/Serbent%C5%B3-49B-rekonstravimas/Projektiniai%20pasi%C5%ABlymai%20PP.pdf)
- A Vilnius project document puts Vilnius in region II, sk = 1.6 kN/m² — [elaba appendix "Apkrovų skaičiavimas"](http://talpykla.elaba.lt/elaba-fedora/objects/elaba:2091290/datastreams/ATTACHMENT_2091300/content)
- A KTU load note for solar modules (2023) gives Lithuanian sk = 1.2 or 1.6 kN/m², citing EN 1991-1-3 together with STR 2.05.04:2003 — [statybapigiau.lt Apkrovos_KTU_2023_02_14.pdf](https://www.statybapigiau.lt/images_mod/pdf/Apkrovos_KTU_2023_02_14.pdf). A KTU thesis (Panevėžys) uses snow region I, 1.20 kN/m², with s = μ1·Ce·Ct·sk — [KTU ePubl](https://epubl.ktu.edu/object/elaba:152358924/MAIN)
- The NA currently in force is LST EN 1991-1-3:2004/NA:2012. A second-generation LST EN 1991-1-3:2025 is in the LSD drafts portal, with public enquiry 2026-05-03 to 2026-07-02 — [LSD projektai: EN 1991-1-3](https://projektai.lsd.lt/lt/standartu/eurokodas-1-poveikiai-konstrukcijoms-1-3-dalis-sniego-apkrovos-1), [older draft page listing replacement of /NA:2012](https://projektai.lsd.lt/lt/standartu/eurokodas-1-poveikiai-konstrukcijoms-1-3-dalis-sniego-apkrovos)
- Dlubal has an online Lithuania snow-zone map tool based on LST EN 1991-1-3 — [Dlubal snow LST EN 1991-1-3](https://www.dlubal.com/en/load-zones-for-snow-wind-earthquake/snow-lst-en-1991-1-3.html)
- The Vtpsi page (2026) still lists STR 2.05.04:2003 among construction technical regulations. No repeal was found — [vtpsi.lrv.lt STR list](https://vtpsi.lrv.lt/lt/teisine-informacija/teises-aktai-2/statybos-techniniai-reglamentai/)

### Inferences
- Summary table (sk):
  | Location | Snow region | sk (kN/m²) |
  |---|---|---|
  | Žuvininkai, Šiauliai district (most likely site) | I | 1.2 |
  | Klaipėda city / Klaipėda district / coastal Klaipėda county (Palanga, Kretinga, Neringa, Šilutė) | I | 1.2 |
  | Telšiai county (Plungė, Telšiai, Mažeikiai, Rietavas) — Žemaitija highland | II | 1.6 (verify per district on the map) |
- Sources call these "Region I/II" in both STR 2.05.04 and the Eurocode-era documents. The NA:2012 values appear to be the same 1.2/1.6 (KTU 2023 and post-2012 project documents use them with EN 1991-1-3 formulas), but I did not read the NA text itself.
- Šiauliai district is not Telšiai county. The profa.lt county grouping is approximate, though, so check on the Annex 1 map that Ginkūnai eldership (bordering Šiauliai city) is in Region I. The Šiauliai-city statement supports Region I.
- Keeping sk = 1.5 is a conservative choice for Region I (+25%). Report it as "conservative", not as the code value.

### Gaps
- The NA:2012 map and table text were not accessed directly. Exact district-by-district Region II boundaries are not confirmed.
- Whether the new LST EN 1991-1-3:2025 (2nd generation, with a revised sk map and partial factors) has been adopted or published as of October 2026 is unknown. After the enquiry it may be published but not yet mandatory.

## Q2. Roof shape coefficients for a 35–40° cone; unbalanced cases; cupola

### Takeaway
EN 1991-1-3 gives μ1 = 0.8 only for slopes 0–30°. For 30–60° it is μ1 = 0.8(60−α)/30, so 35° gives 0.667, 37.5° gives 0.60 and 40° gives 0.533. The assumed μ = 0.8 is conservative by 20–50% for the balanced case. EN 1991-1-3 has no rule for conical roofs. The usual practice is to treat the cone as a family of pitched-roof strips and check an asymmetric case: one half (windward) at 0.5μ1 and the other (leeward) at μ1, as in the duopitch rule. For a rafter-and-ring cone without a central post, this asymmetric case usually governs bending in the rafters and rings.

### Cited Findings
- EN 1991-1-3:2003 (base text) is available at [phd.eng.br EN 1991-1-3 PDF](https://www.phd.eng.br/wp-content/uploads/2015/12/en.1991.1.3.2003.pdf). Its Table 5.2 gives μ1 = 0.8 for 0° ≤ α ≤ 30°, 0.8(60−α)/30 for 30° < α < 60°, and 0 for α ≥ 60°. Section 5.3.3 / Fig. 5.3 gives the duopitch cases: (i) μ1(α1) and μ1(α2); (ii) 0.5μ1(α1) and μ1(α2); (iii) μ1(α1) and 0.5μ1(α2). These values are recalled from the standard and are well established, but the PDF was not opened here, so verify against the PDF.
- Secondary sources disagree on slope limits (one says μ1 = 1.0 up to 25°, which is an old SNiP/STR-style rule). The KTU-based summary flags this — [statybapigiau.lt KTU note](https://www.statybapigiau.lt/images_mod/pdf/Apkrovos_KTU_2023_02_14.pdf). Use the EN values.
- The roof snow formula is s = μi·Ce·Ct·sk (used in Lithuanian practice) — [KTU thesis](https://epubl.ktu.edu/object/elaba:152358924/MAIN)

### Inferences
- Computed μ1 values (0.8(60−α)/30): 35° gives 0.667, 37.5° gives 0.600, 40° gives 0.533.
- Balanced snow on the horizontal projection (Ce = Ct = 1.0):
  | Case | sk | μ | s (kN/m²) | × 86 m² = total (kN) |
  |---|---|---|---|---|
  | Assumed | 1.5 | 0.8 | 1.20 | 103 |
  | Region I, μ = 0.8 (simple, conservative) | 1.2 | 0.8 | 0.96 | 83 |
  | Region I, 35° | 1.2 | 0.667 | 0.80 | 69 |
  | Region I, 40° | 1.2 | 0.533 | 0.64 | 55 |
  | Region II, 35° | 1.6 | 0.667 | 1.07 | 92 |
- Geometry check: the plan area of a 9.8 m circle is π·4.9² = 75.4 m². A plan area of 86 m² means a roof diameter of about 10.46 m, which is consistent with eaves overhangs of about 0.33 m. Snow acts on the full horizontal projection, including the overhang, so 86 m² is right for the total. The wall-ring reaction perimeter is still about 9.8 m.
- Asymmetric (drift) case for the cone, by analogy with the duopitch rule: half the plan (a 180° sector) at μ1 and the other half at 0.5μ1. For Region I at 35°, that is 0.80 kN/m² on one half and 0.40 kN/m² on the other. The total is 75% of balanced, but it produces an overturning-type unbalanced moment on the ring/rafter system. In a radial rafter cone without a central column, the rafters push against a compression (top) ring and a tension (eaves/wall) ring. Under symmetric load the ring forces are pure axial. Under half-load the top ring is pushed sideways, the rafters on the loaded side take more thrust and bending, and the rings take in-plane bending. For a reciprocal-frame cone, unbalanced load is often the governing case. Check it separately; do not just use a larger μ on a uniform load.
- A more onerous "drift" pattern (a leeward sector of about 90–120° at a higher μ, such as 1.0–1.2·μ1) is sometimes used for domes and cones by analogy with the cylindrical-roof rule (EN 5.3.5, μ3 up to 2.0 for cylinders). That rule only applies to curved roofs with β < 60°. For a 35–40° straight-sided cone it is not required by the code, so it is an engineering judgement.
- Cupola / turret on top: its own small roof takes s = μ1(its pitch)·sk. The bigger issue is at the cupola's upslope base, where the cone slope ends against a vertical obstruction. EN 5.3.6 (projections/obstructions: μ2 = γh/sk with 0.8 ≤ μ2 ≤ 2.0, drift length ls = 2h) is written for low-slope roofs. On a 35–40° cone snow tends to slide rather than drift, so only a modest local accumulation ring is expected. With γ_snow ≈ 2 kN/m³ and a 0.5–1.0 m turret, the code formula would allow a local μ2 up to 0.8–1.7, which is conservative to check on the top ring.
- Sliding snow: 35–40° slopes shed snow, so snow guards (EN 6.4: Fs = s·b·sin α) and the impact zone at the eaves matter more than overhang loads (EN 6.3 is a recommendation for sites above 800 m, not relevant here).

### Gaps
- I found no Lithuanian or EN guidance that specifically covers conical roofs for snow. The JRC "Snow loads" background report was not retrieved.
- The Lithuanian NA may change Annex B (exceptional drift) or allow alternative μ values. Not verified.

## Q3. Exposure Ce, thermal Ct, exceptional snow

### Takeaway
Use the EN 1991-1-3 recommended values unless the NA says otherwise: Ce = 1.0 for normal topography, 0.8 for windswept, 1.2 for sheltered, and Ct = 1.0. A small rural house near a pond and fields is normally Ce = 1.0. Taking 0.8 needs open, unsheltered terrain on all sides with no trees, which is not usually justified for a house. Lithuania does not appear to require exceptional snow (Annex A Case B), but I could not confirm this.

### Cited Findings
- Lithuanian practice uses s = μ1·Ce·Ct·sk, with Ce and Ct from EN 1991-1-3 — [KTU thesis](https://epubl.ktu.edu/object/elaba:152358924/MAIN); [Klaipėda college calculation guide referencing STR 2.05.04 (form and exposure coefficients)](http://talpykla.elaba.lt/elaba-fedora/objects/elaba:22658383/datastreams/MAIN/content)
- EN 1991-1-3 Table 5.1 recommends Ce = 0.8 windswept, 1.0 normal, 1.2 sheltered. Clause 5.2(8) gives Ct = 1.0 except for roofs with high thermal transmittance (U > 1 W/m²K, for example glass) — [EN 1991-1-3 text](https://www.phd.eng.br/wp-content/uploads/2015/12/en.1991.1.3.2003.pdf) (values recalled, verify)

### Inferences
- For a well-insulated timber roof, Ct = 1.0. Do not reduce it for heat loss.
- Exceptional snow: the base EN Annex A lets the NA choose Case A (no exceptional loads) or B/C/D. The two-region Lithuanian scheme and project documents never mention s_Ad or Ces, which suggests Case A. Not confirmed.

### Gaps
- The Lithuanian NA choices for Ce, Ct, Annex A case and Cesl (exceptional snow coefficient) were not read.

## Q4. Wind: vb,0, terrain, peak pressure at 6–8 m, cp for cone/cupola, uplift

### Takeaway
Lithuania has three wind regions (10-min mean, 50-year return):
- Region I: vb,0 = 24 m/s, the whole country except II and III. This includes Šiauliai and Žuvininkai.
- Region II: 28 m/s, Plungė and Mažeikiai district municipalities.
- Region III: 32 m/s, the coastal strip about 20 km wide: Skuodas, Kretinga, Klaipėda and Šilutė districts, Palanga, Neringa and Klaipėda city.

With EN recommended profiles and cdir = cseason = 1, the peak velocity pressure at 6–8 m is about:
- Žuvininkai (24 m/s): 0.50–0.56 kPa in terrain III, 0.73–0.80 kPa in terrain II.
- Coastal Klaipėda (32 m/s): 1.30–1.42 kPa in terrain II, 1.73–1.83 kPa in terrain 0 at the shore.

### Cited Findings
- The meteo.lt design wind load calculator puts region III (vref,0 = 32 m/s) in Skuodas, Kretinga, Klaipėda and Šilutė districts plus Palanga and Neringa. Region II (28 m/s) is Plungė and Mažeikiai district municipalities. Region I is the rest of Lithuania. The default region is I — [meteo.lt Projektinės vėjo apkrovos skaičiuoklė](https://www.meteo.lt/kita/skaiciuokles/projektines-vejo-apkrovos-skaiciuokle/)
- The Dlubal Lithuania wind map tool (based on LST EN 1991-1-4:2005/NA:2012) offers vb,0 = 24, 28 and 32 m/s — [Dlubal wind LST EN 1991-1-4](https://www.dlubal.com/en/load-zones-for-snow-wind-earthquake/wind-lst-en-1991-1-4.html)
- Holmes (Extreme wind climates, world survey) says the 2003 Lithuanian loading code gave three zones of basic wind speed (10-min, 50-yr): 24, 28 and 32 m/s. The highest applies only to a strip about 20 km wide along the Baltic coast, and the same values appear in the Lithuanian NA to EN 1991-1-4 — [ebrary: Extreme Wind Climates](https://ebrary.net/206637/engineering/extreme_wind_climates_world_survey)
- The KTU solar-load note gives vb = 24, 28 or 32 m/s by region and qb = 0.5ρv² — [statybapigiau.lt KTU 2023](https://www.statybapigiau.lt/images_mod/pdf/Apkrovos_KTU_2023_02_14.pdf). A KTU thesis uses region I, vb,0 = 24 m/s — [KTU ePubl](https://epubl.ktu.edu/object/elaba:152358924/MAIN)
- Vaidogas and Juocevičius (2011) found that Lithuanian code wind speeds have been exceeded by large cyclonic storms more often than the 1-in-50-year assumption. The south-western part of the country is also hurricane-prone, and they propose separate hurricane regions — [VILNIUS TECH JEELM](https://journals.vilniustech.lt/index.php/JEELM/article/view/5320)
- Climatology: once every 15–20 years, coastal wind speeds reach up to 35 m/s, elsewhere up to 25 m/s — [MLE "vėjas"](https://www.mle.lt/straipsniai/vejas). Storm Anatolijus gave >40 m/s at Nida and 38 m/s at Klaipėda (gusts) — [15min.lt](https://www.15min.lt/gyvenimas/naujiena/ar-zinai/kai-virsta-medziai-koks-didziausias-vejo-greitis-kada-nors-buvo-uzfiksuotas-lietuvoje-1634-1289324)
- A revision, LST EN 1991-1-4:2026, was in public enquiry from 2026-08-16 to 2026-10-15 and will replace LST EN 1991-1-4:2005 + NA:2012 — [LSD projektai EN 1991-1-4](https://projektai.lsd.lt/lt/standartu/eurokodas-1-poveikiai-konstrukcijoms-1-4-dalis-vejo-poveikiai-1)
- The EN 1991-1-4 base text (terrain categories, ce(z), Table 7.4a duopitch cpe, 7.2.8 domes, 7.9 circular cylinders) is at [phd.eng.br EN 1991-1-4 PDF](https://www.phd.eng.br/wp-content/uploads/2015/12/en.1991.1.4.2005.pdf)

### Inferences
- Peak velocity pressure qp = ce(z)·0.5·1.25·vb² (kN/m²), computed with EN recommended formulas: kr = 0.19(z0/0.05)^0.07, Iv = 1/ln(z/z0), co = 1, cdir = cseason = 1. The Lithuanian NA may specify cdir/cseason/terrain parameters differently (verify).
  | Terrain (z0) | z | ce(z) | vb 24 | vb 28 | vb 32 |
  |---|---|---|---|---|---|
  | 0 sea/coast (0.003 m) | 6 m | 2.70 | 0.97 | 1.32 | 1.73 |
  | 0 | 8 m | 2.86 | 1.03 | 1.40 | 1.83 |
  | II open country (0.05 m) | 6 m | 2.04 | 0.73 | 1.00 | 1.30 |
  | II | 8 m | 2.21 | 0.80 | 1.08 | 1.42 |
  | III suburban/village (0.3 m) | 6 m | 1.39 | 0.50 | 0.68 | 0.89 |
  | III | 8 m | 1.57 | 0.56 | 0.77 | 1.00 |
  (qb: 24 m/s = 0.36 kPa, 28 m/s = 0.49 kPa, 32 m/s = 0.64 kPa.)
- Žuvininkai (Šiauliai district) is region I, 24 m/s. The village is on a pond/lake shore and next to fields. If the house faces open water or fields for a long distance, use terrain II (qp ≈ 0.80 kPa at 8 m). Terrain III (≈ 0.56 kPa) applies only with uniform cover of buildings or trees all round. A conservative single value for hand calculation is qp ≈ 0.8 kPa.
- On the coast (dunes, Palanga/Neringa/Klaipėda district) use terrain 0 or I with 32 m/s, giving qp ≈ 1.7–1.8 kPa at 6–8 m. That is more than twice the inland value.
- Pressure coefficients: EN 1991-1-4 has no conical-roof table. Common approximations:
  - Treat the cone like a duopitch roof of the same pitch (Table 7.4a, α = 30°–45°). Windward faces see small positive or negative values, and leeward/side zones are suction. Roughly, external suction cpe,1 for small areas (fixings, shingles) reaches about −1.5 to −2.0 in edge zones F/G for θ = 90° wind. These numbers are from memory of Table 7.4a; verify in the PDF.
  - Alternatively use the dome rules (EN 7.2.8 / Fig. 7.12) for the upper part. Or use literature/wind-tunnel data for cones, which show maximum suction near the apex and the side flanks.
  - Cylindrical walls follow EN 7.9 (cp,0 from +1.0 at the stagnation point to about −1.5 to −2.2 at the sides, depending on Re, then base suction).
- Uplift: for a light timber cone (shingles, battens, OSB), the critical combination is 1.0·Gk (or 0.9·Gk for EQU) − 1.5·Wk(uplift, cpe − cpi). Use cpe,1 (areas ≤ 1 m²) for shingle and batten fixings. Use cpi = +0.2 / −0.3 (EN 7.2.9 recommended when openings are not known), or the dominant-opening value if a large door or window can be open in a storm. Light shingles have little self-weight, so mechanical fixing and starter-course adhesion govern, especially at the eaves edge and near the apex.
- Cupola: it sits at the apex in high-speed, high-suction flow. Treat it as a small structure with drag (force coefficient cf ≈ 0.7–1.2 depending on shape), plus uplift on its roof, with qp taken at its top height (about 7–8 m or more). Check its connection to the top/compression ring for overturning and uplift. This is a typical failure point.

### Gaps
- Exact NA:2012 values for cdir (directional factors), cseason, terrain-category parameters and orography rules were not read.
- No published Lithuanian or EN pressure coefficients for conical roofs were found. Values for cones are an engineering approximation.
- The status of LST EN 1991-1-4:2026 after the enquiry (closed 2026-10-15) is unknown. It may change vb,0 maps or cprob/cdir.

## Q5. Partial factors and combination factors (LST EN 1990 NA)

### Takeaway
EN 1990 recommended STR/GEO factors are γG = 1.35 (unfavourable) / 1.0 (favourable) and γQ = 1.5, with ψ0,snow = 0.5 (CEN members other than Finland, Iceland, Norway and Sweden, H ≤ 1000 m) and ψ0,wind = 0.6. The older Lithuanian STR 2.05.04:2003 used ψ0,snow = 0.7 and ψ0,wind = 0.6, and γQ = 1.3 for snow and wind under the old STR method. I could not confirm whether the Lithuanian EN 1990 NA keeps 0.5 or uses 0.7 for snow. Using ψ0,snow = 0.7 is the safe choice.

### Cited Findings
- The STR 2.05.04:2003 ψ table gives "Statinių vėjo apkrova: ψ0 = 0,6, ψ1 = 0,2, ψ2 = 0" and "Statinių sniego apkrovos: ψ0 = 0,7, ψ1 = 0,5, ψ2 = 0,2" — [e-seimas TAIS.213447 (STR 2.05.04:2003)](https://e-seimas.lrs.lt/rs/legalact/TAD/TAIS.213447/), [actual edition](https://e-seimas.lrs.lt/rs/actualedition/TAIS.213447/SpZvKIooTB/)
- The KTU 2023 solar note uses wind ψ0 = 0.6 and snow ψ0 = 0.7, γG = 0.9 for uplift, and "vėjo ir sniego poveikio dalinis patikimumo koeficientas priimta γQ = 1,3" (STR-based), with cases such as G + S + 0.6W and G + 0.5S + W — [statybapigiau.lt KTU 2023](https://www.statybapigiau.lt/images_mod/pdf/Apkrovos_KTU_2023_02_14.pdf)
- profa.lt applies a factor of 1.3 to sk, giving 1.2 × 1.3 = 1.56 kN/m² ("156 kg/m²"). This follows the STR logic, not Eurocode — [profa.lt](https://www.profa.lt/paprastai-ir-aiskiai-apie-sniego-apkrova)

### Inferences
- For a Eurocode hand check, use γG = 1.35 / 1.0, γQ = 1.5, ψ0,S = 0.7 (conservative; 0.5 if the NA confirms the EN recommendation), ψ0,W = 0.6. Typical ULS combinations:
  - 1.35G + 1.5S + 1.5·0.6W
  - 1.35G + 1.5W + 1.5·0.7S
  - Uplift: 1.0G + 1.5W
- Mixing the STR γQ = 1.3 with Eurocode sk and μ values is inconsistent. Use one system.
- Example ULS snow on plan, Region I, μ = 0.8: 1.5 × 0.96 = 1.44 kN/m², about 124 kN on 86 m². The original assumption gives 1.5 × 1.2 = 1.80 kN/m², about 155 kN. With μ for 35°, 1.5 × 0.80 = 1.20 kN/m², about 103 kN.

### Gaps
- The LST EN 1990:2002/NA text (γ, ψ, and any KFI/consequence-class factors) was not accessed. Whether Lithuania adopted ψ0,snow = 0.5 or 0.7 in the NA is unconfirmed.
- The second-generation EN 1990:2023 (which changes partial factors for snow and wind) is not yet in force in Lithuania as far as found.
