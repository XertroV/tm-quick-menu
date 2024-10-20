
string LoginFromJoinLink(const string &in joinLink) {
    auto match = Regex::Search(joinLink, "join=([a-zA-Z0-9-_]{22})", Regex::Flags::Extended);
    if (match.Length <= 1) {
        NotifyError("Failed to extract login from join link: " + joinLink);
        return "";
    }
    trace("Parsed join link: " + Json::Write(match.ToJson()));
    return match[1];
}
