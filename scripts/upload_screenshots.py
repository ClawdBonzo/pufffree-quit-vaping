#!/usr/bin/env python3
"""Upload PuffFree App Store screenshots (6.9") to ASC version localizations via the API."""
import json, time, hashlib, os, sys, urllib.request, urllib.error
import jwt  # PyJWT

KEY_ID = "K34HFNJTXH"
ISSUER_ID = "69a6de84-f289-47e3-e053-5b8c7c11a4d1"
P8 = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_K34HFNJTXH.p8")
APP_ID = "6761826412"
DISPLAY = "APP_IPHONE_67"
BASE = "https://api.appstoreconnect.apple.com"
ROOT = "/Users/robgoldstein/Desktop/PuffFree-Quitting/screenshots/final"
# locale -> image subfolder
LOC_DIR = {"en-US": "en", "en-GB": "en", "de-DE": "de", "fr-FR": "fr"}
IMAGES = ["01.png", "02.png", "03.png", "04.png"]

def token():
    key = open(P8).read()
    return jwt.encode({"iss": ISSUER_ID, "iat": int(time.time()),
                       "exp": int(time.time()) + 1100, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": KEY_ID, "typ": "JWT"})

TOK = token()

def req(method, path, body=None, headers=None, raw=None, full_url=None, auth=True):
    url = full_url or (BASE + path)
    data = raw if raw is not None else (json.dumps(body).encode() if body is not None else None)
    h = {"Authorization": f"Bearer {TOK}"} if auth else {}
    if body is not None: h["Content-Type"] = "application/vnd.api+json"
    if headers: h.update(headers)
    r = urllib.request.Request(url, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(r) as resp:
            b = resp.read()
            return resp.status, (json.loads(b) if b and resp.headers.get("content-type","").startswith("application/") else b)
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors="replace")

# 1. Find the editable iOS version
st, v = req("GET", f"/v1/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=10")
assert st == 200, f"versions {st}: {v}"
ver = next((x for x in v["data"] if x["attributes"]["appStoreState"] in
            ("PREPARE_FOR_SUBMISSION","DEVELOPER_REJECTED","REJECTED","METADATA_REJECTED","READY_FOR_REVIEW")), v["data"][0])
vid = ver["id"]
print("version", vid, ver["attributes"]["versionString"], ver["attributes"]["appStoreState"])

# 2. Localizations
st, locs = req("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations?limit=200")
assert st == 200, f"locs {st}: {locs}"
loc_by_locale = {l["attributes"]["locale"]: l["id"] for l in locs["data"]}
print("localizations:", loc_by_locale)

def ensure_set(loc_id):
    st, sets = req("GET", f"/v1/appStoreVersionLocalizations/{loc_id}/appScreenshotSets?limit=50")
    assert st == 200, f"sets {st}: {sets}"
    for s in sets["data"]:
        if s["attributes"]["screenshotDisplayType"] == DISPLAY:
            return s["id"], len(s.get("relationships",{}).get("appScreenshots",{}).get("data",[]) or [])
    body = {"data": {"type": "appScreenshotSets",
                     "attributes": {"screenshotDisplayType": DISPLAY},
                     "relationships": {"appStoreVersionLocalization": {"data": {"type": "appStoreVersionLocalizations", "id": loc_id}}}}}
    st, s = req("POST", "/v1/appScreenshotSets", body)
    assert st in (200,201), f"create set {st}: {s}"
    return s["data"]["id"], 0

def upload_one(set_id, path):
    raw = open(path, "rb").read()
    fname = os.path.basename(path)
    body = {"data": {"type": "appScreenshots",
                     "attributes": {"fileSize": len(raw), "fileName": fname},
                     "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}}}}
    st, s = req("POST", "/v1/appScreenshots", body)
    assert st in (200,201), f"reserve {st}: {s}"
    sid = s["data"]["id"]
    for op in s["data"]["attributes"]["uploadOperations"]:
        hdrs = {hh["name"]: hh["value"] for hh in (op.get("requestHeaders") or [])}
        chunk = raw[op["offset"]:op["offset"]+op["length"]]
        st2, b2 = req(op["method"], None, raw=chunk, headers=hdrs, full_url=op["url"], auth=False)
        assert st2 in (200,201,204), f"put {st2}: {b2}"
    md5 = hashlib.md5(raw).hexdigest()
    st3, s3 = req("PATCH", f"/v1/appScreenshots/{sid}",
                  {"data": {"type": "appScreenshots", "id": sid,
                            "attributes": {"uploaded": True, "sourceFileChecksum": md5}}})
    assert st3 == 200, f"commit {st3}: {s3}"
    return sid

for locale, sub in LOC_DIR.items():
    if locale not in loc_by_locale:
        print("SKIP (no localization):", locale); continue
    set_id, existing = ensure_set(loc_by_locale[locale])
    # Clear any existing/orphaned screenshots for a clean, idempotent set.
    st, cur = req("GET", f"/v1/appScreenshotSets/{set_id}/appScreenshots?limit=50")
    if st == 200:
        for sc in cur["data"]:
            req("DELETE", f"/v1/appScreenshots/{sc['id']}")
    print(f"{locale}: set {set_id} (cleared {existing}) — uploading {len(IMAGES)}")
    for img in IMAGES:
        p = os.path.join(ROOT, sub, img)
        sid = upload_one(set_id, p)
        print(f"   uploaded {sub}/{img} -> {sid}")
print("DONE")
