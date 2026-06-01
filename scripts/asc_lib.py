import json,time,os,urllib.request,urllib.error,jwt
KEY_ID="K34HFNJTXH";ISS="69a6de84-f289-47e3-e053-5b8c7c11a4d1"
P8=os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_K34HFNJTXH.p8")
APP_ID="6761826412";BASE="https://api.appstoreconnect.apple.com"
def tok():
    return jwt.encode({"iss":ISS,"iat":int(time.time()),"exp":int(time.time())+1100,"aud":"appstoreconnect-v1"},open(P8).read(),algorithm="ES256",headers={"kid":KEY_ID,"typ":"JWT"})
TOK=tok()
def req(method,path,body=None,full=None):
    url=full or (BASE+path)
    data=json.dumps(body).encode() if body is not None else None
    h={"Authorization":f"Bearer {TOK}"}
    if body is not None:h["Content-Type"]="application/vnd.api+json"
    r=urllib.request.Request(url,data=data,method=method,headers=h)
    try:
        with urllib.request.urlopen(r) as resp:
            b=resp.read();return resp.status,(json.loads(b) if b else None)
    except urllib.error.HTTPError as e:
        return e.code,e.read().decode(errors="replace")
