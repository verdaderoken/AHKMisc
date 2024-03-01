/*
    Extended library for Hotkeys.

    (c) 2022-2024 Ken Verdadero
    2022-11-11
*/

/**
 * Sets a hotkey with an optional HotIf
 * @param keyName the hotkey to set
 * @param callback the function to call when the hotkey is pressed
 * @param {String} options
 * @param {String} hotIf the HotIf to use
 * @param {String} hotIfValue the value to use for the HotIf
 */
HotkeySet(keyName, callback, options := '', hotIf := '', hotIfValue := '') {
    if !StrLen(hotIf) {
        Hotkey(keyName, callback, options)
        return
    }
    switch StrLower(hotIf) {
        case "a": HotIfWinactive(hotIfValue)
        case "na": HotIfWinNotactive(hotIfValue)
        case "x": HotIfWinExist(hotIfValue)
        case "nx": HotIfWinNotExist(hotIfValue)
    }
    Hotkey(keyName, callback, options)
    switch StrLower(hotIf) {
        case "a": HotIfWinactive('')
        case "na": HotIfWinNotactive('')
        case "x": HotIfWinExist('')
        case "nx": HotIfWinNotExist('')
    }
    return
}