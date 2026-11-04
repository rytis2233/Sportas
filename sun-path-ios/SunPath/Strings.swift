import Foundation

/// English / Lithuanian strings and date formatting.
enum L {
    static var lang = "en"

    static func t(_ k: String) -> String {
        if lang == "lt", let v = LT[k] { return v }
        return EN[k] ?? k
    }

    static var dirs: [String] {
        lang == "lt"
            ? ["Š", "ŠŠR", "ŠR", "RŠR", "R", "RPR", "PR", "PPR", "P", "PPV", "PV", "VPV", "V", "VŠV", "ŠV", "ŠŠV"]
            : ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    }

    static func dirName(_ az: Double) -> String {
        dirs[Int((Astro.norm360(az) / 22.5).rounded()) % 16]
    }

    private static var formatters: [String: DateFormatter] = [:]
    private static func fmt(_ d: Date?, _ template: String) -> String {
        guard let d = d else { return "—" }
        let key = lang + "|" + template
        if let f = formatters[key] { return f.string(from: d) }
        let f = DateFormatter()
        f.locale = Locale(identifier: lang == "lt" ? "lt_LT" : "en_GB")
        f.setLocalizedDateFormatFromTemplate(template)
        formatters[key] = f
        return f.string(from: d)
    }
    static func time(_ d: Date?) -> String { fmt(d, "HH:mm") }
    static func date(_ d: Date) -> String { fmt(d, "EEE d MMM yyyy") }
    static func shortDate(_ d: Date) -> String { fmt(d, "d MMM") }
    static func longDate(_ d: Date) -> String { fmt(d, "d MMMM yyyy") }
    static func dur(_ s: Double) -> String {
        let m = Int((s / 60).rounded())
        return "\(m / 60) h " + String(format: "%02d", m % 60) + " min"
    }
    static func deg(_ x: Double, _ digits: Int = 0) -> String { String(format: "%.\(digits)f°", x) }
    static func signed(_ x: Double) -> String { (x >= 0 ? "+" : "") + String(format: "%.1f°", x) }

    static let EN: [String: String] = [
        "appName": "Sun Path",
        "calibrate": "Calibrate", "travel": "Time Travel", "compare": "Compare Dates", "solstice": "Solstice Arcs",
        "eclipses": "Upcoming Eclipses", "language": "Language", "cancel": "Cancel", "done": "Done", "now": "Now", "reset": "Reset",
        "timeTravel": "Time travel", "calibrating": "Calibrating", "manual": "Drag to look around",
        "about": "About Sun Path",
        "howTitle": "How it works",
        "how": "The yellow line is the sun's path for the day. The solid part is above the horizon, the dashed part below it. Dots mark each hour; arrows mark sunrise and sunset.",
        "offlineTitle": "Works offline",
        "offline": "All calculations run on your phone. Sun position (VSOP87), moon position (ELP-2000/82) and eclipse contacts are computed locally — no internet connection is needed.",
        "sensorsTitle": "Sensors",
        "sensors": "Orientation comes from Apple's motion processing, which fuses the gyroscope, accelerometer and compass and is referenced to true north. iOS recalibrates the compass by itself; if it asks, move the phone in a figure-8. When the sun is in the camera view, the overlay is also aligned to it.",
        "accTitle": "Accuracy",
        "acc": "The sun's position is accurate to about 1 arcsecond, eclipse contact times to within about 30 seconds. The camera's exact field of view is read from the phone, so the overlay matches the picture.",
        "status": "Status", "location": "Location", "orientation": "Orientation", "compassCal": "Compass", "cameraFov": "Camera field of view",
        "calibration": "Calibration offset", "noonAlt": "Noon altitude",
        "sunrise": "Sunrise", "sunset": "Sunset", "noon": "Solar noon", "daylength": "Day length",
        "polarDay": "Sun never sets", "polarNight": "Sun never rises",
        "edit": "Edit", "save": "Save", "useGps": "Use GPS", "lat": "Latitude", "lon": "Longitude",
        "gps": "GPS", "manualLoc": "set manually", "approxLoc": "approximate — tap Edit",
        "oriTrue": "true north (Apple)", "oriMag": "magnetic north + model", "oriRel": "gyroscope only", "oriNone": "no motion sensors",
        "calUnknown": "—", "calUncal": "needs calibration", "calLow": "low accuracy", "calMed": "medium accuracy", "calHigh": "high accuracy",
        "calHelp": "Tap the real sun on the screen, or aim the crosshair at it and tap Align to sun. Drag to nudge.",
        "calHelpNight": "The sun is below the horizon. Drag the screen to nudge the overlay onto a known direction.",
        "alignSun": "Align to sun", "fov": "Field of view", "offset": "Offset",
        "aligned": "Aligned to the sun", "autoAligned": "☀ Sun found in the camera — overlay aligned",
        "autoAlign": "Auto-align when the sun is in view", "waitLoc": "Waiting for location…",
        "cmpTitle": "Compare with", "hideCmp": "Turn off",
        "junSol": "June solstice", "decSol": "December solstice", "marEq": "March equinox", "plus1m": "+1 month", "plus6m": "+6 months",
        "solOn": "Solstice arcs on", "solOff": "Solstice arcs off", "equinox": "Equinox",
        "eclTitle": "Upcoming Eclipses", "eclIntro": "Solar eclipses visible from your location, with local times.",
        "calcing": "Calculating…", "noEcl": "No solar eclipses visible from here in the next 30 years.",
        "total": "Total solar eclipse", "annular": "Annular solar eclipse", "partial": "Partial solar eclipse",
        "hereTotal": "Total here", "hereAnnular": "Annular here", "herePartial": "Partial here",
        "obsc": "covered", "sunAlt": "sun at", "risesE": "sun rises eclipsed", "setsE": "sun sets eclipsed",
        "showSky": "Show in sky", "begins": "Begins", "max": "Max", "ends": "Ends", "eclipse": "Eclipse",
        "noCam": "Camera unavailable — allow it in Settings", "noLoc": "Location unavailable — set it in About",
        "saved": "Photo saved to Photos"
    ]

