"""Fetch a CC0 360° panorama from Poly Haven for the Sun Path website preview.

Controlled by sun-path/sky-request.txt:
  candidates      -> save small previews of popular overcast / partly cloudy
                     outdoor panoramas to sun-path/_sky/ (to pick one)
  use <asset-id>  -> save that panorama as sun-path/sky.jpg (4096x2048) with
                     a credit file, and remove the previews
"""
import io, json, os, shutil, sys, urllib.request

from PIL import Image

Image.MAX_IMAGE_PIXELS = None  # 8K panoramas

API = "https://api.polyhaven.com"
HEADERS = {"User-Agent": "sun-path-preview-builder"}


def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=HEADERS), timeout=120) as r:
        return r.read()


def save_resized(data, path, size, quality):
    img = Image.open(io.BytesIO(data)).convert("RGB")
    img.resize(size, Image.LANCZOS).save(path, "JPEG", quality=quality, optimize=True, progressive=True)


def tonemapped_url(asset):
    files = json.loads(get(f"{API}/files/{asset}"))
    tm = files.get("tonemapped")
    if isinstance(tm, dict) and tm.get("url"):
        return tm["url"]
    raise SystemExit(f"{asset}: no tonemapped JPG")


request = open("sun-path/sky-request.txt").read().split()
os.makedirs("sun-path/_sky", exist_ok=True)

if request and request[0] == "candidates":
    assets = json.loads(get(f"{API}/assets?t=hdris&c=outdoor"))
    picks = []
    for name, a in assets.items():
        cats = set(a.get("categories", []))
        if cats & {"overcast", "partly cloudy"} and "urban" not in cats and "pure skies" not in cats:
            picks.append((a.get("download_count", 0), name))
    picks.sort(reverse=True)
    lines = []
    for _, name in picks[:10]:
        try:
            save_resized(get(tonemapped_url(name)), f"sun-path/_sky/{name}.jpg", (1024, 512), 72)
            lines.append(f"{name}\t{', '.join(sorted(assets[name].get('categories', [])))}")
            print("ok", name)
        except Exception as e:  # keep going with the others
            print("skip", name, e)
    open("sun-path/_sky/list.txt", "w").write("\n".join(lines) + "\n")
elif request and request[0] == "use" and len(request) > 1:
    name = request[1]
    save_resized(get(tonemapped_url(name)), "sun-path/sky.jpg", (4096, 2048), 80)
    info = json.loads(get(f"{API}/info/{name}"))
    authors = ", ".join(info.get("authors", {}).keys()) or "Poly Haven"
    open("sun-path/sky-credit.txt", "w").write(
        f"360° sky panorama: \"{info.get('name', name)}\" by {authors}, Poly Haven (polyhaven.com/a/{name}), CC0.\n")
    shutil.rmtree("sun-path/_sky", ignore_errors=True)
else:
    sys.exit("sun-path/sky-request.txt must be 'candidates' or 'use <asset-id>'")
