# Compression ring / tension ring conical roofs (no central column): forces, ring design, wire-rope tension ring, failure modes

Roof being checked: D ≈ 9.8 m (R ≈ 4.9 m), 28 radial rafters 50×200, 14-sided wall plate 200×200 on 14 posts, heptagon compression ring with 1.01 m sides (4 rafters per side), rise ≈ 3 m, steel wire rope wrapped round the plate as the tension ring. Hand calculation so far: H ≈ 3.4 kN per rafter (ULS), hoop force ≈ 15 kN (ULS).

Research limitation: in this session WebFetch could not reach any page (DNS / egress-proxy refusals for eng-tips.com, tfguild.org, yurts.com, certex.com, naturalbuildingblog.com). Everything cited below comes from search-engine summaries of those pages, not from reading the full text. Numbers marked "inference" are my own statics. They use the geometry above and standard textbook or Eurocode material values that were not re-fetched here.

---

## 1. How are compression/tension ring forces computed, is T = n·H/(2π) correct, and what does unbalanced snow do?

### Takeaway
T = n·H/(2π) is correct (exact polygon form: T = H/(2·sin(π/n))). For n = 28 the two differ by only 0.2 %, so ≈15 kN ULS for H = 3.4 kN checks out. Under one-sided snow the hoop force does not go up, but rafter bending, ring vertical shear, ring sway/rotation and ring-corner tension do. The no-column ring roof works like a set of three-hinged arches. It needs diaphragm or bracing action (sheathing, blocking, moment-resisting ring corners) to stop the ring racking or twisting.

