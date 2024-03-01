/*
    Extended library for Window Object

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

/**
 * A simple wrapper for Window-related functions
 */
class Window {
    /**
     * Returns the active window title
     * @returns {String|Integer} The title of the active window or 0 if no window is active
     */
    static GetActiveWindow() {
        try {
            return WinGetTitle("A")
        } catch Error {
            return 0
        }
    }

    static GetCurrentMonitor(WinTitle := '') {
        /*
            Retrieves the index of the current monitor the window is in
            If WinTitle is omitted, the current mouse position will be considered.
        */
        if StrLen(WinTitle) {
            try {
                WinGetPos(&WX, &WY, &WW, &WH, WinTitle)
                WCX := WX + (WW / 2)                                                            ;; Get Window Center Coords
                WCY := WY + (WH / 2)
            } catch Error {
                throw Error("Window `"" WinTitle "`" does not exist.")
            }
        } else {
            MouseGetPos(&X, &Y)
            WCX := X
            WCY := Y
        }

        Loop MonitorGetCount() {
            MonitorGet(A_Index, &L, &T, &R, &B)
            if (WCX > L and WCX < R and WCY < B and WCY > T) {
                return A_Index
            }
        }
        return 0
    }

    /**
     * Sends the window to a specific monitor index
     * @param {String} Index the monitor index to send the window to
     * @param {String} WindowTitle the title of the window to send
     */
    static SendToMonitor(Index := "", WindowTitle := "") {
        WT := (WindowTitle == "" ? this.getActiveWindow() : WindowTitle)
        RETRIES := 0

        ;; Make sure the window exists
        if not WinExist(WT) {
            throw Error("Window `"" WT "`" does not exist.")
        }

        Index := (Index == "" ? (this.getCurrentMonitor(WT) + 1 > MonitorGetCount() ? 1 : this.getCurrentMonitor(WT) + 1) : Index)

        ;; Verify that the index is a number
        if (IsInteger(Index) == 0) {
            throw Error("Index monitor is not a number.")
        }
        if (Index > MonitorGetCount() or Index <= 0) {
            throw Error("Index monitor is out of range.")
        }

        Loop {
            WinActivate(WT)
            Sleep(50)
            if (this.getCurrentMonitor(WT) == Index) {
                break
            }
            else If (RETRIES >= MonitorGetCount()) {
                break
            }
            else {
                Send("{LWin Down} {LShift Down} {Right} {LWin Up} {LShift Up}"), RETRIES++
            }
        }
    }
}