    static let LT: [String: String] = [
        "appName": "Saulės kelias",
        "calibrate": "Kalibruoti", "travel": "Kelionė laiku", "compare": "Palyginti datas", "solstice": "Saulėgrįžų lankai",
        "eclipses": "Artimiausi užtemimai", "language": "Kalba", "cancel": "Atšaukti", "done": "Baigti", "now": "Dabar", "reset": "Atstatyti",
        "timeTravel": "Kelionė laiku", "calibrating": "Kalibruojama", "manual": "Tempk, kad apsidairytum",
        "about": "Apie Saulės kelią",
        "howTitle": "Kaip tai veikia",
        "how": "Geltona linija — saulės kelias per dieną. Ištisinė dalis yra virš horizonto, punktyrinė — po juo. Taškai žymi valandas, rodyklės — saulėtekį ir saulėlydį.",
        "offlineTitle": "Veikia be interneto",
        "offline": "Visi skaičiavimai atliekami telefone. Saulės padėtis (VSOP87), Mėnulio padėtis (ELP-2000/82) ir užtemimų kontaktai skaičiuojami vietoje — internetas nereikalingas.",
        "sensorsTitle": "Jutikliai",
        "sensors": "Padėtis gaunama iš Apple judesio apdorojimo, kuris sujungia giroskopą, akselerometrą ir kompasą ir yra susietas su tikrąja šiaure. iOS kompasą kalibruoja pati; jei paprašys, pamojuok telefonu aštuoniuke. Kai saulė matoma kameroje, piešinys dar ir sulygiuojamas su ja.",
        "accTitle": "Tikslumas",
        "acc": "Saulės padėtis tiksli maždaug iki 1 lanko sekundės, užtemimų kontaktų laikai — iki ~30 sekundžių. Tikslus kameros matymo kampas nuskaitomas iš telefono, todėl piešinys sutampa su vaizdu.",
        "status": "Būsena", "location": "Vieta", "orientation": "Orientacija", "compassCal": "Kompasas", "cameraFov": "Kameros matymo kampas",
        "calibration": "Kalibravimo pataisa", "noonAlt": "Aukštis vidurdienį",
        "sunrise": "Saulėtekis", "sunset": "Saulėlydis", "noon": "Saulės vidurdienis", "daylength": "Dienos ilgumas",
        "polarDay": "Saulė nenusileidžia", "polarNight": "Saulė nepateka",
        "edit": "Keisti", "save": "Išsaugoti", "useGps": "Naudoti GPS", "lat": "Platuma", "lon": "Ilguma",
        "gps": "GPS", "manualLoc": "nustatyta rankiniu būdu", "approxLoc": "apytikslė — spausk Keisti",
        "oriTrue": "tikroji šiaurė (Apple)", "oriMag": "magnetinė šiaurė + modelis", "oriRel": "tik giroskopas", "oriNone": "nėra judesio jutiklių",
        "calUnknown": "—", "calUncal": "reikia kalibruoti", "calLow": "mažas tikslumas", "calMed": "vidutinis tikslumas", "calHigh": "didelis tikslumas",
        "calHelp": "Paliesk tikrąją saulę ekrane arba nukreipk į ją kryželį ir spausk „Sulygiuoti su saule“. Tempk, kad pataisytum.",
        "calHelpNight": "Saulė po horizontu. Tempk ekraną, kad sulygintum piešinį su žinoma kryptimi.",
        "alignSun": "Sulygiuoti su saule", "fov": "Matymo kampas", "offset": "Pataisa",
        "aligned": "Sulygiuota su saule", "autoAligned": "☀ Saulė rasta kameroje — piešinys sulygiuotas",
        "autoAlign": "Automatiškai lygiuoti, kai saulė matoma", "waitLoc": "Laukiama vietos…",
        "cmpTitle": "Palyginti su", "hideCmp": "Išjungti",
        "junSol": "Birželio saulėgrįža", "decSol": "Gruodžio saulėgrįža", "marEq": "Kovo lygiadienis", "plus1m": "+1 mėn.", "plus6m": "+6 mėn.",
        "solOn": "Saulėgrįžų lankai įjungti", "solOff": "Saulėgrįžų lankai išjungti", "equinox": "Lygiadienis",
        "eclTitle": "Artimiausi užtemimai", "eclIntro": "Saulės užtemimai, matomi iš tavo vietos, vietos laiku.",
        "calcing": "Skaičiuojama…", "noEcl": "Per artimiausius 30 metų iš čia matomų Saulės užtemimų nėra.",
        "total": "Visiškas Saulės užtemimas", "annular": "Žiedinis Saulės užtemimas", "partial": "Dalinis Saulės užtemimas",
        "hereTotal": "Čia visiškas", "hereAnnular": "Čia žiedinis", "herePartial": "Čia dalinis",
        "obsc": "uždengta", "sunAlt": "saulė", "risesE": "saulė teka užtemusi", "setsE": "saulė leidžiasi užtemusi",
        "showSky": "Rodyti danguje", "begins": "Pradžia", "max": "Maks.", "ends": "Pabaiga", "eclipse": "Užtemimas",
        "noCam": "Kamera nepasiekiama — leisk ją Nustatymuose", "noLoc": "Vieta nežinoma — nustatyk ją skiltyje Apie",
        "saved": "Nuotrauka išsaugota Nuotraukose"
    ]
}
