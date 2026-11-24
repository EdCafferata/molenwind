"""Voegt per molen het OpenStreetMap-object toe ("osm": "node/123") aan ios/Molenwind/Resources/molens.json.

Koppeling: eerst op ref:tenbruggencate; anders het dichtstbijzijnde OSM-molenobject binnen 40 m.
Molens met openingstijden worden alleen gekoppeld aan een object met precies dezelfde opening_hours,
zodat "Bekijk/verbeter op OpenStreetMap" altijd naar de bron van die tijden wijst.
Gebruik (vanuit de repo-root): python3 research/osm_koppelen.py
"""
import json
import math

MOLENS = "ios/Molenwind/Resources/molens.json"
OSM = "research/osm_windmills.json"
MAX_M = 40


def pos(e):
    c = e.get("center", {})
    return e.get("lat", c.get("lat")), e.get("lon", c.get("lon"))


def afstand(lat1, lon1, lat2, lon2):
    return math.hypot((lat1 - lat2) * 111_000, (lon1 - lon2) * 111_000 * math.cos(math.radians(lat1)))


molens = json.load(open(MOLENS, encoding="utf-8"))
elementen = [e for e in json.load(open(OSM, encoding="utf-8"))["elements"] if pos(e)[0] is not None]
op_ref = {e["tags"]["ref:tenbruggencate"]: e for e in elementen if "ref:tenbruggencate" in e.get("tags", {})}

gekoppeld = 0
for m in molens:
    m.pop("osm", None)
    kandidaten = [op_ref[m["id"]]] if m["id"] in op_ref else elementen
    if m.get("open"):
        kandidaten = [e for e in kandidaten if e["tags"].get("opening_hours") == m["open"]] or [
            e for e in elementen if e["tags"].get("opening_hours") == m["open"]]
    if not kandidaten:
        continue
    best = min(kandidaten, key=lambda e: afstand(m["lat"], m["lon"], *pos(e)))
    if m["id"] in op_ref and best is op_ref[m["id"]] or afstand(m["lat"], m["lon"], *pos(best)) <= MAX_M:
        m["osm"] = f'{best["type"]}/{best["id"]}'
        gekoppeld += 1

json.dump(molens, open(MOLENS, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
print(f"{gekoppeld} van {len(molens)} molens gekoppeld aan OpenStreetMap")
