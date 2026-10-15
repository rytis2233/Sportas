# Timber rafter capacity (EN 1995-1-1) for 50×200 radial rafters + bitumen shingles on a steep conical roof (Lithuania)

> Method note (read first): in this session WebFetch and curl were blocked for nearly every host (DNS failure / proxy 403). That included katepal, vedrana.lt, e-seimas.lrs.lt, rothoblaas.com, strongtie and blueprints.readthedocs. So **every citation below comes from search-engine result snippets, not from reading the full document**. Values marked "(snippet)" should be checked against the linked PDF before anyone relies on them. Values marked "general knowledge, not verified this session" come from standard EN 1995-1-1 / EN 338 content I know but could not confirm through a source this session.

## 1. EN 338 / EN 1995-1-1 design parameters (C16/C18/C24, kmod, γM, kh, kc, kdef) and check of the hand calculation

### Takeaway
The hand calculation's numbers can be reproduced exactly with kmod = 0.8 (snow = medium-term), γM = 1.3, kh = 1.0 (h = 200 mm > 150 mm), in-plane buckling over Lef ≈ 4.8 m and the EN 1995-1-1 §6.3.2 bending + compression interaction: about 53 % bending + 8 % axial ≈ 61 % for C24, and about 70 % + 10 % ≈ 80–81 % for C18. The ULS result is plausible and conservative if kmod 0.9 (short-term) would be allowed. The weaker points are (a) the strength class of the timber actually installed, (b) final deflection including creep, especially if the timber was installed wet, and (c) the details: OSB span at 1.08 m spacing, and the eaves thrust / tension ring.

