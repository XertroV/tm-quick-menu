void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifySuccess(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg, vec4(.4, .7, .1, .3), 10000);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}

void Dev_NotifyWarning(const string &in msg) {
#if DEV
    warn(msg);
    UI::ShowNotification("Dev: Warning", msg, vec4(.9, .6, .2, .3), 15000);
#endif
}

void AddSimpleTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::SetNextWindowSize(400, 0, UI::Cond::Appearing);
        UI::BeginTooltip();
        UI::TextWrapped(msg);
        UI::EndTooltip();
    }
}

void AddMarkdownTooltip(const string &in msg) {
    if (UI::IsItemHovered()) {
        UI::SetNextWindowSize(400, 0, UI::Cond::Appearing);
        UI::BeginTooltip();
        UI::Markdown(msg);
        UI::EndTooltip();
    }
}

namespace UX {
    // call this before you end the popup
    void CloseCurrentPopupIfMouseFarAway(bool closeAnyway = false) {
        auto wPos = UI::GetWindowPos();
        auto wSize = UI::GetWindowSize();
        auto showBoundsRect = vec4(wPos + vec2(-50), wSize + vec2(100));

        closeAnyway = closeAnyway || !MathX::Within(UI::GetMousePos(), showBoundsRect);
        // trace(UI::GetMousePos().ToString() + " " + showBoundsRect.ToString());
        if (closeAnyway) UI::CloseCurrentPopup();
    }
}

namespace MathX {
    bool Within(vec2 &in pos, vec4 &in rect) {
        return pos.x >= rect.x && pos.x < (rect.x + rect.z)
            && pos.y >= rect.y && pos.y < (rect.y + rect.w);
    }
}
