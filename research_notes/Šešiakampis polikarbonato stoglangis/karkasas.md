# Timber frame (hip rafters + central hub) for a hexagonal pyramid polycarbonate skylight on an existing hexagonal curb

Research note on method and sources. The egress proxy blocked direct page fetches for every site tried (blocklayer.com, jlconline.com and sbebuilders.blogspot.com all returned connect_rejected or DNS errors). So every web citation below comes from **search-result snippets**, not full pages. All geometry numbers were recomputed independently in Python (script logic is described in the Inferences sections) and cross-checked against the published formulas cited.

Input geometry used throughout:
- Regular hexagonal curb: outer side s = 1010 mm, inner side 930 mm. Therefore:
  - outer circumradius R = 1010 mm
  - outer apothem a = 874.7 mm
  - inner apothem 805.4 mm
  - curb wall width square to each side = 69.3 mm
  - radial depth at each corner = 80 mm
- Rise of the reference plane = 670 mm.

---

## 1. Verification of the computed angles and the standard formulas (hip pitch, face pitch, length, plumb/seat, backing, dihedral, side cuts)

### Takeaway
All five numbers given in the brief are correct when the run is taken to the **outer** curb corner (R = 1010 mm) and the face run to the outer apothem (874.7 mm):
- hip pitch 33.56°
- face pitch 37.45°
- hip line length 1212 mm
- dihedral between faces 144.6°
- backing 17.70° each side

The backing value matches the published formula tan(backing) = sin(hip pitch) / tan(plan angle), with plan angle = 60° for a hexagon (hip to eave).

