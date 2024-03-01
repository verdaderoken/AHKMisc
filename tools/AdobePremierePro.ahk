/*
    -------------------------------
    Adobe Premiere Pro AHK Wrapper
    -------------------------------

    A basic wrapper for Adobe Premiere Pro using AutoHotkey 2.
    This class provides a set of methods to interact with Adobe Premiere Pro.

    (c) 2024 Ken Verdadero
    2022-06-02
*/

#Requires AutoHotkey v2.0
#Include ../lib/Path.ahk
#Include ../lib/Strings.ahk

class AdobePr {
    static AHK_EXE := "ahk_exe Adobe Premiere Pro.exe"
    static AHK_CLASS := "ahk_class Premiere Pro"
    static AHK_MODAL := "ahk_exe Adobe Premiere Pro.exe ahk_class #32770"
    static DIR_PRPROJ := ".prproj"

    static CACHED_TITLE := ''                                                               ;; Useful for storing title in this variable because modal windows would cause an issue

    /*  Error Types */
    static ErrAbsent(extra) => Error("Premiere is not opened", , extra)
    static ErrNoProject(extra) => Error("There is no project opened", , extra)

    /**
     * Activates Adobe Premiere Pro window
     */
    static Activate() {
        (AdobePr.isOpened() ? WinActivate(AdobePr.AHK_EXE) : 0)
    }

    /**
     * Returns true if the project is currently opened.
     * @returns {Integer} 
     */
    static IsProjectOpened() {
        if WinExist(AdobePr.AHK_EXE) {
            try {
                title := WinGetTitle(AdobePr.AHK_EXE)
                if !StrLen(title) && !AdobePr.IsOnContextMenu() {
                    AdobePr.CACHED_TITLE := ''
                    return 0
                }
                result := (InStr(title, AdobePr.DIR_PRPROJ) ? 1 : 0)
                if !result {                                                                 ;; if a '.prproj' extension is NOT present in title bar, don't update the cached title
                    return (InStr(AdobePr.CACHED_TITLE, AdobePr.DIR_PRPROJ) ? 1 : 0)
                }
                AdobePr.CACHED_TITLE := title
                return result
            }
        }
        return 0
    }

    /**
     * Returns true if the project is currently rendering.
     * @returns {Integer} 
     */
    static IsRendering() {
        try title := WinGetTitle(AdobePr.AHK_EXE)
        catch Error {
            return 0
        }
        if AdobePr.IsOnModal() &&
            (InStr(title, "Rendering : ") ||
                InStr(title, "Rendering Required Audio Files") ||
                InStr(title, "Render and Replace")
            ) {
                return 1
        }
        return 0
    }

    /**
     * Returns true if the project is currently encoding.
     * @returns {Integer} 
     */
    static IsEncoding() {
        try title := WinGetTitle(AdobePr.AHK_EXE)
        catch Error {
            return 0
        }
        if AdobePr.IsOnModal() && InStr(title, "Encoding ") {
            return 1
        }
        return 0
    }

    /**
     * Returns true if the project is currently saving.
     */
    static IsSaving() {
        return (AdobePr.IsOnModal() && InStr(WinGetTitle(AdobePr.AHK_EXE), "Save Project", 1) ? 1 : 0)
    }

    /**
     * Returns the title of Adobe Premiere Pro window
     * @returns {String} the title
     */
    static GetTitle() {
        if !AdobePr.IsOpened() {
            return ''
        }
        try {
            return WinGetTitle(AdobePr.AHK_EXE)
        }
        catch Error {
            return ''
        }
    }