### Cited Findings
- EN 338:2016 bending strength fm,k: C16 = 16, C18 = 18, C24 = 24 N/mm². E0,mean: C16 = 8.0, C18 = 9.0, C24 = 11.0 kN/mm² (Italian reproduction of UNI EN 338:2016, snippet) — [Studio Madera](https://www.studiomadera.it/news/660-legno-conifera)
- In EN 338 only fm,k, E0,mean and density are determined by testing. The other properties (fc,0,k, E0,05 etc.) are derived from the table — [Studio Madera / EN 338 note](https://www.studiomadera.it/news/660-legno-conifera)
- EN 338:2016 has separate tables for bending-based (C) and tension-based (T) classes, so be careful which table is quoted — [Blueprints EN 338 table 1](https://blueprints.readthedocs.io/en/stable/API%20reference/codes/eurocode/en_338_2016/chapter_5_classification_of_structural_timber/table_1/); [Napier CWST "C and T classes"](https://blogs.napier.ac.uk/cwst/c-and-t-classes/)
- kmod for solid timber, service classes 1 and 2: medium-term 0.80, short-term 0.90. Service class 3 is lower (UNE-EN 1995-1-1 table reproduced in a datasheet, snippet) — [Indexfix datasheet](https://www.indexfix.com/wp-content/uploads/CMP6735/files/FT_POS_en_rev2.pdf)
- γM = 1.3 for solid timber in fundamental combinations (Croatian NA table, snippet) — [JRC Eurocodes Balkan workshop, Rajčić EN 1995](https://eurocodes.jrc.ec.europa.eu/sites/default/files/2022-06/13_Eurocodes_Balkan_WS_SK_Rajcic_EN_1995.pdf)
- Service class 1 means about 20 °C and RH rarely above 65 %, so softwood MC ≤ 12 % — [Swedish Wood / Univ. of Galway, Design of timber structures Vol. 2](https://www.universityofgalway.ie/media/timberengineeringresearchgroup/Design-of-timber-structures_Volume2_Rules-and-formulas-according-to-Eurocode-5.pdf)
- **Snow load duration in Lithuania:** a KTU (Panevėžys) student design paper applying LST EN 1995-1-1 puts snow in the **medium-term** class (1 week to 6 months). The older Lithuanian regulation STR 2.05.07:2005 "Medinių konstrukcijų projektavimas" also lists snow as medium-term, with kmod = 0.80 for solid/glulam timber in service class 1 (snippets) — [KTU paper (elaba)](https://talpykla.elaba.lt/elaba-fedora/objects/elaba:152358924/datastreams/MAIN/content); [STR 2.05.07:2005 PDF](https://www.asauna.lt/wp-content/uploads/2019/05/str-205072005-mediniu-konstrukciju-projektavimas-1.pdf); [STR 2.05.07:2005 on e-seimas](https://e-seimas.lrs.lt/rs/legalact/TAD/TAIS.250623/)
- The Galway/Swedish Wood handbook's general table lists snow as short-term, and notes that national annexes may assign climatic loads to different duration classes — [Galway Vol. 2](https://www.universityofgalway.ie/media/timberengineeringresearchgroup/Design-of-timber-structures_Volume2_Rules-and-formulas-according-to-Eurocode-5.pdf); [Swedish Wood Vol. 2 (2022)](https://www.swedishwood.com/siteassets/5-publikationer/pdfer/sw-design-of-timber-structures-vol2-2022.pdf). **Conflict:** the Lithuanian sources above use medium-term. For a Lithuanian check, kmod = 0.8 is the safer and locally consistent choice.
- Lithuanian ground snow load sk: about 1.2 kN/m² in region I (e.g. Kaunas, Klaipėda) and 1.6 kN/m² in region II (e.g. Vilnius) (informational article, snippet) — [Profa.lt "Paprastai ir aiškiai apie sniego apkrovą"](https://www.profa.lt/paprastai-ir-aiskiai-apie-sniego-apkrova); the formal source is LST EN 1991-1-3 + NA / STR 2.05.04 ([STR 2.05.04:2003](https://www.esavadai.lt/dokumentai/1291/))
- EN 1991-1-3 is the basis for roof shape coefficients μ — [EN 1991-1-3 text](https://www.phd.eng.br/wp-content/uploads/2015/12/en.1991.1.3.2003.pdf)

### Inferences
- **Reproducing the hand calc** (my arithmetic, using the values above plus EN 338 fc,0,k / E0,05 from general knowledge: C24 fc,0,k = 21 MPa, E0,05 = 7.4 GPa; C18 fc,0,k = 18 MPa, E0,05 = 6.0 GPa; C16 fc,0,k = 17 MPa, E0,05 = 5.4 GPa, E0,mean = 8.0 GPa. The fc and E0,05 values are not verified this session; search could not confirm them):
  - 50×200: A = 10 000 mm², W = 333 333 mm³, I = 33.3·10⁶ mm⁴, i = 57.7 mm.
  - σm = 2.6e6 / 333 333 = 7.8 MPa. fm,d (C24) = 0.8·1.0·24/1.3 = 14.8 MPa, giving 53 %. fm,d (C18) = 11.1 MPa, giving 70 %.
  - Axial 4.4 kN gives σc = 0.44 MPa. In-plane buckling: λ = 4800/57.7 = 83. λrel = 1.41 (C24) / 1.45 (C18). kc ≈ 0.42 (C24) / 0.40 (C18), with βc = 0.2. Axial term = 0.08 (C24) / 0.10 (C18).
  - Sum: **0.61 (C24), 0.80 (C18)**. This matches the 61 % / 81 % in the hand calc. So the hand calc used kmod 0.8, γM 1.3, kh 1.0 and the §6.3.2 interaction σc/(kc·fc,d) + σm/fm,d.
  - With kmod 0.9 (short-term, as some NAs allow) the utilisation would fall to about 54 % / 71 %. 0.8 is the safe, Lithuania-consistent choice.
  - **C16** (not in the hand calc): about 7.8/(0.8·16/1.3) = 79 % bending + about 11 % axial ≈ **90 %**. Still below 100 %, but with little margin.
  - Out-of-plane buckling and lateral-torsional buckling are prevented only if the OSB is nailed continuously to the rafter top edge. That is a valid assumption for a sheathed roof.
- **Load check:** dead load 0.45 kN/m² is per sloped area, about 0.57 kN/m² on plan at 37.5°. ULS on plan = 1.35·0.57 + 1.5·1.2 ≈ 2.57 kN/m². With a mean tributary width of about 0.66 m ((1.08+0.24)/2) over a 3.7 m plan span, wL²/8 ≈ 2.9 kNm. With the actual trapezoidal load (wider at the eaves) M_Ed ≈ 2.6 kNm is plausible.
  - The **governing loaded width is near the eaves (1.08 m)**. If the hand calc averaged the width uniformly, the moment near mid-span is slightly underestimated. Check whether the overhang (0.6 m cantilever, which relieves the span moment) was counted.
- **Snow 1.2 kN/m² on plan is conservative** for a 35–40° pitch if sk = 1.2–1.6: μ1 = 0.8·(60−α)/30 gives 0.67 at 35° and 0.53 at 40°, so s = 0.64–1.07 kN/m². The extra margin also covers drift and accumulation around the cupola and asymmetric (one-sided) snow on a cone. EN 1991-1-3 has no explicit cone case.
- **kh:** h = 200 mm > 150 mm, so kh = 1.0 (EN 1995-1-1 §3.2). Correct as used.
- **Deflection** (my arithmetic, E0,mean C24 = 11 000 MPa, SLS characteristic load 0.57+1.2 = 1.77 kN/m² plan × 0.66 m, perpendicular component ×cos²37.5° ≈ 0.63, sloped span about 4.66 m):
  - winst ≈ 12 mm. This matches the hand calc (about L/390–L/410).
  - For C18 (E = 9000): about 15 mm.
  - wfin adds creep, kdef·(G + ψ2·S). ψ2 for snow = 0 in most NAs (not verified for Lithuania). The dead part is about 4 mm, so with kdef = 0.6 (SC1) / 0.8 (SC2, ventilated cold roof) wfin ≈ 15–16 mm (C24), about L/300.
  - If the timber was **installed green** (near fibre saturation), EN 1995-1-1 §3.2/2.3.2.2 (general knowledge, not verified this session) says to add 1.0 to kdef, giving kdef ≈ 1.8. Then wfin ≈ 19–20 mm for C24 (about L/240) or about 24 mm for C18 (about L/195).
- **EN 1995-1-1 Table 7.2 recommended ranges** (general knowledge, not verified this session): winst L/300–L/500, wnet,fin L/250–L/350, wfin L/150–L/300. In Baltic and Nordic practice, roof rafters are commonly checked at **L/200 (final) to L/300 (instantaneous)**. A hand-calc limit of L/250–L/300 is a reasonable choice, and 12 mm passes all of them.

### Gaps
- I could not read the current **LST EN 1995-1-1:2005/NA** text. Its duration-class assignment for snow, its Table 7.2 deflection limits, and any ψ2 for snow are confirmed only through secondary Lithuanian sources (KTU paper, superseded STR 2.05.07:2005).
- EN 338:2016 fc,0,k and E0,05 for C16/C18/C24 could not be confirmed through a fetched source (search snippets only confirm fm,k and E0,mean).
- The kdef "+1.0 for green timber" rule and Table 7.2 ranges are from general knowledge and not verified this session.

## 2. Timber grades sold in Lithuania; implications of ungraded or green timber

### Takeaway
In Lithuania you can buy kiln-dried (about 16–20 % MC), calibrated (kalibruota), strength-graded (graduota) C24, and some C18. But much roof timber is still sold as ungraded "statybinė mediena", often fresh-sawn or air-dried. Without a CE mark or grading stamp you cannot claim C24. A cautious engineer would assume C16–C18, which the hand calc shows is still about 80–90 % utilised. Green timber mainly affects creep and deflection (kdef), shrinkage (about 200 → 195 mm depth, plus twist and loosening of fasteners) and the risk of fungal decay if it cannot dry.

### Cited Findings
- Lithuanian suppliers sell calibrated C24 (e.g. 45×195×6000 mm, recommended for rafters and floor joists) and C18 (e.g. 45×245) — [Lentvario mediena article on kalibruota mediena](https://www.lentvariomediena.lt/straipsniai/kalibruota-mediena-lietuvoje); [Vedrana graduota mediena](https://www.vedrana.lt/graduota_mediena/); [Medžio turas C24](https://www.medzioturas.lt/kalibruota-c24-mediena)
- Typical declared moisture of dried construction timber in LT offers is about 16–20 % — [Medžio bitės](https://www.medziobites.lt/konstrukcine-statybine-mediena?sort=p.width&order=ASC&page=8); [Vigidas pack](https://www.vigidaspack.lt/statybine-mediena)
- One supplier states that calibration accuracy holds best in dried timber. In other words, undried timber shrinks and distorts after planing — [Lentvario mediena](https://www.lentvariomediena.lt/straipsniai/kalibruota-mediena-lietuvoje)
- Price indications: about €28.67/pc for C24 45×195×6000, and €8.43–33.21/pc across sizes at another seller (prices not current-verified) — [Lentvario mediena](https://www.lentvariomediena.lt/straipsniai/kalibruota-mediena-lietuvoje); [Medžio turas](https://www.medzioturas.lt/kalibruota-c24-mediena)
- Classified ads also offer "C24 kalibruota, vakuuminis impregnavimas" timber — [Skelbiu.lt C24](https://www.skelbiu.lt/paieska/c24-mediena/)
- Strength classes are assigned under EN 14081-1 (grading, with a CE mark) — [Studio Madera / EN 338](https://www.studiomadera.it/news/660-legno-conifera)

### Inferences
- **50×200 is not a standard calibrated C24 size** in the LT offers found (those are 45×195, 45×245, etc.). A nominal 50×200 is likely sawn ("pjautinė") timber from a sawmill: probably ungraded and possibly fresh. Check for any stamp, delivery note or CE declaration. If there is none, assume ungraded and verify with C16/C18 values (utilisation about 80–90 %, see section 1). A visual-grading check against EN 14081 / INSTA 142 by a specialist could justify C18/C24.
- **Actual dimensions:** green 50×200 dried to about 15–18 % MC shrinks roughly 2–3 % across the width, to about 48×195. W scales with b·h², about 0.91×, so utilisation rises about 9 % (C18 → about 88 %). Measure the real cross-section.
- **Green timber:** higher kdef (about +1.0) brings final deflection to about L/200–L/250. Drying shrinkage can loosen nails and angle-bracket connections. Twist and cupping can show through the OSB and shingles. Green timber shut into a closed, insulated, unventilated roof risks mould and decay, so ventilation matters.
- Rafter MC at installation above about 20 % should be documented. Measure with a pin moisture meter now.

### Gaps
- No statistics found on what share of Lithuanian roof timber is graded vs ungraded.
- No Lithuanian source found on grading rules for small sawmills.

## 3. Span-table sanity check for 50×200 at about 1.0 m spacing

### Takeaway
UK tables (BS 5268 / EC5 UK NA) give about 3.7 m for 47×200 C24 at 600 mm centres with concrete tiles and 0.75 kN/m² imposed load, and about 4.1–4.2 m at 400 mm centres. Spans scale roughly with 1/√(spacing). At the 1.08 m eaves spacing of this roof, a table would give about 2.7–2.9 m, but at the mean spacing of about 0.66 m it gives about 3.5 m. That supports a "works, but not with a large margin" result for a 3.7 m plan span, given that the loaded width tapers to 0.24 m.

### Cited Findings
- 47×200 C24 at 600 mm centres: 3.72 m (concrete tiles, 0.75 kN/m² imposed). At 400 mm: 4.10 m (UK calculator, EC5 + UK NA basis) — [TradeCalculator rafter span tables](https://tradecalculator.co.uk/reference/rafter-span-tables/)
- Another guide: 47×200 C24 at 400 mm centres spans "approximately 4.20 m — verify against TRADA" — [BuildEstimatory UK](https://uk.buildestimatory.com/guides/rafter-span-table/)
- UK imposed-load bases: 0.75 kN/m² for altitude ≤ 100 m, 1.0 kN/m² for about 100–200 m — [Timber Beam Calculator (BS 5268-7.5)](https://www.timberbeamcalculator.co.uk/en-gb/span-tables/rafters); [TradeCalculator](https://tradecalculator.co.uk/reference/rafter-span-tables/)
- Taylor Maxwell publishes C24 span tables (TRADA-based) — [Taylor Maxwell C24 span tables PDF](https://www.taylormaxwell.co.uk/uploads/files/D.100.02-01_C24-Span-Tables_Design_Span-Tables.pdf)
- US span tables (WWPA, #2 SPF) are in a different system (allowable stress, ft-in) — [WWPA span tables](https://www.admoyer.com/builders/spantables.pdf); [CKCOG rafter table](https://www.ckcog.com/wp-content/uploads/Rafter-Span-Table.pdf)

### Inferences
- Scale the UK table: 3.72 m × √(0.6/1.08) ≈ 2.77 m at 1.08 m spacing; × √(0.6/0.66) ≈ 3.55 m at the 0.66 m average.
  - UK tables use a lower imposed load (0.75 vs 1.2 kN/m² on plan here) but heavier concrete tiles (about 0.5–0.6 kN/m² vs 0.45 here). Net loads are similar to somewhat lower than this roof.
  - So a 50×200 rafter (6 % wider and slightly deeper than 47×200) over 3.7 m plan with radial taper is close to the table limit. That is consistent with the 61 % (C24) to 81 % (C18) ULS utilisation, since UK tables are often governed by deflection and include margins.
- The radial taper is the key difference from parallel-rafter tables. Peak moment occurs closer to the eaves, where the loaded width is largest. A table check at 1.08 m spacing alone would wrongly fail the rafter, and a check at the average width alone is slightly unconservative.
- No Nordic (Swedish/Finnish) or TRADA table for 50×200 at 1.0–1.2 m spacing was retrievable this session.

### Gaps
- TRADA, Swedish (Svenskt Trä) and Finnish span tables could not be fetched. No direct table at about 1.0 m spacing and 1.2 kN/m² snow was found.

## 4. Bitumen shingles on a steep conical roof: pitch limits, steep-slope fixing, cone use, underlay, OSB thickness, ventilation, cupola flashing

### Takeaway
Bitumen shingles (Katepal, Tegola, Shinglas/TechnoNICOL, IKO) are suited to 35–40° and to cones. Manufacturers allow 12° up to 90°, and Shinglas's manual has a section on cone-shaped slopes. At 35–40° standard fixing applies (4 nails per shingle). Extra nails (about 6) plus bitumen mastic are required only above about 45–60°. For a cone, the critical items are:
- the deck (OSB 18 mm on rafters at 1.08 m is below the commonly quoted 21 mm for about 1.2 m spacing);
- a full underlay;
- cutting and trimming the shingles to a fan or taper with joints staggered and glued;
- ventilation (≥ 50 mm air gap).

### Cited Findings
- Katepal: minimum slope 1:5 (about 12°) — [Katepal fitting instructions](https://www.roofgiant.com/resources/files/katepal-fitting-instructions.pdf); [Katepal Katrilli](https://katepal.net/product/katepal-katrilli/)
- Katepal hexagonal shingles are listed for pitches of 12°–90°. Warranty is 15 years without the Katepal underlay and 25 years with it (retailer listing) — [Roofing Superstore, Katepal Super KL](https://www.roofingsuperstore.co.uk/product/katepal-super-kl-hexagonal-bitumen-roofing-shingles-3m2-green.html)
- Katepal Katrilli: needs an underlay membrane, fixing with roofing nails or flat-headed screws, and a minimum installation temperature of +5 °C — [Katepal Katrilli](https://katepal.net/product/katepal-katrilli/)
- SuperKatepal: 4 roofing nails per shingle, about 30 mm above the bottom of each notch (50 mm for "Foxy"). The self-adhesive strip does not replace the nails — [Katepal UK installation PDF](https://www.katepaluk.co.uk/wp-content/uploads/2024/01/inst_roof_shingles_1464792078.pdf); [Katepal UK FAQ](https://www.katepaluk.co.uk/faq)
- Katepal: nails must penetrate the decking. Short nails gradually work loose from the sarking. The underlay table has a separate row for steep roofs (pitch > 1:3); headings were not readable in the snippet — [Katepal UK FAQ](https://www.katepaluk.co.uk/faq); [Katepal installation guide 2025](https://katepal.net/wp-content/uploads/2025/02/Katepal_roofing_shingles_installation_guide.pdf)
- Katepal: valleys and verges are cut and glued with sealing compound K-36, with nails at 10 cm along valley sheet edges. "The steeper the roof, the better the appearance" — [Katepal guide 2025](https://katepal.net/wp-content/uploads/2025/02/Katepal_roofing_shingles_installation_guide.pdf); [Katepal Ambient guide](https://www.katepaluk.co.uk/wp-content/uploads/2024/01/Ambient_Installation_Guide_1569404674.pdf)
- Katepal SBS shingles: always ensure roof-space ventilation (exhaust vents at gables or ridge ventilators) — [Katepal SBS 3-tab instructions](https://www.katepaluk.co.uk/wp-content/uploads/2024/01/as_3T_ENG_net_1464792274.pdf)
- TechnoNICOL Shinglas: if the slope is above 60°, the underlayment is installed 1 m wide from the eaves edge. Nails per shingle depend on slope angle (table not in snippet) — [TechnoNICOL Shinglas manual (Palmako)](https://www.palmako.ee/sites/default/files/product_files/file/manual_01_TECHNONICOL_SHNIGLAS_YSindelMU_YSindelPU_YSindelRO_YSindelPR.pdf)
- Shinglas LT manual: galvanised roofing nails 25–30 mm, head ≥ 9 mm, shank ≥ 3 mm, about 80 g/m². The table of contents includes a section on **cone-shaped slopes (kūginiai šlaitai)**, whose text was not retrievable — [Vedrana: Shinglas įrengimo instrukcija](https://www.vedrana.lt/images/default/source/attachments/bituminiu-cerpiu-cerpeliu-montavimo-instrukcija.pdf)
- Lithuanian roofing rules ST 121895674.215.30.01:2016 "Stogų įrengimas":
  - nail count per shingle depends on slope (table 12.2, values not in snippet);
  - shingle slopes and fixing must follow the manufacturer's instructions;
  - ventilation channel above insulation ≥ **50 mm** if slope > 20°, **80 mm** if < 20°.
  - [KBU ST Šlaitiniai stogai PDF](https://kbu.lt/wp-content/uploads/2018/08/ST_%C5%A0laitiniai-stogai_v1_161203.pdf)
- **Deck thickness vs rafter spacing** (manufacturer table quoted in LT guidance, also used for Ruflex): OSB-3 is **12 mm at 60 cm, 18 mm at 90 cm, 21 mm at 120 cm, 27 mm at 150 cm** spacing. OSB below 12 mm is not acceptable. Leave a 3 mm gap at joints (another source says 5 mm), lay boards staggered, and use a bitumen underlay with ≥ 10 cm laps — [Tradehome: bituminių čerpių montavimo instrukcija](https://www.tradehome.lt/stogai/stogo-dangos/lanksciosios-cerpes/bituminiu-cerpiu-montavimo-instrukcija.htm); [Ekspertai.lt](https://www.ekspertai.lt/bitumines_cerpes/patarimai/bituminiu_cerpiu_klojimas_ant_medines_konstrukcijos); [Visainfo: dažniausios klaidos](https://www.visainfo.lt/specialistu-patarimai/bituminiu-cerpiu-montavimas-dazniausios-klaidos-3-dalis)
- Steep-slope practice (US/EU manufacturers):
  - above 60° (21:12) use ASTM D4586 asphalt roof cement in addition to nails (Atlas);
  - 6 nails per shingle above 60° (Owens Corning, BP);
  - the 45° / 12:12 limit for standard application (asphaltroofing.org);
  - mastic layer < 3 mm, because excess causes blistering (IKO);
  - factory sealant strips are less effective on very steep, shaded and cold slopes (IKO).
  - [Atlas Roofing mansard](https://www.atlasroofing.com/asphalt-life/shingling-the-steep-slopes-of-mansard-style-roofs); [Owens Corning nailing](https://www.owenscorning.com/en-us/roofing/blog/how-to-nail-roofing-shingles); [BP shingles instructions](https://bpcan.com/wp-content/uploads/2017/03/bpshingles-installationen-complete.pdf); [ARMA asphaltroofing.org](https://asphaltroofing.org/?p=427); [IKO vertical walls & steep slopes](https://www.iko.eu/en/blog/vertical-walls-and-steep-slopes)
- Cones:
  - Roofing Magazine: divide the cone into three zones; cones steeper than 21/12 may need hand sealing with plastic cement — [Roofing Magazine: shingling a cone-shaped roof](https://roofingmagazine.com/expert-tips-for-shingling-a-cone-shaped-roof/)
  - IKO: self-adhesive underlay on rounded roofs (it seals around nails), with shingle portions getting smaller toward the top — [IKO (search result)](https://iko.eu/en/search?page=110)
  - Tegola: shingles are flexible, suit curves and complex shapes, and are cut to shape after the leading edges are adhered. Minimum pitch without underlay is 14–20° depending on product — [Tegola brochure](http://www.matthewhebden.co.uk/tegola.pdf); [Tegola Canadese installation chapter](https://www.tegola-de.com/wp-content/uploads/2019/10/ROOFING-TECHNOLOGIES-CH6-pages-59-78-v2.pdf)
  - Anecdotal: on a 17 ft turret, snap radial lines from apex to eave (18" apart at the eave, converging to nothing at the top) — [Fine Homebuilding forum](https://www.finehomebuilding.com/forum/how-to-shingle-a-round-turret-roof)
- Penetrations (LT guidance):
  - shingles are laid up to the vent stack, cut out, and laid over the stack's flange;
  - at chimneys, fix a 50×50 mm triangular fillet strip, lay waterproofing over it, then the shingle course;
  - clearance to combustibles: 130 mm from masonry/concrete flues, 250 mm from uninsulated ceramic flues.
  - [Tradehome](https://www.tradehome.lt/stogai/stogo-dangos/lanksciosios-cerpes/bituminiu-cerpiu-montavimo-instrukcija.htm); [Ekspertai.lt](https://www.ekspertai.lt/bitumines_cerpes/patarimai/bituminiu_cerpiu_klojimas_ant_medines_konstrukcijos)
- Katepal FAQ recommends vertical installation on steep surfaces to prevent creases — [Katepal UK FAQ](https://www.katepaluk.co.uk/faq)

### Inferences
- **At 35–40° the shingles are within normal range.** No steep-slope regime applies (that starts at about 45° in US guidance and 60° in Shinglas/Atlas/OC). Use standard 4 nails per shingle, with self-adhesive strips that activate in sun. In Lithuanian climate, shaded north-facing segments of a cone may not seal well, so hand-applied mastic dots under tabs are cheap insurance.
- **OSB 18 mm at 1.08 m rafter spacing at the eaves exceeds the 90 cm limit for 18 mm** in the manufacturer table. The table calls for about 21 mm at 1.2 m. The rafters narrow quickly toward the top, so only the lower band (roughly the bottom 1 m of slope) is over the limit. Risks: sag between rafters, a visible "washboard" effect, and nail pull-through or creep under snow. Possible fixes: noggings or counter-battens between rafters in the lower zone, 22 mm OSB, or tongue-and-groove (T&G) boards. Flag for verification against the specific shingle brand's table.
- **Cone geometry:** standard strip shingles (3-tab, hexagonal, "Jazzy/Foxy") can be used. Each course must be cut into tapered segments (fan pattern), and the joints shift around the circumference. Near the top ring, where radius is small, segments become very narrow. There, use ridge/eaves strip or individual tiles, or switch to a metal cap or the cupola base flashing. Glue all cut edges with K-36 / Shinglas mastic.
  - Shinglas has a dedicated cone section, the most directly relevant manufacturer guidance, but it was not retrievable.
  - Self-adhesive underlay (e.g. Katepal KATE/KTX, Shinglas Anderep) across the whole cone is advisable, because radial joints in each course are more frequent than on a plane.
- **Cupola / penetration flashing:** the "min. 15 cm upstand" from the brief is in line with common practice, though I found no source for it. Usual practice is a 150–300 mm upstand on vertical walls, a triangular fillet, an underlay collar, a metal apron with counter-flashing, and mastic. Not verified from manufacturer text this session.
- **Ventilation:** ≥ 50 mm continuous air gap between insulation/underlay and OSB, with eaves intake and an outlet at the top ring or cupola. On a cone, all rafter bays converge at the top, so the outlet area there must be adequate (often via the cupola base or ring vents).

### Gaps
- Full text of the Shinglas "kūginiai šlaitai" section, Shinglas table of nails per slope, Katepal steep-roof underlay table, and the ST 2016 table 12.2 could not be fetched.
- No source found for the "15 cm upstand" figure for cupola flashing on bitumen shingle roofs.
- No manufacturer statement found on minimum cone radius or top-ring diameter.

## 5. Rafter-to-wall-plate connection with angle brackets + nails (lateral/uplift about 3–4 kN)

### Takeaway
Standard steel angle brackets have characteristic capacities of about 5–11 kN per bracket in the lateral (F2/3) direction with full nailing using 4×60 ring nails (Rothoblaas WBR). That is roughly 2.5–6 kN design, after kmod 0.9 / γM 1.3 and with nail-type and fill factors. Simpson ABR105 shows about 10.7–17.8 kN R1,k for a pair. So 3–4 kN per rafter is feasible with one well-nailed bracket, or better one per side. It is not feasible with a few short smooth nails, which is common site practice. Fully nailed brackets with ring-shank (CNA/LBA) nails ≥ 50–60 mm are needed.

### Cited Findings
- Rothoblaas WBR timber-to-timber (F2/3) characteristic values with LBA Ø4×60 nails: WBR07015 5.6 kN, WBR09015 6.8 kN, WBR10020 9.3 kN, WBR90110 7.1 kN, WBR170 11.0 kN per bracket. Some columns (10.4 / 10.9 kN; 12.4 / 9.2 kN) are for 2 brackets per joint; column labels were not clear in the snippet — [Rothoblaas WBR datasheet](https://www.rothoblaas.com/attachments/260306/01_WBR_EN.pdf)
- Shorter nails need a reduction factor kF: 0.74 for 40 mm, 0.91 for 50 mm, 1.00 for 60 mm LBA nails — [Rothoblaas WBR datasheet](https://www.rothoblaas.com/attachments/260306/01_WBR_EN.pdf)
- LBA 4 mm nail ftens,k = 6.9 kN. LBA ring nails are covered by ETA-22/0002 — [Rothoblaas LBA datasheet](https://www.rothoblaas.com/attachments/288930-product-302/lba-en-technical-data-sheet.pdf); [Rothoblaas ETA-22/0089](https://www.rothoblaas.com/attachments/293316-product-300/ETA220089)
- Simpson Strong-Tie ABR:
  - characteristic capacities in C24 for 2 brackets per connection, full nailing with CNA4.0 nails;
  - ABR105S: R1,k = 10.7 kN (CNA4.0×40) / 17.8 kN (CNA4.0×60), with 10 + 14 fasteners;
  - capacities assume short-term load and service class 2 (kmod 0.9);
  - see the ETA for other conditions.
  - [Strong-Tie LV ABR-S](https://www.strongtie.lv/en-LV/products/angle-abr7090105-embossed-abr-s); [Strong-Tie UK ABR](https://www.strongtie.co.uk/en-UK/products/reinforced-angle-bracket-abr); [Simpson ABR PDF](https://pim.strongtie.eu/api/v1/public/download/gb/en/product/260/ABR.pdf)
- F1/F2 labels in search results belong to Simpson's US H-series hurricane ties (allowable loads in lb), not to the EU ABR tables — [Simpson H/TSP](https://cdn.shopify.com/s/files/1/0398/5188/4705/files/H_-_TSP.pdf)

### Inferences
- Design value per bracket ≈ Rk · kmod / γM. For a connection, γM = 1.3 (general knowledge, not verified this session) and kmod 0.9 short-term (wind uplift and snow lateral). Example: WBR09015 at 6.8 kN gives about 4.7 kN. ABR105 (pair) at about 10.7 kN gives about 7.4 kN per pair. For about 4 kN per rafter, **one bracket per side (pair) fully nailed is adequate**. A single bracket with partial or short smooth nails may not be.
- **Radial rafters on a ring wall plate:** each rafter bears at an angle to the plate's tangent, so the bracket must sit square to the rafter and the plate. Birdsmouth (notched) seats help shear transfer. The bigger structural question is **outward thrust**. If the top ring does not act as a rigid compression ring with fixed support, horizontal thrust per rafter H ≈ (axial force)·cosα, so about 3–3.5 kN for 4.4 kN axial. The wall plate must then work as a **tension ring**: ring force T ≈ H·n/(2π) for n rafters, joined with enough splices. Verify the wall-plate splices as well as the bracket.
- Uplift: at 35–40° pitch wind suction is moderate, and the self-weight of about 0.45 kN/m² offsets part of it. 3–4 kN uplift per rafter seems high for a 4.8 m rafter at an average 0.66 m spacing, so check where that figure came from. Bracket uplift (F1-type) values are usually higher than lateral values for full nailing.

### Gaps
- Exact column labels and load directions of the WBR and ABR tables were not readable. The values above are snippet extractions and must be checked in the PDFs/ETAs.
- No Lithuanian-specific connector guidance found. No data found for cheap unbranded angle brackets common in LT DIY stores, which often have no ETA and should not be assumed to match Simpson/Rothoblaas values.