### Cited Findings
- PCI Journal 1966, "Circular Roofs with Radial Framing": ring forces are obtained from the total moment divided by the vertical distance between the compression and tension rings. N is the horizontal thrust per rib, n is the number of ribs. (The extracted equations were garbled, so check the original scan.) — [PCI Journal 1966](https://www.pci.org/PCI_Docs/Publications/PCI%20Journal/1966/December-1966/Circular%20Roofs%20with%20Radial%20Framing%20Student%20Activities%20Physical%20Education%20Building.pdf)
- Eng-Tips practitioners: the classic approach checks the ring with Roark's circular-ring formulas (bending and buckling) and treats the rafters as beam-columns. A square (4-sided) ring needs at least one member across opposite corners to be stable. — [Eng-Tips "Roof Compression Ring"](https://www.eng-tips.com/threads/roof-compression-ring.422478/); [Eng-Tips tank compression ring & rafter design](https://www.eng-tips.com/threads/tank-compression-ring-and-rafter-design.488744/)
- Eng-Tips, square compression-ring roof: three things to check are (1) strength under balanced load, (2) racking in plan under unbalanced load, and (3) pitching about a horizontal axis. Diaphragms can be modelled as equivalent cross-bracing, and temporary bracing may be needed during erection. — [Eng-Tips "Roof Compression Ring"](https://www.eng-tips.com/threads/roof-compression-ring.422478/)
- Eng-Tips, 100-year-old large conical timber roof: the engineer's analysis matched the observed buckling only when the transverse beams were assumed to act as a compression ring. A commenter argued that the roof sheathing boards also carry part of the thrust in tension. — [Eng-Tips 100-yr conical roof](https://www.eng-tips.com/threads/100-year-old-large-conical-wood-framed-roof-compression-ring.435528/)
- CR4 tank-roof thread: how the ring behaves depends on the load case, and unbalanced snow or wind can change the outcome. A compression ring can buckle unless cross-members shorten its unsupported length. — [CR4 Conical Tank Roofs](https://cr4.globalspec.com/thread/81623/Conical-Tank-Roofs)
- Steel silo conical roof study (18.34 m diameter): asymmetric (sector) snow raised normal stresses by up to ~23 % and vertical displacements by up to ~50 % compared with balanced snow. EN 1991-1-3 covers asymmetric snow patterns but does not list conical roofs specifically. — [ResearchGate silo roof snow study](https://www.researchgate.net/publication/321188472_Effects_of_different_snow_load_arrangements_on_steel_silo_roof_structures)
- Pacific Yurts: the tension cable around the top of the wall resists the roof's outward thrust. Cable tension must be equal on both sides, because uneven tension can pull rafters off the centre ring and weaken the structure under snow or wind. — [Pacific Yurts durability page](https://www.yurts.com/what-makes-a-yurt-durable-inside-the-build-of-a-pacific-yurt/); [Pacific Yurts set manual](https://www.yurts.com/download/pacific-yurts-set-manual-12-14-16-yurts/)
- Ring beams in prehistoric roundhouses: roof weight tends to spread the rafters outward, lowering the apex and pushing the wall stakes out until collapse. A ring beam high in the wall turns the load into vertical load down the wall. — [Gefrin roundhouse construction](https://gefrin.com/roundhouses-construction/)

### Inferences (own statics; please re-verify)
**Hoop force, exact form.** A closed n-gon with equal inward radial nodal forces H at the corners has axial force T = H / (2·sin(π/n)).
- n = 28: sin(6.43°) = 0.1120, so T = 4.466·H. This compares with n/(2π) = 4.456·H.
- With H = 3.4 kN, T ≈ 15.2 kN. The user's 15 kN is correct.
- The same formula gives the compression in a 28-node ring. The 7-sided ring with 4 rafters per side is a different case (see section 2): its side axial force is ≈ F_side/(2·tan(π/7)) ≈ 1.04·F_side ≈ 4.0–4.2·H ≈ 14 kN, plus bending.

**Thrust per rafter.** Take moments about the plate bearing, assuming symmetric load and zero vertical shear at the ring. Then H·h = Σ(load × horizontal distance from the plate).
- Tributary width grows with radius (w(r) = 2πr/n). For a uniform plan load q, from r0 to R: H = (q·2π/(n·h)) · ∫ r·(R−r) dr.
- With r0 = 1.16 m (heptagon circumradius = 1.01/(2·sin(π/7)) = 1.164 m), R = 4.9 m, h = 3.0 m, n = 28: H ≈ 1.26·q (kN, q in kN/m² plan). Add the ring self-weight and any skylight load: P_ring·(R−r0)/(n·h).
- So H = 3.4 kN corresponds to q_ULS ≈ 2.7 kN/m² of plan. Plausible for 1.35·g + 1.5·μ1·s_k. μ1 for pitch ≈ 38.7° (rise 3 / run ≈ 3.74) is 0.8·(60−38.7)/30 ≈ 0.57 per EN 1991-1-3 (formula from memory; the Lithuanian s_k value still needs to be confirmed).
- Taking the plate at its centreline rather than the outer edge shortens the run slightly and lowers H a little.

**Three-hinge behaviour.**
- Each diametrically opposite rafter pair plus the ring behaves like a three-hinged arch (hinges at the two plates and the "crown" ring).
- With full uniform load on span L and rise h: H = w·L²/(8h).
- With load on one half only:
  - H drops to w·L²/(16h).
  - A vertical shear V = w·L/8 has to pass through the crown (the ring) from the loaded to the unloaded side. The unloaded rafter gets pushed up and acts as a strut.
  - The loaded rafter's sagging moment rises. Rafters that are hinged at the ring see larger bending and opposite-sign moments.
- So unbalanced snow is usually not critical for the hoop force (full snow governs). It is critical for:
  - (a) rafter bending,
  - (b) the ring's vertical shear capacity and rafter-to-ring connections in shear or uplift,
  - (c) ring sway/rotation and ring-corner joints that change sign (a heptagon with mitred butt corners has no tension capacity, so a corner can open),
  - (d) the plate and cable seeing non-uniform thrust, which makes the polygonal plate bend in plan.

**Mechanism warning.** A set of radial rafters pinned at both ends lets the ring rotate about the vertical axis (all rafters swing tangentially together) and sway sideways. Only the following resist this:
- the sheathing or boarding acting as a conical diaphragm/shell,
- blocking between rafters at the ring and the plate,
- diagonal battens or bracing in the roof plane,
- moment or shear capacity in the screwed rafter-ring and rafter-plate joints.

Check on site that a continuous, well-fixed board or OSB deck or diagonal bracing exists.

**Recommended load cases for the check:**
- full snow,
- snow on half the roof (μ1 on one side, 0.5·μ1 on the other, by analogy with EN 1991-1-3 duo-pitch case (ii)/(iii); this is an engineering analogy because conical roofs are not explicitly covered),
- snow on a single sector (drift),
- wind uplift (a reversal can put the ring in tension and the cable to zero if the roof is light),
- erection or temporary loads.

Ideally use a simple 3D frame model: 28 rafters, the ring as 7 beams with realistic corner springs, the plate as 14 beams, and the cable as a tension-only element with pre-tension.

### Gaps
- Could not open the PCI 1966 paper or the Eng-Tips threads in full; the formulas above are standard statics, not quoted from them.
- No published closed-form result found for the in-plane ring rotation/sway stiffness of a timber radial-rafter roof under unbalanced snow.
- The Lithuanian s_k and the national annex for snow were not checked in this session.

---

## 2. Compression ring design: bending of polygon sides with rafters bearing between corners, corner joints, typical ring sizes, rafter-ring connections

### Takeaway
With 4 rafters bearing on each 1.01 m heptagon side, the side is a beam-column. It carries ≈14 kN axial compression plus an in-plane bending moment of ≈1.75 kNm ULS if the corners act as pins. The section's bending depth in that direction is the radial width (8–10 cm), so the ring height matters a lot. Corner joints must carry the full compression by contact, plus shear and tension under unbalanced load. I found no published ring sizes from manufacturers for ~10 m roofs; yurt makers use laminated rings and add a second "secondary compression ring" of blocking for snow.

### Cited Findings
- Pacific Yurts use a laminated centre ring to which the rafters connect. Their snow & wind kit adds a secondary compression ring made of horizontal blocking between the rafter supports. A 2×6 rafter, ring and hardware upgrade raises snow capacity on 20, 24 and 30 ft yurts. A steel central column is offered for high-snow sites. Owners are told not to let snow build past 12 in (≈30 cm). — [Pacific Yurts durability](https://www.yurts.com/what-makes-a-yurt-durable-inside-the-build-of-a-pacific-yurt/); [Pacific Yurts snow/wind kit instructions](https://www.yurts.com/download/snow-wind-kit-installation-instructions)
- A natural-building builder's ring design is a steel ring with welded brackets for bolted rafters. The geometry has to be redone if pole size or count changes. The same blog calls a 20 ft (6 m) roundhouse with no centre pole "pushing the limit" and recommends drawing it to scale to check the rafters fit at the ring. — [naturalbuildingblog new compression ring design](https://naturalbuildingblog.com/new-compression-ring-design/)
- Radiating-rafter roofs without a centre post rely on a stout tension band around the wall to stop the walls kicking out, as in a yurt. — [naturalbuildingblog](https://naturalbuildingblog.com/?p=4091)
- Rob Roy / Earthwood: both of their buildings used a centre post with a broad capital receiving 16 radial rafters. For a 28 ft cordwood roundhouse with a living roof they considered a centre post effectively required. Earthwood (38'8" OD) had rafters of mostly 5×10 in. — [greenhomebuilding.com Rob Roy Q&A](https://www.greenhomebuilding.com/QandA/cordwood/structural.htm); [Mother Earth News Earthwood](http://www.motherearthnews.com/green-homes/cordwood-house-zmaz95amztak)
- Ring-compression roofs are self-supporting once locked; a temporary central support is used only during erection. — [OFF-GRID Daily Life roundhouse guide](https://offgriddailylife.com/the-roundhouse-project-guide/)
- In radial rafter roofs most of the weight lies on the outer half of the rafters. — [Permies reciprocal roof thread](https://permies.com/t/53564/roundwood-reciprocal-roof-structure-strong)
- TFEC technical bulletin (2026): when the radius of curvature to depth ratio of a curved member is below 5, the straight-beam flexure formula underestimates circumferential stress. This matters for curved or glulam rings, less so for straight polygon sides. — [TFEC bulletin](https://www.tfguild.org/timber-frame-engineering-council/technical-bulletins/view/567/download)
- Circular compression rings loaded by uniform radial reactions carry axial compression only. Any non-uniform force pattern, or a polygonal ring loaded between nodes, adds bending. — [USAL paper on non-circular compression rings](https://produccioncientifica.usal.es/documentos/63db1072ce41a8765aab5ab9?lang=de)

### Inferences (own statics; please re-verify)
**Heptagon geometry.**
- Side s = 1.01 m.
- Circumradius r = s/(2·sin(π/7)) = 1.164 m.
- Apothem a = r·cos(π/7) = 1.049 m.
- The ring is ≈2.1–2.3 m across, which is large.
- Each side subtends 51.4°. With 28 rafters at 12.86° spacing placed symmetrically, the rafters on one side sit at ±6.43° and ±19.29° from the side's mid-normal. Along the side that is x = a·tan φ = ±0.118 m and ±0.367 m from midspan, i.e. 0.138 m and 0.387 m from each corner.

**Side bending (corners treated as pins, normal components P·cos φ, P = H = 3.4 kN ULS).**
- End reaction = P·(0.994 + 0.944) = 1.94·P.
- M_mid = 1.94P·0.505 − 0.944P·0.367 − 0.994P·0.118 ≈ 0.515·P ≈ 1.75 kNm (ULS).
- If the corners are effectively rigid, for example with a laminated double-layer ring with overlapping corners, the midspan moment drops to roughly 1/2–2/3 of this, but the corners then carry hogging moment.

**Side axial force.** N ≈ 14 kN (see section 1).

**Section check with C24 (EN 338 values from memory: f_m,k = 24, f_c,0,k = 21, f_c,90,k = 2.5 MPa), k_mod = 0.8 (medium-term snow), γ_M = 1.3.**
- Design strengths: f_m,d ≈ 14.8 MPa and f_c,0,d ≈ 12.9 MPa.
- In-plane bending uses the radial width b as the depth: W = h_vert·b²/6.
  - b = 90 mm: bending alone needs h_vert ≥ ~90 mm. Including the axial interaction (σc/fc)² + σm/fm ≤ 1, roughly h_vert ≥ 100–120 mm.
  - b = 80 mm: roughly h_vert ≥ 130–150 mm.
- **The ring height is therefore the critical unknown. Measure it.** A built-up ring (two or three glued and screwed layers with staggered joints) or a steel flat or angle reinforcement on the inside face is the usual fix if it is too small.
- Out-of-plane and torsional effects come from the rafter thrust line acting eccentrically. A 50×200 rafter at ≈38.7° has a plumb cut ≈ 200/cos 38.7° ≈ 256 mm tall. If the ring is shallower, the thrust is eccentric and twists the ring.

**Rafter bearing on the ring.**
- The thrust acts perpendicular to the ring grain: σc,90 = H/(50·h_contact).
- f_c,90,d ≈ 2.5·0.8/1.3 ≈ 1.5 MPa (k_c,90 up to 1.5 may apply).
- With H = 3.4 kN the bearing needs ≥ ~2,200 mm², i.e. ≥ 45 mm of full-contact height on a 50 mm wide rafter (less with k_c,90).
- Gaps, rounded or poorly fitted cuts, or end bearing only on screws are a weak point. Look for crushing or indentation and screws bent or withdrawn.

**Ring corners.**
- Under balanced load the corners transmit ≈14 kN by contact. A mitred butt joint is acceptable only if the full face is in contact.
- Under unbalanced load or wind the corners need shear and some tension capacity: screwed steel plates, straps across each corner (top and bottom), or overlapping laminated layers.
- PU glue is not a reliable structural joint across gaps or end grain; do not count on it.

**Plate check.**
- 14 sides at R ≈ 4.9 m: side ≈ 2·4.9·sin(π/14) ≈ 2.18 m.
- Two rafters per side at ≈0.54 m either side of midspan.
- Vertical load per rafter ≈ q·πR²/28 ≈ 2.7·75.4/28 ≈ 7.3 kN ULS. That gives M ≈ 7.3·(1.09−0.54) ≈ 4 kNm and σ ≈ 3 MPa in a 200×200 (W = 1.33·10⁶ mm³). OK.
- In-plan bending of a plate side from the outward thrust (if the cable only bears at the corners): M ≈ 3.4·0.55 ≈ 1.9 kNm. OK.

**Rafter (quick check).**
- Tributary width ≈ 1.10 m at the plate and 0.26 m at the ring.
- With q = 2.7 kN/m²: M ≈ 3.2 kNm, σm ≈ 9.7 MPa in a 50×200 (W = 333,000 mm³), which is ≈0.65 of f_m,d. N ≈ 4.4 kN is small. OK for strength.
- SLS deflection ≈ L/250–L/300.
- Lateral restraint of the 50 mm wide rafter (h/b = 4) by sheathing or battens is required.

### Gaps
- No manufacturer data found (Pacific Yurts, Colorado Yurt, Rainier, Ben Law, Tony Wrench) giving actual ring dimensions or rafter-to-ring hardware for ~10 m spans. The pages could not be opened.
- No source found on typical timber ring heights for 28-rafter roofs.

---

## 3. Tension ring: wire rope sizes, breaking loads, safety factors, clips, turnbuckles, pre-tension, stretch, corrosion; is a cable sufficient?

### Takeaway
For T_Ed ≈ 15 kN a 6 mm rope (MBL ≈ 21–23 kN) is not adequate once the 80 % termination efficiency and a material factor are applied. An 8 mm 6×19 IWRC 1770 rope (MBL ≈ 40 kN) is marginal: acceptable on a Eurocode-type check but far below rigging practice (SF ≈ 5). 10 mm (MBL ≈ 58–70 kN) is comfortable. Also important is stiffness: an 8 mm rope stretches ≈0.3–0.46 % elastically at 10–15 kN (≈10–14 cm on a 30.8 m circumference). That lets the plate spread ≈1.5–2.3 cm in radius plus any constructional stretch and clip slip, unless the rope is pre-tensioned with a turnbuckle and re-tensioned.

### Cited Findings
**Breaking loads, EN 12385 6×19 IWRC (Katradis):**

| Diameter | MBL, 1770 grade | MBL, 1960 grade |
|---|---|---|
| 6 mm | 22.7 kN | 25.1 kN |
| 8 mm | 40.3 kN | 44.7 kN |
| 10 mm | 63.0 kN | 69.8 kN |

— [Katradis 6x19 IWRC](https://www.katradis.com/our-products/wire-ropes/standard-wire-ropes/6x19-steel-core-iwrc/)

- **Lower-strength variants.** 6×19 fibre core (1770): 6 mm 21.0, 8 mm 37.4, 10 mm 58.4 kN. DIN 3060 (1+6+12) steel core: 6 mm 21.2, 8 mm 37.6 kN. Do not mix up standards and constructions; check the actual rope's certificate. — [Katradis 6x19 fibre core](https://www.katradis.com/our-products/wire-ropes/standard-wire-ropes/6x19-fiber-core/); [Katradis 6x19 standard steel core](https://www.katradis.com/our-products/wire-ropes/standard-wire-ropes/6x19-standard-steel-core/)
- **Imperial reference.** 1/4" (6.4 mm) 6×19 IPS fibre core ≈ 24.4 kN. — [Engineering ToolBox wire rope strength](https://www.engineeringtoolbox.com/wire-rope-strength-d_1518.html)
- **EN 1993-1-11 (tension components).** Covers resistance, serviceability and durability of steel tension elements; detailed termination design is excluded. Being revised (new edition; the 2008 edition is replaced from 2028-03-31). The Cyprus National Annex limits the characteristic wire tensile strength used for durability to 1770 N/mm² (round wires). — [Cyprus NA EN 1993-1-11](https://moi.gov.cy/MOI/moiup/moi.nsf/All/05FE06BB537676ACC22585A100430DF8/$file/Cyprus_National_Annex_EN_1993-1-11.pdf); [ČSN EN 1993-1-11 ed.2 notice](https://www.tzb-info.cz/normy/csn-en-1993-1-11-ed-2-2026-10); [LSD prEN 1993-1-11](https://projektai.lsd.lt/en/drafts/eurocode-3-design-of-steel-structures-part-1-11-tension-components)
- **EN 13411-5 U-bolt grips.** A grip-secured eye termination must hold at least 80 % of the rope's minimum breaking force for 5 minutes with ≤ 1 mm slip.
  - 8 mm rope: minimum 4 grips, 6.0 Nm.
  - 10 mm rope: minimum 4 grips, 9.0 Nm. An ERCA safety warning corrects an erroneously printed 9.9 Nm to 9 Nm.
  - Torques assume greased threads and bearing surfaces.
  - Grip spacing should be at least 1.5 × rope diameter (per ERCA; check the current edition).
  — [Unique Group wire rope clips catalogue](https://www.uniquegroup.com/wp-content/uploads/2023/04/DO_EN_CATEN_Catalogue_3.20Wire20rope20clips.pdf); [ERCA Safety Warning 1/2011](https://www.erca.uk/news/Update_ERCA_Safety_Warning_1_2011_WireRopeTerminations.pdf?PHPSESSID=df0d0d60dd42fe233ca0afe651bd73c1); [BS EN 13411-5](https://growsafehse.com/wp-content/uploads/2024/05/BS-EN-13411-5-2003Termination-For-Steel-Wire-Ropes-Safety-U-Bolt-Wire-Rope-Grips-min.pdf); [Rossendale grips safety info](https://rossendalegroup.co.uk/wp-content/uploads/2023/02/Wire-Rope-Grips_-Safety_Information.pdf)
- **Crosby / Certex practice (US clips).**
  - Placement: first clip one base width from the dead end, U-bolt on the dead (tail) end, saddle on the live end: "Never saddle a dead horse!" The live end sits in the saddle so the U-bolt does not crush it.
  - Minimum clips:
    - 1/4": 2 clips, 4¾" turnback, 15 ft-lb
    - 1/2": 3 clips, 11½" turnback, 65 ft-lb
    - 3/4": 4 clips, 18" turnback, 130 ft-lb
  - Add one clip if the rope turns back over a thimble or pulley.
  - Tighten nuts evenly and alternately to torque. Re-tighten after the first load and again after a period in service.
  - U-bolt clips are not recommended for elevator, personnel-hoist or scaffold use (ANSI A17.1 / A10.4).
  — [Crosby wire rope clips PDF](https://www.thecrosbygroup.com/wp-content/uploads/catalog/2022/en-US/398.pdf); [Certex U-bolt clip instructions](https://www.certex.com/wire-rope-terminations/u-bolt-clips-warnings-application-instructions/); [IHSA wire rope clips safety talk](https://www.ihsa.ca/pdfs/safety_talks/wire_rope_cable_clips.pdf)
- **Torque discrepancy.** The EN 13411-5 torques (6–9 Nm, greased) are much lower than the Crosby torques (15 ft-lb ≈ 20 Nm for 1/4", dry threads). Follow the instructions of the specific grip's manufacturer. — [Unique Group](https://www.uniquegroup.com/wp-content/uploads/2023/04/DO_EN_CATEN_Catalogue_3.20Wire20rope20clips.pdf); [Crosby](https://www.thecrosbygroup.com/wp-content/uploads/catalog/2022/en-US/398.pdf); [Ackland/Grainger clip instructions](https://punchout.acklandsgrainger.com/ec/pdf/1DKK8_1.pdf)
- **Elastic stretch (Loos).** Elastic stretch % of length ≈ W·G/D² (W in lb, D in inches), with G = 0.0000136 for 6×19 galvanized IWRC and 0.0000140 for 7×19 galvanized. This covers elastic stretch only, not constructional stretch. — [Loos wire rope stretch](https://blog.loosco.com/loos-blog/how-do-i-figure-out-cable-and-wire-rope-stretch)
- **Apparent modulus.** The apparent E of a rope depends on its construction, so use the manufacturer's E and the area it was tabulated for. — [Eng-Tips wire rope area](https://www.eng-tips.com/threads/wire-rope-area.498385/post-8835051)
- **Yurt practice.** Equal cable tension around the yurt is essential; uneven tension can pull rafters off the ring. — [Pacific Yurts](https://www.yurts.com/what-makes-a-yurt-durable-inside-the-build-of-a-pacific-yurt/)
- **Turnbuckle WLLs (retail).** A 5/16" jaw-jaw turnbuckle is rated at 1,200 lb (≈5.3 kN) WLL. Small turnbuckles are often the weakest link. — [Amazon turnbuckle listing](https://www.amazon.com/Turnbuckles-Stainless-Steel-Aircraft-Cable/dp/B0DRGQR23L)

### Inferences (own; please re-verify)
**Required rope MBL for T_Ed = 15 kN (ULS) or T_k ≈ 10–11 kN (characteristic):**
- *Eurocode-type check.* EN 1993-1-11 (from memory, not verified here) gives F_Rd ≈ F_uk/(1.5·γ_R), with γ_R ≈ 0.9–1.0 depending on the termination. Divide by 0.8 for clip efficiency. MBL ≥ 15·1.5/0.8 ≈ 28 kN, or about 31 kN with γ_R = 1.0 and margin.
  - 6 mm (22.7 kN): fails.
  - 8 mm IWRC 1770 (40.3 kN): passes with utilisation ≈ 0.7–0.8.
  - 10 mm (63 kN): utilisation ≈ 0.45.
- *Rigging-practice check (WLL = MBL/5 on characteristic load).* MBL ≥ 5·10.5 ≈ 50–55 kN, so 10 mm is needed. A structural tension ring is not lifting gear, so SF 5 is conservative. Factors of 2.5–3 on characteristic load (after termination efficiency) are the kind of target an engineer would usually accept for a static structural stay; this is an engineering judgement, not a sourced rule.
- Check whether the rope actually installed is 6×19 IWRC or a weaker hardware-store 6×7 / 7×7 / fibre-core rope, and which wire grade it uses. Ask for the certificate or measure it.

**Stiffness (Loos formula).**
- At 15 kN = 3,372 lb:
  - 8 mm (D = 0.315 in): 0.46 %
  - 10 mm: 0.30 %
  - 6 mm: 0.82 %
- At a realistic SLS of ≈8–10 kN: 8 mm ≈ 0.25–0.31 %.
- On a 30.8 m circumference that is 8–14 cm of elongation, i.e. radial spread of ≈1.2–2.3 cm.
- The ring drops by about spread × run/rise ≈ 1.25× the spread.
- Add constructional stretch on first loading (typically a few tenths of a percent for non-prestretched rope; not sourced here) and grip bedding-in.
- **Pre-tension the rope** with a properly rated turnbuckle (rated ≥ the rope's design force; a typical 5/16" turnbuckle with 5 kN WLL is too weak if it is meant to carry the full load) and re-tension after the first winter.

**Load sharing with the timber plate.** Mitred butt joints that are screwed and PU-glued have little tension strength or stiffness. The cable is therefore the real tension ring, and it must be designed for the full hoop force T. The timber plate acts as a compression or bending member between the cable contact points. Any slack in the cable means the posts are bending outward to carry the thrust until the cable takes up.

**Cable over polygon corners.**
- The rope deflects 25.7° at each of the 14 plate corners. The radial force at each corner = 2T·sin(π/14) ≈ 0.445·T ≈ 6.7 kN ULS, concentrated on a thin wire.
- This can crush the timber corner, which loses tension, and kink the rope.
- Use steel saddles or angles, or round the corners. Keep the rope at the height of the rafter thrust line on the plate (the birdsmouth level) to avoid twisting the plate.

**Joining the rope ends.** A loop closed with a lap splice has two live ends; single-saddle U-bolts cannot be oriented "correctly" for both. Prefer thimble eyes at each end joined through a turnbuckle or shackle, with each eye made to EN 13411-5 (≥4 grips for 8–10 mm, right orientation, torque). Double-saddle (fist-grip) clips are the usual choice for lap splices (manufacturer practice; not confirmed in this session).

**Corrosion.** Use galvanized or stainless rope and fittings. Check for rust where the rope touches wet timber, at the plate corners, and inside the grips. Timber shrinkage and seasonal moisture change the plate dimensions and so the cable tension: check tension at least once a year.

### Gaps
- Exact EN 1993-1-11 resistance formula and γ_R value not confirmed (pages not fetched).
- No yurt manufacturer document found giving the cable diameter used on ~10 m (32 ft) yurts.
- No sourced value for constructional stretch of 6×19 galvanized rope.
- No source on creep of steel rope at these stress levels (generally small; timber creep at the cable contact points and joints matters more).

---

## 4. Typical failure modes / mistakes and what to check on site

### Takeaway
The dominant failure modes are:
- the plate spreading because the tension band is slack, slips or is too weak,
- walls or posts pushed out,
- ring-side bending, crushing or corner opening,
- rafter-to-ring connections pulling off under uneven loading,
- local crushing or splitting at the birdsmouth on the plate and at the cable bearing points.

Most of these show up first as measurable changes in geometry, so a measured survey is the key check.

### Cited Findings
- Roof weight spreads the rafters outward, lowers the apex and pushes the wall stakes out until collapse unless there is a ring beam or tension band. — [Gefrin roundhouse construction](https://gefrin.com/roundhouses-construction/)
- Radiating-rafter roofs need a stout tension band around the walls to prevent kick-out. Removing interior supports without one is unsafe. — [naturalbuildingblog](https://naturalbuildingblog.com/?p=4091); [naturalbuildingblog reciprocal roofs](https://naturalbuildingblog.com/reciprocal-roofs/)
- Uneven cable tension can pull rafters off the centre ring and weaken the structure under snow or wind. Do not let snow build past ~30 cm. — [Pacific Yurts set manual](https://www.yurts.com/download/pacific-yurts-set-manual-12-14-16-yurts/); [Pacific Yurts snow/wind kit](https://www.yurts.com/download/snow-wind-kit-installation-instructions)
- Observed buckling in a 100-year-old conical timber roof could only be explained by ring action. Sheathing contributes to resisting thrust. — [Eng-Tips 100-yr conical roof](https://www.eng-tips.com/threads/100-year-old-large-conical-wood-framed-roof-compression-ring.435528/)
- Asymmetric snow can raise stresses by ~23 % and deflections by ~50 % compared with balanced snow on conical roofs. — [ResearchGate silo roof](https://www.researchgate.net/publication/321188472_Effects_of_different_snow_load_arrangements_on_steel_silo_roof_structures)
- A compression ring can buckle unless its unsupported length is shortened. — [CR4](https://cr4.globalspec.com/thread/81623/Conical-Tank-Roofs)
- Wire-rope grips must be re-tightened after first loading and periodically; wrong orientation reduces termination capacity. — [IHSA](https://www.ihsa.ca/pdfs/safety_talks/wire_rope_cable_clips.pdf); [Crosby](https://www.thecrosbygroup.com/wp-content/uploads/catalog/2022/en-US/398.pdf)
- Rob Roy considered a centre post effectively required for a 28 ft (8.5 m) living-roof roundhouse; no-column ring roofs of this size are at the upper end of DIY practice. — [greenhomebuilding.com](https://www.greenhomebuilding.com/QandA/cordwood/structural.htm); [naturalbuildingblog](https://naturalbuildingblog.com/new-compression-ring-design/)

### Inferences: site checklist (own)
1. **Geometry survey (most important).**
   - Measure the plate diameter across at least 7 diameters (corner to opposite corner) and compare with the design value or with each other. A difference of more than ~1–2 cm suggests spreading or ovalisation.
   - Plumb each of the 14 posts. Outward lean at the top is the classic sign of thrust.
   - Measure the ring height above the floor at several points, or the rafter sag. A dropped or tilted ring suggests spreading or unbalanced settlement.
   - Repeat after a snow event or seasonally.
2. **Wall plate joints.** Check the mitred butt joints for gaps opening on the outside face, cracked glue lines, bent or withdrawn screws, and deformed angle brackets. Check that the post-top housing (2 cm) is not splitting.
3. **Cable.**
   - Is it tight everywhere, with no slack sections?
   - Does it sit at rafter-thrust height?
   - Does it bear on sharp corners (crushing or indentation)?
   - Grips: number (≥4 for 8–10 mm), orientation (saddle on live end), torque, slip marks (paint a witness mark).
   - Turnbuckle size and rating.
   - Rope diameter and construction, corrosion, broken wires.
4. **Compression ring.**
   - Measure the ring section (radial width × height) and timber grade.
   - Check side straightness (inward bowing of sides between corners is a sign of bending overload).
   - Check corner joints for opening or rotation.
   - Look for crushing at the rafter bearings and for splits.
   - Check rafter-to-ring screws or brackets (withdrawal, shear).
   - Check the ring is level.
5. **Rafters.** Look for splits at the birdsmouth and notches, excessive notch depth at the plate, lateral buckling or twist, mid-span sag, and moisture damage at the eaves.
6. **Roof deck / diaphragm.** Check for continuous boarding or OSB nailed to every rafter, or diagonal bracing, and blocking at the ring and plate. Without these the ring can rotate or sway under unbalanced snow.
7. **Load control.** Snow-clearing policy (especially avoid drifts on one side), no added heavy finishes (green roof, extra insulation layers) beyond what was designed for.
8. **Remedies if marginal.**
   - Upgrade to 10 mm IWRC rope, or add a second rope, with thimbles plus a rated turnbuckle, steel corner saddles, and pre-tension.
   - Reinforce the ring with a second laminated layer or a steel plate/angle ring, add corner straps, add blocking between rafters at the ring.
   - Add a temporary centre prop during heavy snow until verified.

### Gaps
- No documented case histories or statistics of roundhouse/yurt roof failures were found.
- Recommended inspection intervals and tolerances for ring roofs come from no code found; the values above are engineering judgement.
