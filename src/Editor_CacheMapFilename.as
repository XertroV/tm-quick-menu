[Setting hidden]
string S_LastMapFileName = "";

[Setting hidden]
string S_LastMapName = "";

[Setting hidden]
string S_LastMapUid = "";

[Setting hidden]
string S_LastUploadedUid = "";

// Json obj with array of objects. Each object has "name" and "filename" keys. Ordered by most recent.
[Setting hidden]
string S_PastMapsJson = "";

void CacheEditedMapFileName(CGameCtnChallenge@ challenge) {
    if (challenge is null) return;
    auto fid = GetFidFromNod(challenge);
    if (fid is null) return;
    auto fileName = fid.FullFileName;
    if (!fileName.Contains("\\Maps\\")) return;
    if (S_LastMapFileName == fileName) return;
    S_LastMapFileName = fileName;
    S_LastMapName = challenge.MapName;
    S_LastMapUid = challenge.Id.GetName();
    AddMapToPastMaps(S_LastMapName, fileName);
    trace("Cached last edited map file name: " + fileName);
    // trace(S_PastMapsJson);
    Meta::SaveSettings();
}

void AddMapToPastMaps(const string &in name, const string &in filename) {
    Json::Value@ j = Json::Object();
    try {
        @j = Json::Parse(S_PastMapsJson);
    } catch {
        warn("Failed to parse past maps json; resetting");
    }
    if (j.GetType() != Json::Type::Object) {
        @j = Json::Object();
    }

    auto @recentMaps = Json::Array();
    if (j.HasKey("recentMaps")) {
        @recentMaps = j["recentMaps"];
        if (recentMaps.GetType() != Json::Type::Array) {
            warn("recentMaps is not an array; resetting");
            @recentMaps = Json::Array();
        }
    }

    auto ix = JsonArrFind(recentMaps, "filename", filename);
    if (ix != -1) {
        recentMaps.Remove(ix);
    }
    auto mapObj = Json::Object();
    mapObj["name"] = name;
    mapObj["filename"] = filename;
    JsonArrInsert(recentMaps, 0, mapObj);
    while (recentMaps.Length > 10) {
        recentMaps.Remove(10);
    }

    j["recentMaps"] = recentMaps;
    S_PastMapsJson = Json::Write(j);
}

int JsonArrFind(Json::Value@ arr, const string &in key, const string &in val) {
    for (uint i = 0; i < arr.Length; i++) {
        if (arr[i].HasKey(key) && arr[i][key].GetType() == Json::Type::String && string(arr[i][key]) == val) {
            return i;
        }
    }
    return -1;
}

void JsonArrInsert(Json::Value@ arr, uint ix, Json::Value@ val) {
    Json::Value@[] tmp(arr.Length);
    for (uint i = 0; i < arr.Length; i++) {
        @tmp[i] = arr[i];
    }
    while (arr.Length > ix) {
        arr.Remove(arr.Length - 1);
    }
    arr.Add(val);
    for (uint i = ix; i < tmp.Length; i++) {
        arr.Add(tmp[i]);
    }
}