    /**
     * Retrieves information about the current project using the title bar.
     * @returns {Object} Returns a metadata/object of the current project
     */
    static GetCurrentProject() {
        placeholder := {
            filename: '',
            name: '',
            ext: '',
            dir: '',
            drive: '',
            path: '',
            saved: ''
        }
        if AdobePr.IsOnModal() || AdobePr.IsOnContextMenu() || !AdobePr.IsProjectOpened() {
            return placeholder
        }
        try {
            title := StrReplace(AdobePr.GetTitle(), '*', '')
            filename := StrSplit(title, '\')[-1]
            ext := '.' StrSplit(title, '.')[-1]
            path := Trim(Join(ArrayTrunc(StrSplit(title, ' '), 6), ' '))

            out := {
                filename: filename,
                name: RegExReplace(filename, ext '$'),
                ext: ext,
                dir: PathSplit(path)[1],
                drive: StrSplit(StrSplit(title, '\')[1], ' ')[-1] '\',
                path: path,
                saved: (StrSplit(AdobePr.GetTitle())[-1] != '*'),
            }
            return out
        } catch Error {
            return placeholder
        }
    }

    /**
     * Gets the current position of Adobe Premiere Pro window
     * @returns {Array} [X, Y, W, H]
     */
    static GetCurrentPos() {
        try {
            if AdobePr.IsOpened() {
                WinGetPos(&X, &Y, &W, &H, AdobePr.AHK_CLASS)
                return [X, Y, W, H]
            }
            throw AdobePr.ErrAbsent("GetCurrentPos")
        } catch Error {
            return [0, 0, 0, 0]
        }
    }

    static IsSaved() => AdobePr.GetCurrentProject().saved
    static IsOnContextMenu() => (WinExist("ahk_class #32768") && AdobePr.IsOpened() ? 1 : 0)
    static IsOnModal() => (WinExist("ahk_class #32770") && AdobePr.IsOpened() ? 1 : 0)
    static IsOnModalActive() => (WinExist("ahk_class #32770") && AdobePr.IsActive() ? 1 : 0)      ;; Probable fix for modal conflicts
    static IsOnPopupWindow() => (WinExist("ahk_class DroverLord - Window Class") && AdobePr.IsOpened() ? 1 : 0)
    static IsLaunching() => (AdobePr.IsOnModal() && !StrLen(AdobePr.GetTitle()) ? 1 : 0)
    static IsOpened() => (WinExist(AdobePr.AHK_EXE) ? 1 : 0)
    static IsActive() => (WinActive(AdobePr.AHK_EXE) ? 1 : 0)
    static IsOnExportSettings() => (AdobePr.IsOnModal() && AdobePr.GetTitle() == "Export Settings" ? 1 : 0)
    static IsOnQuickExportSettings() => (AdobePr.IsOnPopupWindow() && AdobePr.GetTitle() == "OS_PopupWindow" ? 1 : 0)

    /**
     * Checks if Adobe Premiere Pro is idle and not doing anything.
     */
    static IsReady() =>
        (AdobePr.IsOpened() && !AdobePr.IsLaunching() &&
            !AdobePr.IsOnModal() && !AdobePr.IsOnContextMenu() ? 1 : 0)


    /**
     * Checks if a balloon popup is present in Adobe Premiere Pro
     */
    static HasBalloonPopup(popupType := 0) {
        switch popupType {
            case 0: color := 0x87BEFF                                                       ;; Notice Message
        }
        if !AdobePr.IsOpened() {
            return
        }
        WinGetPos(&X, &Y, &W, &H, AdobePr.AHK_CLASS)
        x := W - (W * 0.1)
        y := H - (H * 0.1)
        return PixelGetColor(x, y) == color
    }


    /**
     * Focuses a control in Adobe Premiere Pro
     */
    static GetControlFocused() {
        try return ControlGetClassNN(ControlGetFocus(AdobePr.AHK_EXE))
        catch Error {
            return 0
        }
    }

    /**
     *   Adapted from @TaranVH 's `prFocus()` function
     *   (https://github.com/TaranVH/2nd-keyboard/blob/b0687fe9eaa6d1d33f8e22913b70940c8d78ed0a/Almost_All_Premiere_Functions.ahk#L657)
     * 
     *   Focuses to a certain panel.
     *   * Note: This only works for default keybindings in activating panel.
     * 
     *   List of panels:
     * 
     *       Shift + 1   - Project Panel
     *       Shift + 2   - Source Panel
     *       Shift + 3   - Timeline Panel
     *       Shift + 4   - Program Panel
     *       Shift + 5   - Effect Controls Panel
     *       Shift + 7   - Effects Panel
     *       Shift + 8   - Media Browser Panel
     *       Shift + 9   - Audio Clip Mixer Panel
     */
    static PanelFocus(panelName) {
        if (Type(panelName) != "String") {
            throw TypeError("Expected String type, got " Type(panelName), , panelName)
        }
        if !AdobePr.IsOpened() {
            throw AdobePr.ErrAbsent(A_ThisFunc)
        }
        if !AdobePr.IsProjectOpened() {
            throw AdobePr.ErrNoProject(A_ThisFunc)
        }
        switch StrLower(panelName) {
            case 'project': Send("+1")
            case 'source': Send("+2")
            case 'timeline': Send("+3")
            case 'program': Send("+4")
            case 'effectcontrols': Send("+5")
                ; case 'effects': Send("+7")                                                    ;; ! This causes to send '&' and idk why
            case 'mediabrowser': Send("+8")
            case 'audioclipmixer': Send("+9")
        }
    }
}