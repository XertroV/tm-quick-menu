void JoinServer(const string &in joinLink, PermissionState p = PermissionState::ShouldCheck) {
    // permissions
    bool allowed = p == PermissionState::AlreadyChecked;
    allowed = allowed || Permissions::PlayPublicClubRoom();
    if (!allowed) {
        NotifyError("You don't have permission to join servers");
        return;
    }
    // actually join
    string serverLogin = LoginFromJoinLink(joinLink);
    if (serverLogin == "") return;
    ReturnToMenu(true);
    auto app = cast<CGameManiaPlanet>(GetApp());
    app.ManiaTitleControlScriptAPI.JoinServer(serverLogin, false, "");
}

void ReturnToMenu(bool yieldTillReady = false) {
    auto app = cast<CGameManiaPlanet>(GetApp());
    // if we're already in the main menu, don't do anything
    if (app.Switcher.ModuleStack.Length == 0 && app.LoadProgress.State == NGameLoadProgress::EState::Disabled) return;
    // if we're in the in-game menu, close it to avoid crashing
    if (app.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
        app.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit);
    }
    app.BackToMainMenu();
    while (yieldTillReady && !app.ManiaTitleControlScriptAPI.IsReady) yield();
}

void PlayMap(const string &in pathOrUrl) {
    if (!Permissions::PlayLocalMap()) {
        NotifyError("You don't have permission to play local maps");
        return;
    }
    ReturnToMenu(true);
    auto app = cast<CGameManiaPlanet>(GetApp());
    app.ManiaTitleControlScriptAPI.PlayMap(pathOrUrl, "", "");
}

void UploadMap(const string &in path) {
    if (!Permissions::CreateAndUploadMap()) {
        NotifyError("Refusing to upload maps because you are missing the CreateAndUploadMap permissions.");
        return;
    }
    auto ix = path.IndexOf("\\Maps\\");
    if (ix == -1) {
        NotifyError("Refusing to upload maps that are not in the Maps folder.");
        return;
    }
    auto mapUserPath = path.SubStr(ix);
    trace("UploadMap: " + mapUserPath);
    auto fid = Fids::GetUser(mapUserPath);
    if (fid is null) {
        NotifyError("Failed to get Fid for map: " + mapUserPath);
        return;
    }
    auto map = cast<CGameCtnChallenge>(Fids::Preload(fid));
    if (map is null) {
        NotifyError("Failed to preload map fid: " + mapUserPath);
        return;
    }

    auto uid = map.Id.GetName();
    trace('UploadMapFromLocal: ' + uid);
    S_LastUploadedUid = uid;

    auto app = cast<CGameManiaPlanet>(GetApp());
    Notify("Uploading map: " + Text::OpenplanetFormatCodes(S_LastMapName) + " | UID: " + uid);
    auto cma = app.MenuManager.MenuCustom_CurrentManiaApp;
    auto dfm = cma.DataFileMgr;
    auto userId = cma.UserMgr.Users[0].Id;
    auto regScript = dfm.Map_NadeoServices_Register(userId, uid);
    while (regScript.IsProcessing) yield();
    // reset this, it gets set again in success branch
    S_LastUploadedUid = "";
    if (regScript.HasFailed) {
        NotifyError("Uploading map failed: " + regScript.ErrorType + ", " + regScript.ErrorCode + ", " + regScript.ErrorDescription);
    } else if (regScript.HasSucceeded) {
        trace("UploadMapFromLocal: Map uploaded: " + uid);
        NotifySuccess("Uploaded map: " + Text::OpenplanetFormatCodes(S_LastMapName));
        S_LastUploadedUid = uid;
        Meta::SaveSettings();
    } else if (regScript.IsCanceled) {
        trace("UploadMapFromLocal: Map upload canceled?!: " + uid);
    } else {
        NotifyError("Uploading map failed: unknown error" + regScript.IsCanceled + ' / ' + regScript.IsProcessing);
    }
    dfm.TaskResult_Release(regScript.Id);
}
