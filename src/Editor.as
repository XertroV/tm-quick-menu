void WatchForEditor() {
    auto app = GetApp();
    auto editor = cast<CGameCtnEditorFree>(GetApp().Editor);
    while (true) {
        while ((@editor = cast<CGameCtnEditorFree>(app.Editor)) is null) {
            yield();
        }
        auto mapId = editor.Challenge.Id.Value;
        CacheEditedMapFileName(editor.Challenge);
        while ((@editor = cast<CGameCtnEditorFree>(app.Editor)) !is null) {
            if (editor.Challenge.Id.Value != mapId) {
                while (app.BasicDialogs.Dialogs.CurrentFrame !is null) {
                    yield();
                }
                mapId = editor.Challenge.Id.Value;
                CacheEditedMapFileName(editor.Challenge);
            }
            yield();
        }
    }
}

void EditMapFrom(const string &in filename) {
    if (!Permissions::OpenAdvancedMapEditor()) {
        NotifyError("You don't have permission to edit maps");
        return;
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    if (!IsInMenu(app.Switcher)) {
        NotifyError("Must be in main menu");
        return;
    }
    app.ManiaTitleControlScriptAPI.EditMap(filename, "", "");
}

void EditNewMap() {
    if (!Permissions::OpenAdvancedMapEditor()) {
        NotifyError("You don't have permission to edit maps");
        return;
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    if (!IsInMenu(app.Switcher)) {
        NotifyError("Must be in main menu");
        return;
    }
    app.ManiaTitleControlScriptAPI.EditNewMap2("Stadium", "48x48Screen155Day", "", "CarSport", "", false, "", "");
}

bool IsInMenu(CGameSwitcher@ switcher) {
    return switcher.ModuleStack.Length == 1
        && cast<CTrackManiaMenus>(switcher.ModuleStack[0]) !is null;
}
