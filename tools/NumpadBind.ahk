/*
	Numpad Binder for TKL keyboards
	--------------------------------
    Allows the user to input alt codes for TKL using CapsLock as switch.

    This makes it easier to type alt codes without the need to use the numpad.
    as TKL keyboards do not have a numpad.

    Usage:
        1. Press CapsLock to toggle the number row as numpad.
        2. Type the sequence of alt-code (ex: ™ — Alt+0153)
        3. Press CapsLock again to release the command
        4. The output alt-code will be represented

    Known Limitations:
        - When CapsLock is triggered, you cannot use Backspace to remove a character.
        The CapsLock must be toggled again. This is due to Backspace is reserved for
        removing sequence number when typing an Alt-Code

	(c) 2022-2024 Ken Verdadero
	Rev 1. 2022-05-31
*/

#SingleInstance Force
NumpadBind.Setup()

class NumpadBind {
    static MODE := (GetKeyState("CapsLock", "T") ? 0 : 1)
    static RECORD := []

    /**
     * Setup the hotkeys for the numpad bind
     */
    static Setup() {
        Loop 26 {
            Hotkey("~" Chr(96 + A_index), ObjBindMethod(NumpadBind, "AnyKey"))
        }
        NumpadBind._Init()
    }

    /**
     * Initialize the hotkey binds for the numpad bind
     */
    static _Init() {
        Hotkey("~CapsLock",
            ObjBindMethod(NumpadBind, "ToggleAlt"))
        Hotkey("BackSpace",
            ObjBindMethod(NumpadBind, "ReduceRecord"),
            (NumpadBind.MODE ? "On" : "Off"))
        Loop 10 {
            key := A_Index - 1
            Hotkey(key,
                ObjBindMethod(NumpadBind, "SendNumber", key),
                (NumpadBind.MODE ? "On" : "Off"))
        }
    }

    /**
     * Toggle the numpad bind mode
     * @param args 
     */
    static ToggleAlt(args*) {
        if NumpadBind.MODE && NumpadBind.RECORD.Length {                                    ;; Confirm key sequence/alt code
            CMD := "{Alt Down}"
            for k in NumpadBind.RECORD {
                CMD .= "{Numpad" k "}"
            }
            CMD .= "{Alt Up}"
            Send(CMD)
            NumpadBind.RECORD := []
            NumpadBind.MODE := 0
            NumpadBind._Init()
            Send("{CapsLock}")
        } else {                                                                            ;; Enable numpad bind mode
            NumpadBind.RECORD := []
            NumpadBind.MODE := 1
            NumpadBind._Init()
        }
        NumpadBind.MODE := (GetKeyState("CapsLock", "T") ? 0 : 1)
    }

    /**
     * Sends the actual number from the numpad
     * @param key 
     */
    static SendNumber(key*) {                                                               ;; Record the actual number represented by a number from numpad
        NumpadBind.MODE := 1
        NumpadBind.RECORD.Push(key[1])
    }

    static AnyKey(Hk) {
        NumpadBind.MODE := 0
        NumpadBind._Init()
    }

    /**
     * Remove the last character from the sequence
     * @param args 
     */
    static ReduceRecord(args*) {
        if !NumpadBind.MODE && !NumpadBind.RECORD.Length
            return
        try NumpadBind.RECORD.RemoveAt(-1)
    }
}