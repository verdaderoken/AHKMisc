/*
    Extended library for Keys

    (c) 2022-2024 Ken Verdadero
    2022-05-30
*/

#Include ./Arrays.ahk
#Include ./Set.ahk

/**
 * Lists of keys and key groups
 * 
 */
class Keys {
    static Modifiers := [
        "LShift", "LCtrl", "LAlt", "LWin",
        "RShift", "RCtrl", "RAlt", "RWin"
    ]
    static Toggles := [
        "CapsLock", "ScrollLock", "NumLock"
    ]
    static Functions := ArrayRange(1, 12, "F")
    static NumpadNum := ArrayRange(1, 9, "Numpad")
    static NumpadOn := ArrayMerge(                                                          ;; Numpad states as if NumLock is ON
        ArrayRange(0, 9, "Numpad"),
        ["NumpadDiv", "NumpadMult", "NumpadSub",
            "NumpadAdd", "NumpadEnter", "NumpadDot"]
    )
    static NumpadOff := [                                                                   ;; Numpad states as if NumLock is OFF
        "NumpadIns", "NumpadEnd", "NumpadDown", "NumpadPgdn",
        "NumpadLeft", "NumpadRight", "NumpadHome",
        "NumpadUp", "NumpadPgup", "NumpadDiv", "NumpadMult",
        "NumpadSub", "NumpadAdd", "NumpadEnter", "NumpadDel"
    ]
    static LettersLower := Keys._Letters()
    static LettersUpper := Keys._Letters(true)
    static Letters := ArrayMerge(Keys.LettersLower, Keys.LettersUpper)
    static Numbers := ArrayRange(0, 9)
    static UpperSymbols := Set("~!@#$%^&*()_+<>?:`"{}|%")                                   ;; Upper symbols as if Shift is being held down
    static LowerSymbols := Set("``,./;'[]]\-=")                                             ;; Lower symbols as if Shift is not held down
    static Symbols := ArrayMerge(Keys.UpperSymbols, Keys.LowerSymbols)
    static Specials := ["Ins", "Del", "Home", "End", "PgUp", "PgDn"]
    static Arrows := ["Left", "Up", "Down", "Right"]
    static Spaces := "Space"

    static AllKeys := ArrayMerge(
        Keys.Letters,
        Keys.Numbers,
        Keys.Symbols,
        Keys.Arrows,
        Keys.Functions,
        Keys.Toggles,
    )

    static _Letters(uppercase := false) {
        o := []
        loop 26 {
            o.Push(uppercase ? StrUpper(Chr(96 + A_index)) : (Chr(96 + A_index)))
        }
        return o
    }
}