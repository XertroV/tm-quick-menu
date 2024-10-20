bool Perms_EditMap = false;
bool Perms_JoinTOTD = false;

enum PermissionState {
    ShouldCheck,
    AlreadyChecked,
}

void Main() {
    Perms_EditMap = Permissions::OpenAdvancedMapEditor();
    Perms_JoinTOTD = Permissions::PlayTOTDChannel();
    startnew(WatchForEditor);
}

void Render() {
    auto app = GetApp();
    if (!IsInMenu(app.Switcher)) return;
    // in the menu
    DrawMainQuickMenu();
}

uint lastAction = 0;

[Setting hidden]
bool S_ShowJoinTotd = true;
[Setting hidden]
bool S_ShowNewMap = true;
[Setting hidden]
bool S_ShowEditLastMap = true;


void DrawMainQuickMenu() {
    bool rClick = false;

    UI::SetNextWindowSize(90, 130, UI::Cond::Appearing);
    if (UI::Begin("Quick Menu", UI::WindowFlags::AlwaysAutoResize | UI::WindowFlags::NoCollapse)) {
        UI::BeginDisabled(lastAction + 1000 > Time::Now);
        if (S_ShowJoinTotd) {
            if (Perms_JoinTOTD) {
                if (UI::Button("Join TOTD")) {
                    startnew(Run_JoinTOTD);
                    lastAction = Time::Now;
                }
                rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
            } else {
                UI::TextDisabled("Join TOTD");
                AddSimpleTooltip("You don't have permission to join TOTD");
            }
        }

        if (S_ShowJoinTotd && (S_ShowNewMap || S_ShowEditLastMap)) UI::Separator();

        if (Perms_EditMap) {
            if (S_ShowNewMap) {
                if (UI::Button("New Map")) {
                    startnew(Run_EditMapNow);
                    lastAction = Time::Now;
                }
                rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
            }
            if (S_ShowEditLastMap) {
                if (UI::BeginMenu("Last Edited")) {
                    if (UI::Button("Edit Last")) {
                        startnew(Run_EditLastMap);
                        lastAction = Time::Now;
                    }
                    rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
                    AddSimpleTooltip("Edit: " + Text::OpenplanetFormatCodes(S_LastMapName));
                    //--
                    if (UI::Button("Open Folder")) {
                        startnew(Run_OpenFolderLastEditedMap);
                        lastAction = Time::Now;
                    }
                    rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
                    //--
                    if (UI::Button("Play Last Edited")) {
                        startnew(Run_PlayLastEditedMap);
                        lastAction = Time::Now;
                    }
                    rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
                    //--
                    UI::Separator();
                    UI::BeginDisabled(S_LastUploadedUid == S_LastMapUid);
                    if (UI::Button("Upload Last Edited")) {
                        startnew(Run_UploadLastEditedMap);
                        lastAction = Time::Now;
                    }
                    rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
                    UI::EndDisabled();
                    //--
                    UI::EndMenu();
                }
                rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
            }
        } else {
            if (S_ShowNewMap) {
                UI::TextDisabled("New Map");
                AddSimpleTooltip("You don't have permission to edit maps");
            }
            if (S_ShowEditLastMap) {
                UI::TextDisabled("Edit Last");
                AddSimpleTooltip("You don't have permission to edit maps");
            }
        }

        UI::EndDisabled();

        bool nothingDrawn = !S_ShowJoinTotd && !S_ShowNewMap && !S_ShowEditLastMap;
        if (nothingDrawn) {
            DrawSettings();
        } else {
            UI::Separator();
            UI::Text("\\$i\\$999Opts: RClick");
            rClick = rClick || UI::IsItemClicked(UI::MouseButton::Right);
        }
    }
    UI::End();

    if (rClick) {
        UI::OpenPopup("Quick Menu Options");
    }

    if (UI::BeginPopup("Quick Menu Options")) {
        DrawSettings();
        UX::CloseCurrentPopupIfMouseFarAway();
        UI::EndPopup();
    }
}

void DrawSettings() {
    S_ShowJoinTotd = UI::Checkbox("Show Join TOTD", S_ShowJoinTotd);
    S_ShowEditLastMap = UI::Checkbox("Show Edit Last Map", S_ShowEditLastMap);
    S_ShowNewMap = UI::Checkbox("Show New Map", S_ShowNewMap);
    if (S_ShowNewMap) {
        UI::Indent();
        Draw_MapDefaultsSettings();
        UI::Unindent();
    }
    UI::Text("\\$i\\$999RClick works on the buttons, too.");
}

void Run_EditMapNow() {
#if DEPENDENCY_MAP_TOGETHER
    EditorPatches::SkipClubFavItemUpdate_IsApplied = true;
    // EditNewMapFrom(MapBase::Stadium155, MapMood::Day, MapCar::CarSport, nat3(48, 255, 48), "Stadium");
    EditNewMapFrom(S_NewMapBase, S_NewMapMood, S_NewMapCar, S_NewMapSize, "Stadium");
    EditorPatches::SkipClubFavItemUpdate_IsApplied = false;
#elif DEPENDENCY_EDITOR
    Editor::NextEditorLoad_EnableInventoryPatch(Editor::InvPatchType::SkipClubUpdateCheck);
    EditNewMap();
#else
    EditNewMap();
#endif
}

void Run_EditLastMap() {
    if (S_LastMapFileName == "") {
        NotifyError("No map has been edited yet");
        return;
    }
#if DEPENDENCY_MAP_TOGETHER
    EditorPatches::SkipClubFavItemUpdate_IsApplied = true;
    EditMapFrom(S_LastMapFileName);
    EditorPatches::SkipClubFavItemUpdate_IsApplied = false;
#elif DEPENDENCY_EDITOR
    Editor::NextEditorLoad_EnableInventoryPatch(Editor::InvPatchType::SkipClubUpdateCheck);
    EditMapFrom(S_LastMapFileName);
#else
    EditMapFrom(S_LastMapFileName);
#endif
}

void Run_UploadLastEditedMap() {
    if (S_LastMapFileName == "") {
        NotifyError("No map has been edited yet");
        return;
    }
    UploadMap(S_LastMapFileName);
}

void Run_OpenFolderLastEditedMap() {
    if (S_LastMapFileName == "") {
        NotifyError("No map has been edited yet");
        return;
    }
    OpenExplorerPath(Path::GetDirectoryName(S_LastMapFileName));
}

void Run_PlayLastEditedMap() {
    if (S_LastMapFileName == "") {
        NotifyError("No map has been edited yet");
        return;
    }
    PlayMap(S_LastMapFileName);
}


void Run_JoinTOTD() {
    if (!Permissions::PlayTOTDChannel()) {
        NotifyError("You don't have permission to join TOTD");
        return;
    }
    string jl;
    try {
        jl = GetTotdJoinLink();
    } catch {
        PrintActiveContextStack();
        auto e = getExceptionInfo();
        NotifyError("Failed to get TOTD JoinLink: " + e);
        return;
    }
    NotifySuccess("Joining TOTD Server...");
    JoinServer(jl);
}
