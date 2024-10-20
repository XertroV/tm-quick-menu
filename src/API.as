const string TOTD_JOIN_URL = "https://live-services.trackmania.nadeo.live/api/token/channel/daily/join";
const string LIVE_AUDIENCE = "NadeoLiveServices";
string GetTotdJoinLink() {
    NadeoServices::AddAudience(LIVE_AUDIENCE);
    while (!NadeoServices::IsAuthenticated(LIVE_AUDIENCE)) {
        yield();
    }
    auto req = NadeoServices::Post(LIVE_AUDIENCE, TOTD_JOIN_URL);
    req.Start();
    trace("Getting JoinLink for TOTD...");
    while (!req.Finished()) yield();
    if (req.ResponseCode() != 200) {
        throw("Failed to get JoinLink for TOTD: " + req.ResponseCode());
        return "";
    }
    auto j = req.Json();
    return j["joinLink"];
}