### Cited Findings
- General hip backing formula: "Hip Rafter Backing Angle = arctan( sin(Hip Rafter Pitch Angle) ÷ tan(Plan Angle) )". The dihedral triangle is taken perpendicular to the hip run. — [Raftertools: C5 Timber Framing Angle](http://raftertools.com/TimberFraming/Angles/c5.html); [Raftertools: Dihedral angle help](http://www.raftertools.net/help/dihedral_angle.htm)
- The same structure appears in hip/valley framing notes: "Backing Angle = arctan (sin Hip-Valley Pitch Angle ÷ tan Plan Angle)". — [Geocities web_sketches: Hip and Valley Formulas](http://www.geocities.ws/web_sketches/framing_math/hip_valley_formulas.html)
- For a regular (90° corner) hip the formula reduces to "ArcTan[Sin(hip plumb angle)]", because tan 45° = 1. For irregular hips: "ArcTan[Sin(hip plumb angle) / Tan(CHK 1)]", where the cheek (plan) angle replaces 45°. — [Calculated Industries (TikTok how-to)](https://www.tiktok.com/@calculatedindustries/video/7222010645909114154)
- Polygon rafter tables (SBE Builders) define the plan angle from the polygon's central angle and give "Hip Side Cut Angle = arctan( cos(hip pitch angle) ÷ tan(plan angle) )". — [SBE Builders: Polygon Rafter Tables (PDF)](https://www.sbebuilders.com/tools/rafter-tables/Polygon_Rafter_Tables.pdf); see also [SBE Builders: Hexagon and Octagon Roof Framing Geometry](http://sbebuilders.blogspot.com/2012/06/hexagon-and-octagon-roof-framing.html) (page not reachable, title only) and [Hip Rafter Backing Bevel Angles, Hatfield (PDF)](http://www.sbebuilders.com/pdf/hip-rafter-backing-bevel-angle.pdf)
- A hexagon gazebo calculator gives hip length ≈ √((s + overhang)² + rise²), noting that for a regular hexagon the side s equals the radius. It calls the central hub "the tricky part", where six hips must meet flush. — [ConstructionCalcHub: Hexagon Gazebo Calculator](https://constructioncalchub.com/hexagon-gazebo-calculator/)
- Online tools exist for hexagon and octagon hip/common rafters with cheek-cut angles and birdsmouth layout. Examples are [rafter-calculator.com](https://rafter-calculator.com/calculators), [Learn Framing gazebo calculator](https://learnframing.com/gazebo-calculator/) and a 3–20-sided polygon app outputting "hip rafter angles, plumb cuts, and king post dimensions" ([App Store: Gazebo Roof Rafter Calculator](https://apps.apple.com/my/app/gazebo-roof-rafter-calculator/id6759833129)). Blocklayer's hexagon/gazebo calculators could not be reached (proxy-blocked), so they were not cross-checked.
- Low-quality SEO pages repeat a "4/12 → 33.69°" hip-angle figure that does not follow from the standard formulas. Ignore such pages. — [example of copied hip-calculator page](https://dashboard.ekuep.com/?p=67990)

### Inferences
These are my own computations. Each formula was checked two ways: by the published formula above and by 3-D face-normal vectors.

**Plan constants for n = 6**
- Central angle = 60°.
- Plan angle hip-to-eave θ = 60°.
- Plan angle hip-to-common rafter = 30°.
- R = s = 1010 mm; a = s·√3/2 = 874.7 mm.

**Hip pitch**
- tan p_h = rise/R = 670/1010 = 0.6634, so **p_h = 33.56°**.
- Alternative: tan p_h = tan p_f · cos 30°.

**Face (common) pitch**
- tan p_f = rise/a = 670/874.7 = 0.7660, so **p_f = 37.45°**.

**Hip line length** (reference line, outer corner to apex)
- √(1010² + 670²) = **1212 mm**.
- Face slant height (eave midpoint to apex) = **1102 mm**.

**Backing (bevel of hip top)**
- tan β = sin p_h / tan 60° = 0.5528 / 1.732, so **β = 17.70°**.

**Dihedral between adjacent faces**
- Method 1: 180° − 2β = **144.6°**.
- Method 2 (normals): cos α = sin²p_f · cos 60° + cos²p_f = 0.8152, so α = 35.40° and the dihedral = 180° − α = 144.60°. This matches.

**Plumb cut**
- The cut deviates from square by the hip pitch: miter-saw setting **33.56°**.
- The plumb line on the side face makes 56.44° with the rafter edge.
- **Do NOT use the "HIP/VAL" scale of a speed square or the 17-inch hip run of a framing square.** Those are for 90° (square) corners. Use the degree scale at 33.5–33.6°. (Inference: those scales are derived for 45° plan hips.)

**Seat (level) cut**
- Perpendicular to the plumb line.
- With the rafter lying on its side face: 56.44° from square, i.e. 33.56° from the long edge.

**Side (cheek) cut on top edge**
- For a vertical cut plane at plan angle φ from the rafter axis: tan(side cut, measured from the axis) = tan φ · cos p_h.
- A 6-way junction without a hub needs φ = 30° each side, giving **25.69° from the axis** (= 64.31° from a square line). This matches the SBE formula arctan(cos p_h / tan 60°).

**Compound saw settings for that no-hub 6-way wedge**
- Rafter flat on its side face: miter 33.56° + bevel 60°.
- Rafter standing on edge: bevel 16.05° + miter 64.31°.
- Both exceed the range of normal miter saws. This is a strong practical argument for a hub (see section 2).

**Sensitivity table** (rise → hip pitch / face pitch / backing / dihedral / hip length / face slant)

| Rise | Hip pitch | Face pitch | Backing | Dihedral | Hip length | Face slant |
|---|---|---|---|---|---|---|
| 600 | 30.71° | 34.45° | 16.43° | 147.1° | 1175 | 1061 |
| 620 | 31.54° | 35.33° | 16.81° | 146.4° | 1185 | 1072 |
| 640 | 32.36° | 36.19° | 17.17° | 145.7° | 1196 | 1084 |
| **670** | **33.56°** | **37.45°** | **17.70°** | **144.6°** | **1212** | **1102** |
| 700 | 34.72° | 38.67° | 18.20° | 143.6° | 1229 | 1120 |
| 730 | 35.86° | 39.85° | 18.69° | 142.6° | 1246 | 1139 |

All lengths in mm.

**Reference-plane caveat (important)**
- The 67 cm rise is the rise of a reference plane P whose eave line is the outer top edge of the curb. P is the underside of the sheets, i.e. the backed hip tops and the bevelled eave bearers.
- Real hips sitting on the curb put that eave line at some height h0 above the curb top. h0 is the hip's "height above plate", HAP (see section 5).
- If the pitch is kept, the apex of P ends up at **h0 + 670 mm** above the curb top. If the absolute apex height must stay at 670 mm, use rise = 670 − h0 and read the table above. For example, h0 = 50 mm gives rise 620 mm, hip 31.54°, backing 16.81°.

### Gaps
- Blocklayer (blocklayer.com) hexagon/gazebo calculators and the JLC octagon article could not be opened (proxy policy denial). So no direct screenshot-level cross-check with blocklayer outputs was possible. The formula sources above agree with each other and with the vector computation.

---

## 2. How hips meet at the top: hub vs. king post vs. no-hub cheek cuts; hub sizes; how hips are cut at the hub

### Takeaway
DIY and professional polygon roofs almost always bring the hips to a **central hub**. The hub can be a hexagonal timber block, or a king post that is temporary or permanent, or a steel gazebo tie. Each hip then needs only a **single plumb cut** at its top. A no-hub 6-way junction needs double compound cheek cuts (25.7° on the top edge, 60° effective bevel), which normal saws cannot make.

A hexagonal block with a face width at least equal to the hip width is the practical choice for this lantern:
- across flats 120 mm for hips up to ~69 mm wide, or
- across flats 140–150 mm for 70–80 mm hips.

### Cited Findings
- Russian DIY build: the central "lock" of the hexagonal gazebo roof was a **hexagonal prism of 200×120×120 mm timber**. Hips were fixed to it with home-made **galvanized roofing-steel plates**, and the top plate was screwed to the prism "strictly in the centre" with a **4.2×90 mm** self-tapping screw. The author recommends preparing the top ring and the rafter system with its central lock **on the ground**, to fit parts and get lengths and angles exactly. — [kak-svoimi-rukami.com: Шестигранная беседка… подробные чертежи](https://kak-svoimi-rukami.com/2017/09/shestigrannaya-besedka-na-dache-svoimi-rukami-podrobnye-chertezhi/)
- Another Russian guide: six bars (typically **150×50 mm**) converge at the centre on a timber spire with a metal "apron". Each bar is also fixed to the top ring at its corner. — [besedkis.ru: Шестигранная беседка](https://besedkis.ru/dlja_dachi/shestigrannaya-besedka)
- Alternative Russian method: three edge-on boards are half-lapped across the hexagon (two for a 4-sided roof, three for a 6-sided one), and a short vertical post at their crossing supports the rafters. — [nasha-besedka.ru: Беседка шестигранная](https://nasha-besedka.ru/vidy-i-formy/150-besedka-shestigrannaya-svoimi-rukami)
- For dome-type roofs, rafters joined at the apex "fan-wise into a closed chain" is called optimal. — [stylekrov.ru: Обрешетка для беседки](https://stylekrov.ru/obreshetka-dlya-besedki.html)
- Octagon framing: a solid octagonal block is made with a bevel on each edge "ready for all your hips to butt into". For a hexagon, the equivalent is six faces. — [JLC: Framing an Octagonal Roof](https://www.jlconline.com/training-the-trades/framing-an-octagonal-roof_o/) (snippet only)
- Deck-builder gazebo guide: a hub is built up from 2×4s, raised temporarily to the centre, and ridge (hip) rafters run from header-beam corners to the hub faces, followed by commons. — [decks.com: How to build a gazebo](https://www.decks.com/how-to/articles/how-to-build-a-gazebo)
- Hexagonal gazebo guide: rafters can be attached to a king post or to a small hub. A full-height king post "requires some extra work, as you'll have to dig a hole in the middle", but it adds firmness. "You can do without it." — [Garden Patch: How to Build a Hexagonal Gazebo Roof](https://www.gardenpatch.uk.com/how-to-build-a-hexagonal-gazebo-roof/)
- Pyramid framing guides mention "hip rafter deduction for central hub thickness" and the king post as a central anchor giving solid bearing. — [DecorDash: Pyramid Roof Framing](https://decordash.blog/pyramid-roof-framing-construction-guide)
- Metal alternative: **Simpson Strong-Tie GT6Z**, an 18-gauge galvanized gazebo tie connecting **six 2x rafters** at the top of a six-sided gazebo. It is two pieces, one above and one below the rafters. The decorative APGT6/APGTF versions need a minimum 2×6 rafter. — [Toolnut: Simpson GT6Z](https://www.toolnut.com/products/simpson-strong-tie-gt6z-gt-zmax-galvanized-18-gauge-gazebo-tie-for-6-2x-rafters-center); [Toolnut: APGT6](https://www.toolnut.com/products/simpson-strong-tie-apgt6-outdoor-accents-gazebo-tie-for-2x-top-of-gazebo); [Benefast: gazebo tie](https://benefast.com/product/gazebo-tie-2/)
- A patent describes a sheet-metal gazebo top connector with field-bendable arms for any pitch. — [US5197241A Gazebo top connection](https://patents.google.com/patent/US5197241)
- Rafters installed with brackets "require only two plumb cuts", one at the hub/ridge and one at the overhang. — [Hunker: How to Cut Rafters for an Octagon Gazebo](https://www.hunker.com/13413975/how-to-cut-birds-mouths-in-rafters)
- A square-gazebo plan uses a 4×4 centre post to carry the king post and 2×6 hips, with both hip ends cut at 25.5° for its own pitch. These angles do not transfer to a hexagon. — [MyOutdoorPlans: 10x10 Gazebo Hip Roof Plans](https://myoutdoorplans.com/pergola/10x10-gazebo-hip-roof-plans/)

### Inferences
Computed for this geometry.

**Hub faces**
- A hexagonal hub has its **flats facing the hips**, so each hip ends in one plain plumb cut at 33.56°, square across. The hub corners then point down the six face fall-lines.
- Hub side length = AF/√3, where AF is the across-flats dimension:

| AF (mm) | Side (mm) | Across corners (mm) | Hip top centerline at hub face, below apex of P (mm) | P at hub corner, below apex (mm) | Hip length along top centerline, hub face to outer-corner plumb line (mm) |
|---|---|---|---|---|---|
| 100 | 57.7 | 115.5 | 33.2 | 44.2 | 1152 |
| 120 | 69.3 | 138.6 | 39.8 | 53.1 | 1140 |
| 140 | 80.8 | 161.7 | 46.4 | 61.9 | 1128 |
| 150 | 86.6 | 173.2 | 49.8 | 66.3 | 1122 |

- Rule: hub side ≥ hip width. So:
  - 120×120 stock (as in the Russian build) suits hips ≤ ~65–69 mm wide.
  - 150×150 stock, planed to AF 140–150, suits 70–80 mm hips.
- Hub deduction along the hip = (AF/2)/cos p_h = 0.6·AF. That is 72 mm for AF 120 and 84 mm for AF 140, measured from the theoretical 1212 mm line.

**Hub height**
- Hip plumb height = depth/cos p_h = 1.20 × depth: 84 mm for a 70-deep hip, 114 mm for 95, 144 mm for 120.
- Example with AF 140 and 95-deep hips:
  - hip ridge at the hub face is 46 mm below the apex of P;
  - hip bottom at the hub face is 46 + 114 = 160 mm below the apex.
- A **flat-topped hub** must sit ≥ 62 mm below the apex of P, otherwise its corners touch the sheets. Set it ~65–70 mm below.
- A 160–200 mm tall block therefore gives full bearing for every hip, plus a small pendant below. This agrees with the 200 mm prism in the Russian build.
- Sheets stop short of the apex, and a hexagonal top cap (aluminium, zinc-coated steel or polycarbonate) covers the 6-way joint.

**Round post hub**
- Gives only line contact with a flat plumb cut. Avoid it, or flatten six facets.

**Simpson GT6Z**
- Sized for 2x (38 mm) rafters. It will not fit 60–80 mm hips without modification.

**No hub (not recommended)**
- Each hip gets a double cheek: plumb in elevation, 25.7° to the axis on the top edge, forming a 51.4° included point on the top.
- A traditional variant has one opposite pair butting square, with the other four needing mixed 60°/30° plan cheeks.
- Both are hard to execute accurately by DIY means.

### Gaps
- No source gave a quantitative hub-sizing rule. The "side ≥ hip width" and "height ≥ plumb height + clearance" rules above are derived from geometry.
- No Lithuanian-language source on the gazebo hub detail was found (searches for "šešiakampė pavėsinė stogas" were not productive). The Polish search ("altana sześciokątna więźba") returned only generic rafter-roof content.

---

## 3. Hip cross-section for ~1.2 m hips carrying 20 mm multiwall polycarbonate + snow; top width for sheet bearing; are intermediate rafters/purlins needed?

### Takeaway
Structurally even 45×70 C24 hips are lightly stressed: ~3.3 MPa in the conservative case below. Section size is governed by:
- **sheet edge bearing** — two sheets per hip, ≥ 20–25 mm each, plus a central gap;
- **hub and screw edge distances**;
- **stiffness**.

Recommendation: hips **60–80 mm wide** (70×95 is a good default), backed 17.7° each side.

Each triangular face spans at most 1.01 m hip-to-hip (at the eave). That is within the commonly published rafter-spacing maxima for 16–25 mm multiwall (1050–1250 mm). So intermediate rafters are optional, not essential, for typical Lithuanian snow. One mid-face jack per face is cheap insurance for snow zone II or drifting.

### Cited Findings
- The Birchwood P501 glazing-bar system is "designed for installing multiwall polycarbonate glazing onto **50mm wide rafters**". A supplier in the same results recommends installing a **60mm wide rafter at the hip**. (Snippet; the exact page carrying the 60 mm hip statement is not certain.) — [Birchwood Trading: P501 installation (PDF)](https://www.birchwoodtrading.co.uk/SiteDownloads/Rafter%20Glazing%20Bar%20Systems/P501%20Rafter%20Glazing%20Bar%20System/P501%20System%20Installation.pdf); [Birchwood: Glazing Centres info sheet (PDF)](https://www.birchwoodtrading.co.uk/SiteDownloads/Info%20Sheet%20-%20Glazing%20Centres.pdf)
- A snap-fit uPVC rafter bar has an **aluminium base 45 mm wide, 20 mm high**, so the rafter top must be at least that wide. — [Omega Build: Snapfix uPVC rafter glazing bar](https://www.omegabuild.com/shop/glazed-roof-bars-and-components/snapfix-upvc-rafter-supported-glazing-bar-for-10-16mm-polycarbonate-glazing)
- Most PVC-capped snap bars are made for 10/16/25 mm sheet. No bar explicitly rated for 20 mm was found. Aluminium screw-down capped bars suit "all thicknesses". — [The Glazing Shop: PVC capped rafter bar](https://www.theglazingshop.co.uk/pvc-capped-rafter-bar-10mm-16mm-25mm-white-brown.html); [Roofing Megastore: Corotherm rafter glazing bar](https://www.roofingmegastore.co.uk/corotherm-polycarbonate-sheet-rafter-glazing-bar.html)
- Rafter spacing for multiwall sheets:
  - 16 mm: **max ~1050 mm**; 25 mm: **max ~1250 mm**. — [The Polycarbonate Store: rafter spacing](https://www.thepolycarbonatestore.co.uk/polycarbonate-sheet-size-rafter-spacing-recommendations/); [PolycarbonateX: rafter spacing guide](https://polycarbonatex.co.uk/blogs/news/rafter-spacing-guide-for-polycarbonate-roofing-complete-uk-guide)
  - Another supplier lists 800–1050 mm for 25 mm. — [Clear Amber: best width for twinwall](https://clearambershop.com/en-us/blogs/trade-and-diy-blog/best-width-for-twinwall-polycarbonate-sheets)
  - A third gives far more generous figures (1500–1800 mm for 25 mm) and stresses that design loads come from the local code. — [polycarbonate.cc thickness chart](https://www.polycarbonate.cc/how-to-choose-polycarbonate-sheet-thickness/)
  - Sources conflict, so the conservative 1050 mm (16 mm) / 1250 mm (25 mm) figures are used here.
- Lithuanian characteristic ground snow load: **sk = 1.2 kN/m² (zone I) or 1.6 kN/m² (zone II)**. — [KTU thesis (PDF)](https://epubl.ktu.edu/object/elaba:14980853/14980853.pdf); [statybapigiau.lt load description (PDF)](https://www.statybapigiau.lt/images_mod/pdf/Apkrovos_KTU_2023_01_16.pdf)
  - Zone I includes e.g. Kaunas, Klaipėda, Šiauliai and Panevėžys counties; zone II includes Vilnius, Utena and Telšiai counties. Check the current STR edition. — [profa.lt: sniego apkrova](https://www.profa.lt/paprastai-ir-aiskiai-apie-sniego-apkrova)
  - The current standard is LST EN 1991-1-3:2025. — [LSD projektai](https://projektai.lsd.lt/lt/standartu/eurokodas-1-poveikiai-konstrukcijoms-1-3-dalis-sniego-apkrovos-1)

### Inferences
My calculations. Assumptions are stated; this is not a certified design.

**Plan areas**
- Per face 0.442 m²; total 2.65 m².
- Sloped glazing area 3.34 m², before overhang.

**Snow shape coefficient**
- I used the EN 1991-1-3 Table 5.2 relation μ1 = 0.8·(60° − α)/30° for 30° ≤ α ≤ 60°. This is from background knowledge and was not retrieved in this session.
- At α = 37.45°: μ1 ≈ 0.60. So s ≈ 0.72 kN/m² (zone I) or 0.96 kN/m² (zone II) on plan.
- The lantern sits on a roof and may collect drift. As a conservative case I also checked μ = 0.8 → 1.28 kN/m².

**Load per hip**
- Assumed dead load 0.10 kN/m² sloped, which is unverified (see Gaps).
- Design q = 1.35g + 1.5s = 1.25 / 1.61 / 2.09 kN/m² plan (zone I / zone II / conservative).
- Conservatively all load goes to the hips, with each hip taking one face-equivalent: W = 0.55 / 0.71 / 0.92 kN.
- Load is triangular, rising toward the eave. M_max ≈ 0.128·W·L_plan = 0.072 / 0.092 / 0.120 kNm.

**Bending stress, conservative case (2.09 kN/m²)**

| Section (mm) | Stress (MPa) |
|---|---|
| 45×70 | 3.26 |
| 45×95 | 1.77 |
| 70×70 | 2.09 |
| 60×90 | 1.48 |
| 70×95 | 1.14 |

- The design bending strength of C24 outdoors is roughly 12 MPa (kmod ≈ 0.65–0.8, γM = 1.3; background knowledge). Utilisation is therefore ≤ ~30% for every option, and deflection is negligible.

**Outward thrust and curb ring tension**
- The hub is not post-supported, so by symmetry it carries no shear. Each hip pushes out on the curb by H ≈ W·(L/3)/rise = 0.28 / 0.36 / 0.46 kN.
- In a hexagonal ring, each curb side carries tension T = H (2T·cos 60° = H). Each curb corner joint must hold ~0.3–0.5 kN in tension. That is easily done with 2–4 structural screws per corner, or a steel corner plate, but it must not be left to glue or toe-nails.

**Bearing width for 20 mm sheets on a backed hip**
- The faces meet at 144.6°. If both sheets' edges are cut square to the sheet face and their undersides touch at the hip centreline, the V-gap at the top surface is 2·20·tan 17.7° = **12.8 mm**. On top of that comes the expansion gap (≈3 mm per metre of sheet; see section 7).
- With a 70 mm hip: 35 mm per side, minus ~3–5 mm of central gap, leaves ~30 mm of bearing per sheet. That meets the ≥ 20–25 mm target and leaves room for sealing tape and the cap-screw line.
- With 60 mm: ~25 mm per sheet, which is the minimum.
- 45 mm (one standard board) is too narrow for two 20 mm sheets plus a cap.

**Spans and intermediate members**
- Sheet flutes run down the fall line (perpendicular to the eave). Each sheet then spans across the flutes from hip to hip.
- That span is 1010 mm at the eave and shrinks to 0 at the apex. It is supported on all three edges: two hips plus the eave bearer.
- 1010 mm is within the 1050 mm (16 mm) / 1250 mm (25 mm) maxima above. For 20 mm, interpolation gives ~1100–1150 mm (this is an interpolation, not a published value). **So no purlins are needed.**
- Optional mid-face jack (common) rafter, recommended for zone II, drift, or if anyone may lean on it:
  - one per face, from the eave midpoint toward the hub, at the face pitch of 37.45°, flat top (not backed);
  - it stops against the two hips just below the hub with plumb cheek cuts of **24.6° from its axis** on the top edge (tan = tan 30° · cos 37.45°);
  - this halves the sheet span to ≤ ~505 mm.

**Sheet triangle per face (for the sheet researcher)**
- Base 1010 mm and slant height 1102 mm at the curb outer edge.
- Apex half-angle 24.62°; the sheet's hip edge is at 24.6° to the flutes.
- With a plan overhang d past the curb face: base = 2(874.7 + d)·tan 30°, slant = 1102 + d/cos 37.45°. For example, d = 30 mm gives base 1045 and slant 1140 mm.

### Gaps
- No manufacturer load/span table for **20 mm** multiwall supported on three edges of a triangle was found. Confirm with the specific sheet's datasheet (Marlon/Polygal/Carboglass etc.).
- The weight of 20 mm multiwall (kg/m²) was not found in search results. The 0.10 kN/m² dead load (sheet + caps) is an assumption.
- The EN 1991-1-3 shape coefficient and the timber strength values were not retrieved from a source in this session (background knowledge).

---

## 4. Attaching hips to the existing curb; keeping it square and the hub centred; order of assembly

### Takeaway
Each hip lands on a curb corner with a level **seat cut**. The tail is cut plumb, flush with (or slightly beyond) the outer corner. Use a birdsmouth only if the curb width allows. Fix with screws plus a steel angle bracket or strap so that both the ~0.5 kN outward thrust and wind uplift are resisted.

Set the hub on a **temporary central post** at the exact centre, at the computed height. Install hips in opposite pairs, and check diagonals and planarity before final fixing. Alternatively, pre-assemble the ~25 kg frame on a full-size template on the ground.

### Cited Findings
- The birdsmouth is the notch where a rafter sits on the plate; the seat cut is the level cut bearing on the wall. — [JLC: A Simple Way to Lay Out and Cut a Hip Rafter](https://www.jlconline.com/training-the-trades/one-way-to-lay-out-and-cut-a-hip-rafter_o?o=1)
- Hip and common rafters need the same height above plate (HAP) so the roof planes line up. A hip's geometry otherwise puts its top corners above the planes, so it must be "dropped" or backed. — [ContractorTalk: hips and valleys](https://www.contractortalk.com/threads/hips-and-valleys.61506/)
- Dropping (lowering the seat) versus backing (bevelling the top): dropping is standard on production frames. Example: ~1/4" drop for 1-1/2" stock on a 6/12 roof. — [RedX Apps: How to cut a hip rafter](https://www.redxapps.com/guides/how-to-cut-a-hip-rafter)
- A practitioner advises dropping the hip into the wall framing so the seat has full bearing. The same thread says extending the seat cut far into the interior is not code-compliant because the rafter can split. — [GreenBuildingAdvisor: hip rafter confusion](https://www.greenbuildingadvisor.com/question/hip-rafter-confusion)
- Polygon gazebo hips form a birdsmouth over the header beam and need "fairly complex miter cuts across the top surface to allow your roofing to lay flat" (i.e., backing). — [HowToSpecialist: how to build a gazebo roof](https://howtospecialist.com/outdoor/gazebo/how-to-build-a-gazebo-roof/)
- Temporary centre support:
  - A builder recommends a temporary support tower at the exact centre: the king post is set on it and braced plumb, and the rafters are brought to it. He advises against building the whole roof on the ground and lifting it. (Low-reliability domain.) — [buildstatus.puri.sm: How to make a gazebo roof](https://buildstatus.puri.sm/make-gazebo-roof)
  - Contrasting view: the Russian build recommends preparing the ring and the rafter system with central lock on the ground. — [kak-svoimi-rukami.com](https://kak-svoimi-rukami.com/2017/09/shestigrannaya-besedka-na-dache-svoimi-rukami-podrobnye-chertezhi/)
- Kit-gazebo sequence:
  - The hub is lifted to ~110 in at the centre. One rafter is bolted to the hub and bracketed to a beam corner, then the remaining rafters follow. The top cap goes on only after all rafters. — [HON gazebo manual 43200-32 (PDF)](https://cdn.shopify.com/s/files/1/0561/4347/8958/files/43200-32_as.pdf)
  - Another kit supplies two temporary 2×2 supports, removed after installation. — [Atlas Gazebo manual (PDF)](https://edecks.co.uk/uploads/manuals/AtlasGazebo-2.4DEC21-ED.pdf?v3625)
- Russian builds fix each of the six hips at the top ring corner as well as at the hub. — [besedkis.ru](https://besedkis.ru/dlja_dachi/shestigrannaya-besedka)
- Commercial lantern installation stresses checking edge alignment and squareness along the eaves before fixing the eaves to the upstand. A "hip and ridge spider" is assembled at the top. — [Korniche Roof Lantern Installation Guide (PDF)](https://www.pclbuildingproducts.co.uk/wordpress/wp-content/uploads/2025/11/Korniche-LANTERN-2-installation-guide-web.pdf)

### Inferences
Computed and practical.

**Curb corner bearing**
- Radial depth at each corner is 80 mm (outer 1010 to inner 930 mm circumradius).
- The seat cut runs inward from the plumb tail cut at the outer corner, so seat length L_s ≤ 80 mm.
- Notch depth (plumb) at the tail = L_s·tan 33.56° = 0.663·L_s.
- HAP at the outer corner = plumb depth − notch:

| Hip depth (plumb height) | Seat 50 mm: notch / HAP | Seat 60 mm: notch / HAP | Seat 80 mm: notch / HAP |
|---|---|---|---|
| 70 (84) | 33 (39%) / 51 | 40 (47%) / 44 | 53 (63%) / 31 |
| 95 (114) | 33 (29%) / 81 | 40 (35%) / 74 | 53 (47%) / 61 |
| 120 (144) | 33 (23%) / 111 | 40 (28%) / 104 | 53 (37%) / 91 |

  All values in mm; the percentage is notch depth as a share of plumb height.
- A common rule of thumb is to keep the notch ≤ ~1/3 of depth (not sourced here; see Gaps). Good combinations are therefore 95 deep with a 50–60 mm seat (HAP 74–81 mm), or 120 deep with a 60–80 mm seat.
- **The chosen HAP = h0 fixes the height of the eave bearers (section 5) and lifts the apex of P to h0 + 670 mm.**

**Backing vs dropping**
- For glazing, back the hip. Dropping leaves the sheets bearing on two arrises only.
- Backing depth on each side face, measured square to the top edge: (b/2)·tan 17.7° = 7.2 mm (b = 45), 9.6 (60), **11.2 (70)**, 12.8 (80), 14.4 (90).
- The equivalent plumb "drop" would be 8.6 / 11.5 / 13.4 / 15.3 / 17.2 mm.
- How to cut it:
  - **Table saw:** hip lying on a side face, blade tilted 17.7°, rip along the top edge, then turn end-for-end for the second side. This leaves a centre ridge.
  - **Hand method:** strike a centreline on the top and lines 11.2 mm down each side face, then plane to the lines with an electric planer.

**Fixing hip to curb (suggested; not from a source)**
- Per hip: 2 partially threaded construction screws, Ø6–8 × 120–160 mm. Drive them through the seat area into the curb corner (toe-screwed from both sides), so they do not split the tail.
- Plus one steel angle bracket (≥ 70×70 mm, ribbed) or a twisted strap / hurricane-tie-type connector on the inside face.
- The curb itself must be anchored to the roof below against uplift.

**Fixing hip to hub**
- Two toe-screws Ø6 × 100–140 per hip into the hub, plus a galvanized or stainless strap or plate across the top or bottom face (as in the Russian build).
- Or a pair of six-arm plates above and below (GT6Z-style) if hips are 38–45 mm.

**Centering and squareness**
- Find the centre with three strings across opposite outer corners (each 2020 mm long; inner 1860 mm). Their crossing is the hub centre.
- If the three strings do not cross at one point, the curb is irregular. Measure all six sides and the three diagonals first and shim or plane the curb to level.
- Temporary post: a 45×45 or 70×70 prop from the floor below, cut so the hub top sits at curb top + h0 + 670 − ~65 mm (AF 140 hub). Brace it in two directions and plumb it with a level.
- Check: the six hub-centre-to-corner distances must be equal, and the hub flats must face their corners. Mark the hub flats 0°/60°/120°… with a line to each corner.

**Order**
1. Install the opposite hip pairs one after another (0° and 180°, then 60° and 240°, then 120° and 300°) so the hub is never pulled sideways.
2. Fix the hub end lightly first, then the seat. Re-check the hub plumb and centre, then fix fully.
3. Check planarity: a straightedge or taut string from each hip ridge to the next across the face, and from the hub to each eave midpoint.
4. Remove the prop after the eave bearers and corner fixings are in.

**Ground pre-assembly alternative**
- Frame mass ≈ 6 × 0.07 × 0.095 × 1.15 m³ × ~470 kg/m³ ≈ **21–23 kg**, plus the hub (~2–3 kg). Pre-assembling on a full-size plywood/chipboard template of the curb (corner marks at R = 1010) is practical for this size, then lift into place. It requires the template to replicate the real curb exactly.

**Cut a test hip first**
- Fit it, then use it as the template for the other five, as gazebo guides suggest.

### Gaps
- No source quantified the birdsmouth depth limit (the 1/3 rule is a common rule of thumb, not verified here).
- No source gave connector sizes for hip-to-curb uplift for this size. Hurricane-tie searches returned nothing hexagon-specific.
- Wind uplift on the lantern was not computed. The sheets and frame weigh only ~0.1 kN/m², so mechanical hold-downs are needed.

---

## 5. Eave support: bevelled bearer along each curb side

### Takeaway
Each sheet's bottom edge must bear on a surface in the glazing plane. Fix a **bevelled eave bearer** (tilting fillet) along each curb side, with its top at the face pitch of **37.45°**:
- outer edge height = h0, the same as the hips' HAP;
- inner edge height = h0 + 53 mm over the 69.3 mm curb width;
- ends cut square-down with a 30° plan miter so they butt against the hips' side faces.

Base-and-cap and lantern systems treat this bevelled ledger/eaves member as mandatory.

### Cited Findings
- In an aluminium base-and-cap polycarbonate system: "if using rafters, a beveled ledger board is required". Flutes follow the slope, and hips get flashing and sealing. — [Amerilux base & cap install guide (PDF)](https://ameriluxinternational.com/wp-content/uploads/2021/pdf-downloads/install-guides/amerilux-base-cap-install-guide.pdf); same system: [Domtek/Verolite base & cap guide (PDF)](https://www.domtek.ca/wp-content/uploads/2024/03/verolite-base-cap-install-guide-domtek.pdf)
- Glazing-bar guide: leave **~40 mm overhang past the eaves** so water drains into the gutter. Leave ~2 mm expansion clearance between sheets and snap-down bars. Minimum pitch 5°. — [Clear Amber: How to install polycarbonate sheets with Snapa glazing bars](https://www.clearamber.com/news/132/How-to-Install-Polycarbonate-Sheets-with-Snapa-Glazing-Bars.html)
- Commercial lanterns fix an eaves member to the upstand (curb) and check eaves alignment and squareness before fixing. — [Korniche Roof Lantern Installation Guide (PDF)](https://www.pclbuildingproducts.co.uk/wordpress/wp-content/uploads/2025/11/Korniche-LANTERN-2-installation-guide-web.pdf)
- End-closure (drip/end-stop) profiles exist in 6.4/10/16/25/28/35 mm sizes for polycarbonate sheet ends. — [Clear Amber: How to install roofing sheet end cap](https://clearambershop.com/en-us/blogs/how-to-video-series/how-to-install-end-stop-bar)
- Aluminium rafter-top glazing bars screw down into timber rafters in DIY lanterns. — [Clear Amber: 6 types of roof lantern](https://clearambershop.com/en-us/blogs/trade-and-diy-blog/6-types-of-roof-lantern-you-can-make-yourself-for-less)

### Inferences
Computed.

**Bearer cross-section**
- Trapezoid, 69.3 mm wide (the curb top width square to the side).
- Outer face height h0, inner face height h0 + 69.3·tan 37.45° = **h0 + 53.1 mm**, top bevel **37.45°** (the face pitch, NOT the hip pitch).
- Examples:
  - h0 = 44 mm (70×70 hip, 60 mm seat) → bearer 44/97 mm;
  - h0 = 74 mm (95-deep hip, 60 mm seat) → 74/127 mm.
- A tall bearer can be built up: a flat batten plus a ripped bevel strip.

**Bearer ends**
- The hip side faces are vertical and run at 60° to each curb side in plan.
- So each bearer end is a plain vertical cut at **30° miter, 0° bevel**, with the bearer lying on its flat underside. Exception: if the hip is narrower than the corner region, a short corner filler is needed.

**Planarity check**
- Lay a straightedge from the backed hip ridge across to the bearer bevel. It must touch both with no rock. Shim or plane the bearer, never the hip ridge.

**Overhang**
- Let the sheets overhang the curb outer face by 20–40 mm as a drip, unsupported beyond the bearer. Close the sheet's lower flute ends with breathable/anti-dust tape plus a U/end-stop profile with drainage.
- Consider a small drip strip under the overhang so water does not run back down the curb face.

### Gaps
- No manufacturer drawing of a timber tilting fillet for a pyramid lantern on a timber curb was found. The geometry above is derived, not sourced.

---

## 6. Timber choice, protection outdoors, and fasteners

### Takeaway
Use kiln-dried, strength-graded softwood: C24 spruce/pine or KVH/glulam for dimensional stability. Pressure-treat it (copper-based, e.g. Wolmanit CX, NTR A class) or use larch, and paint or stain all faces before glazing.

Fasteners should be stainless (A2 at minimum; A4 is safer next to copper-treated wood) or a high corrosion-class coating. Polycarbonate fixings must have integrated flexible sealing washers. Sources found were thin, so most of this section is inference.

### Cited Findings
- Copper-treated Swedish pine (Wolmanit CX, durability class NTR A) is rated for outdoor use. — [EPD: Impregnated wood products from pine, NTR A](https://environdec.com/library/epd31829)
- A2 stainless woodscrews are marketed as "suitable for use outdoors and in humid environments" (retailer claim). — [Fusion Fixings: A2 stainless woodscrews](https://www.fusionfixings.co.uk/collections/a2-stainless-steel-pozi-countersunk-woodscrews)
- A Norwegian forum user reports heavily corroded screws in older treated-wood terraces and asks whether A4 is worth it over A2. This is anecdotal. — [byggebolig.no forum](https://byggebolig.no/garasje-anneks-og-smahus/vedbu/30)
- For polycarbonate, "only screws fitted with an integrated, flexible sealing washer, matched in length to the thickness of the material and the type of substrate" should be used. Stainless or zinc-flake coated screws prevent rust staining the sheet. — [Marcopol: which screws for multiwall polycarbonate](https://marcopol.eu/which-screws-should-you-choose-for-multiwall-polycarbonate/)
- Do not overtighten fixings below the sheet surface, keep holes between ribs, and oversize holes for expansion. Neoprene-bonded washers are recommended. — [AC Plastics/UACI multiwall installation guide (PDF)](https://www.acplasticsinc.com/media/documents/UACI_140008_Multiwall_Polycarbonate_Installation_Guide_HR.PDF)

### Inferences
Not sourced in this session; practical guidance.

**Timber**
- KVH/C24 or glulam (e.g. 70×100 or 80×100 planed) twists less than green sawn pine. That matters because a twisted hip ruins the glazing plane.
- Kiln-dried timber (moisture content ~15–18%) should be acclimatised before cutting.
- Larch is naturally more durable but resinous and prone to splitting near ends. Pre-drill.

**Protection**
- Apply the paint or stain system (primer plus 2 coats of exterior opaque or semi-transparent finish) to all six faces and especially the end grain, after all cuts and before glazing.
- The hip tops and bearer bevels will be covered by tape or gaskets but still see condensation. Use a light-coloured finish to reduce heat build-up under the sheets.

**Fasteners**
- A4 stainless or C4/C5 coated construction screws next to copper-treated timber; A2 for untreated, painted spruce under cover.
- Do not mix galvanized and stainless parts in contact with copper preservatives without checking the screw maker's guidance.

### Gaps
- No authoritative (manufacturer or standard) statement was found on A2 vs A4 with copper-treated wood, nor on Lithuanian-market treatment classes (NTR/EN 335 use classes) for this use. Search returned only retailer and forum material.
- No Lithuanian-language DIY source on timber protection for lantern frames was found.

---

## 7. Typical step-by-step build sequence (DIY polycarbonate hexagonal skylight on an existing curb)

### Takeaway
The sequence below is pieced together from gazebo, kit and lantern guides plus the geometry above:
1. survey and strengthen the curb;
2. fix the reference plane (h0) and the cut list;
3. make the hub;
4. cut and test-fit one hip, then copy it;
5. erect the hub on a temporary post and fit the hips in opposite pairs;
6. fit the bevelled eave bearers (and optional mid-face jacks);
7. check planarity, finish, then glaze with expansion gaps.

### Cited Findings
- Hub raised temporarily at the centre first, hips from corners to hub faces next, commons after. — [decks.com: how to build a gazebo](https://www.decks.com/how-to/articles/how-to-build-a-gazebo)
- Kit order: hub at height → rafter bolted to hub and bracketed to corner → remaining rafters → top cap last. — [HON gazebo manual (PDF)](https://cdn.shopify.com/s/files/1/0561/4347/8958/files/43200-32_as.pdf)
- Ring and central lock can be prepared on the ground to fit lengths and angles accurately (Russian hexagon gazebo build, 200×120×120 hub). — [kak-svoimi-rukami.com](https://kak-svoimi-rukami.com/2017/09/shestigrannaya-besedka-na-dache-svoimi-rukami-podrobnye-chertezhi/)
- Further Russian step-by-step hexagon gazebo guides with drawings: [sovet-ingenera.com](https://sovet-ingenera.com/obustroystvo/shestigrannaya-besedka-svoimi-rukami.html); [bouw.ru drawing with dimensions](https://bouw.ru/article/chertezh-shestigrannoy-besedki-s-razmerami); [besedkas.ru: hexagon gazebo from beams](https://besedkas.ru/stroim-shestigrannuyu-besedku-iz-brusa/)
- Multiwall sheets go with flutes following the slope so condensation drains. — [Amerilux guide (PDF)](https://ameriluxinternational.com/wp-content/uploads/2021/pdf-downloads/install-guides/amerilux-base-cap-install-guide.pdf)
- Thermal expansion allowance, with sources differing:
  - ~1/8" per 3 ft at a 100 °F differential (≈3.5 mm/m) — [AC Plastics guide (PDF)](https://www.acplasticsinc.com/media/documents/UACI_140008_Multiwall_Polycarbonate_Installation_Guide_HR.PDF)
  - 3–5 mm per lineal metre — [ClearSpan glazing bar (PDF)](https://www.eboss.co.nz/assets/literature/41039/ClearSpan-Glazing-Bar-v.1.pdf)
- Multi-sided pyramid rooflights are made commercially over 6- or 8-sided openings. Rafter placement and glass size are set by the sides and slope. — [Royalite: pyramid skylight](https://www.royalite-mfg.com/pyramid-skylight/); standard pyramid pitch of 30° at one UK supplier — [White Sales: pyramid rooflights](https://www.whitesales.co.uk/products/rooflights/bespoke-rooflights/pyramid)

### Inferences
The proposed sequence, with numbers for this curb.

1. **Survey the curb.**
   - Measure the 6 outer sides (target 1010 mm) and the 3 corner-to-corner diagonals (target 2020 mm outer / 1860 inner).
   - Check the top is level all round (≤ ±2 mm) and the corner joints are sound.
   - Add corner screws or steel plates so each side can take ~0.5 kN ring tension.
2. **Choose h0 and the hip section.** Example: 70×95 C24 hips, 50–60 mm seat → h0 ≈ 74–81 mm. Decide whether the 670 mm rise is kept (apex of P at h0 + 670) or the rise is reduced (see the table in section 1).
3. **Make the hub.**
   - Use 150×150 stock planed to a hexagon AF 140 (side 80.8 mm), 180–200 mm tall.
   - Mark the flat centrelines and drill a centre hole for the plumb line or prop.
4. **Mark and cut one hip, then test-fit it.**
   - Top plumb cut at 33.56° from square.
   - Length along the backed ridge line, from the hub-face plumb line to the outer-corner plumb line: **1128 mm** (AF 140). This is 1140 mm for AF 120 and 1152 mm for AF 100. Add a tail allowance if extending past the corner.
   - Seat cut 50–60 mm long, level, ending at the tail plumb cut.
   - Back the top 17.7° each side (11.2 mm down each side for a 70 mm hip).
5. **Copy the test hip five times.** Clamp it to each blank to transfer the cuts.
6. **Erect.**
   - Centre point from the strings; prop at height; hub flats aligned to the corners.
   - Install opposite pairs, fixing the hub end first, then the seat. Fit angle brackets or straps.
7. **Fit the eave bearers.** Bevel 37.45°, outer height h0, inner h0 + 53 mm, ends 30° miter. Check coplanarity with a straightedge from each hip ridge.
8. **Optional:** one mid-face jack per face (24.6° top-edge cheek cuts against the hips) for zone II or drifting snow.
9. **Remove the prop.** Re-check the diagonals, hub plumb and planarity.
10. **Finish all timber** before glazing (all faces, end grain).
11. **Glaze** (covered by the polycarbonate researcher). In outline:
    - Cut the triangles: base 1010 + 2·d·tan 30°; slant 1102 + d/cos 37.45°.
    - Leave an expansion gap of ~3 mm per metre (~3–4 mm for 1.1 m sheets) at the hips and apex.
    - Tape the flute ends.
    - Bed the sheets on sealing tape on the hip bevels and bearers.
    - Fit hip caps able to cover a ≥ 13 mm V-gap plus expansion at the 144.6° dihedral.
    - Fit a top cap over the hub.

### Gaps
- No complete, documented DIY build of a timber-framed hexagonal polycarbonate *lantern* (as opposed to a gazebo) was found. The sequence above combines gazebo, kit and lantern sources with derived geometry.
- No YouTube, Instructables or Lithuanian forum build specific to a 6-sided polycarbonate skylight could be opened (fetch blocked; searches returned no specific matches).
