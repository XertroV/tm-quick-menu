#if DEPENDENCY_MAP_TOGETHER
[Setting hidden]
MapBase S_NewMapBase = MapBase::Stadium155;

[Setting hidden]
MapMood S_NewMapMood = MapMood::Day;

// Starting a map with a diff car works, but if the appropriate car transform block/item is not on the map, play mode crashes the game.
// [Setting hidden]
MapCar S_NewMapCar = MapCar::CarSport;

[Setting hidden]
nat3 S_NewMapSize = nat3(48, 255, 48);

const int N_255_Sq = 255*255;

void Draw_MapDefaultsSettings() {
    UI::PushItemWidth(130);
    S_NewMapBase = DrawComboMapBase("Base", S_NewMapBase);
    S_NewMapMood = DrawComboMapMood("Mood", S_NewMapMood);
    // S_NewMapCar = DrawComboMapCar("Car", S_NewMapCar);
    auto origSize = S_NewMapSize;
    S_NewMapSize.x = UI::SliderInt("Size.X", S_NewMapSize.x, 8, 1024, "%d", UI::SliderFlags::AlwaysClamp);
    S_NewMapSize.y = UI::SliderInt("Size.Y", S_NewMapSize.y, 48, 255, "%d", UI::SliderFlags::AlwaysClamp);
    S_NewMapSize.z = UI::SliderInt("Size.Z", S_NewMapSize.z, 8, 1024, "%d", UI::SliderFlags::AlwaysClamp);
    if (S_NewMapSize.x * S_NewMapSize.z > N_255_Sq) {
        if (origSize.x != S_NewMapSize.x) {
                S_NewMapSize.z = N_255_Sq / S_NewMapSize.x;
        } else {
            S_NewMapSize.x = N_255_Sq / S_NewMapSize.z;
        }
    }
    UI::PopItemWidth();
}

funcdef string EnumToStringF(int);
int DrawArbitraryEnum(const string &in label, int val, int nbVals, EnumToStringF@ eToStr) {
    if (UI::BeginCombo(label, eToStr(val))) {
        for (int i = 0; i < nbVals; i++) {
            if (UI::Selectable(eToStr(i), val == i)) {
                val = i;
            }
        }
        UI::EndCombo();
    }
    return val;
}

MapBase DrawComboMapBase(const string &in label, MapBase val) {
    if (UI::BeginCombo(label, tostring(val))) {
        if (UI::Selectable(tostring(MapBase::Stadium155), val == MapBase::Stadium155)) val = MapBase::Stadium155;
        if (UI::Selectable(tostring(MapBase::NoStadium), val == MapBase::NoStadium)) val = MapBase::NoStadium;
        if (UI::Selectable(tostring(MapBase::StadiumOld), val == MapBase::StadiumOld)) val = MapBase::StadiumOld;
        UI::EndCombo();
    }
    return val;
}

MapMood DrawComboMapMood(const string &in label, MapMood val) {
    return MapMood(
        DrawArbitraryEnum(label, int(val), 4, function(int v) {
            return tostring(MapMood(v));
        })
    );
}

MapCar DrawComboMapCar(const string &in label, MapCar val) {
    return MapCar(
        DrawArbitraryEnum(label, int(val), 4, function(int v) {
            return tostring(MapCar(v));
        })
    );
}
#else
void Draw_MapDefaultsSettings() {
    // do nothing
}
#endif
