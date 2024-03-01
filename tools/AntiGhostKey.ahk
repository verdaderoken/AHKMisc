/*
    AntiGhostKey
    Eliminates any ghost keypress after executed by sending a backspace.

    This is a simple workaround to prevent ghost keypresses
    when a user double-clicks a key.

    Disclaimer:
        - This is only a pseudo-ghost key prevention.

    - User can still use the press-hold key to spam keypresses.
    - Ghost keys are automatically prevented when
        interval between recent keypress is below the threshold.
    - All units are measured in milliseconds.
    - Debug data can be enabled by using AntiGhostKey.SetDebug(1).

    - Typical duration of a double press ranges from 250 to 300 ms.
    - A ghost key is below 90 ms.
    - Tracking can go as low as 13 ms.
    - Uses A_TickCount for millisecond precision

    Interval can be modified:
        - The higher the number, the higher the chance it will be truncated.

    Max Record can be modified:
        - The higher the number, the longer it takes to detect
            a spam keypress or detecting a press-hold situation.

    (c) 2022-2024 Ken Verdadero

    Written 2022-05-17
    Rev 1. 2022-05-30
*/

#Include ../lib/Basic.ahk
#Include ../lib/Format.ahk
#Include ../lib/Keys.ahk
#Include ../lib/Path.ahk
#SingleInstance Force

class AntiGhostKey {
    static DEF_INTERVAL := 90
    static DEF_MAX_RECORD := 3
    static FILE_LOG := PathJoin(A_Temp, "ghostkeys.log")

    __New(key, interval, maxRecord, debug, logging) {
        this.TICK := A_TickCount
        this.RECORD := []
        this.INTERVAL := interval
        this.MAX_RECORD := maxRecord
        this.DEBUG := debug
        this.LOGGING := logging
        this.KEYNAME := TrimPassthrough(key)                                                ;; Trim "~" pass through if present
    }

    /**
     * Connects a single new key to a hotkey.
     * This will create a new object instance of a class to have separate tracking.
     * It also returns the instance of the newly connected key.
     * @param key the key to connect
     * @param {Integer} interval number of milliseconds to wait before detecting a double keypress
     * @param {Integer} maxRecord how many records to keep
     * @param {Integer} debug true to enable debug, false to disable
     * @param {Integer} logging true to enable logging, false to disable
     * @returns {AntiGhostKey} the instance of the newly connected key.
     */
    static Connect(key, interval := 0, maxRecord := 0, debug := false, logging := false) {
        _OBJ := AntiGhostKey(
            key,
            (!interval ? AntiGhostKey.DEF_INTERVAL : interval),
            (!maxRecord ? AntiGhostKey.DEF_MAX_RECORD : maxRecord),
            debug,
            logging
        )

        try Hotkey("~" _OBJ.KEYNAME, ObjBindMethod(_OBJ, "DetectDouble"))                   ;; Bind the key to its hotkey.
        catch Error as e {
            ToolTipX("Error binding `"" _OBJ.KEYNAME "`"")
        }
        return _OBJ                                                                         ;; Return back the object instance.
    }

    /**
     * Connects all keys to a hotkey.
     * This method returns a Map of object instances instead of a single instance.
     * @param {Integer} interval number of milliseconds to wait before detecting a double keypress
     * @param {Integer} maxRecord how many records to keep
     * @param {Integer} debug true to enable debug, false to disable
     * @param {Integer} logging true to enable logging, false to disable
     * @returns {Object} a map of object instances of the newly connected keys.
     */
    static ConnectAll(interval := 0, maxRecord := 0, debug := false, logging := false) {
        _AGK := Object()                                                                    ;; Object instance map.
        for key in ArrayMerge(Keys.LettersUpper,                                            ;; Iterate through a large array of keys.
            Keys.Numbers,
            Keys.NumpadOn,
            Keys.Symbols,
            Keys.Spaces,
            "Del",
        ) {
            _AGK.DefineProp(key,                                                            ;; Defining properties for some keys may fail (due to syntax limitations).
                {
                    value: AntiGhostKey.Connect(key, interval,
                        maxRecord, debug, logging)
                }                     ;; Forward to Connect method along with arguments.
            )
        }
        return _AGK
    }

    /**
     * Disconnects a single key from the hotkey binding.
     */
    Disconnect() {
        Hotkey("~" this.KEYNAME, ObjBindMethod(this, "DetectDouble"), "Off")
    }

    /**
     * Detects a double keypress and sends a backspace.
     * This method is called by the hotkey binding and should not be called directly.
     * 
     * @param Hk the hotkey
     */
    DetectDouble(Hk) {
        DIFF := A_TickCount - this.TICK                                                       ;; Record the difference between last keypress of a key.
        this.RECORD.Push(DIFF)                                                              ;; Push new difference value to the records.

        THR_RECORD := Round((this.INTERVAL * (this.RECORD.Length + 2)))                       ;; Calculate the record threshold for "spam" indication.
        DIFF_RATIO := Round((Abs(this.INTERVAL - DIFF) / this.INTERVAL), 2)                     ;; Threshold-to-Diff ratio (in percent).
        isSpamming := (ArraySum(this.RECORD) < THR_RECORD ? 1 : 0)                            ;; Spam indicator.

        (this.RECORD.Length > this.MAX_RECORD ? this.RECORD.RemoveAt(1) : 0)                  ;; First index will be released if the record is full.

        if this.DEBUG {                                                                     ;; Displays the debug data only if DEBUG prop is enabled.
            try {
                ToolRep(
                    "Tracked key: " this.KEYNAME,
                    "Recorded Diffs: " ArrayAsStr(this.RECORD, , , , "ms", true),
                    "Record Threshold: " THR_RECORD " ms",
                    Format("Sum of Records: {1} ms | Spam: {2}",
                        FmtNum(ArraySum(this.RECORD)),
                        (isSpamming ? "Yes" : "No")),
                    "Interval: " this.INTERVAL " ms",
                    "Difference (" this.KEYNAME " key): " DIFF " ms | "
                    DIFF_RATIO "%",
                )
            } catch Error as e {
                ToolRep("Exception occured: " e.Message)
            }
        }

        if DIFF < this.INTERVAL && !isSpamming {                                            ;; Only send a backspace when the user double—
            Send("{BackSpace}")                                                             ;; clicks once and not press-holding the key.
            (this.DEBUG ? ToolRep("Double keypress detected for " this.KEYNAME) : 0)
            if this.LOGGING {
                try {
                    FileAppend(
                        Format("`n{1} - [Key: {2}] ({3} ms) - {4} ({5}%)",
                            A_Now,
                            this.KEYNAME,
                            DIFF,
                            ArrayAsStr(this.RECORD, , , , "ms", true),
                            DIFF_RATIO
                        ),
                        AntiGhostKey.FILE_LOG
                    )
                }
            }
        }

        this.TICK := A_TickCount                                                            ;; Updates tick value with current time.
    }

    /**
     * Sets the debug state of a single key.
     * @param {Number} state the state to set
     */
    SetDebug(state := -1) {                                                                   ;; Sets the debug state of a single key.
        this.DEBUG := (state < 0 ? (!this.DEBUG ? 1 : 0) : state)                                 ;; When arg is omitted, toggle between last state.
    }

    /**
     * Sets the logging state of a single key.
     * @param {Number} state the state to set
     */
    SetLogging(state := -1) {
        this.LOGGING := (state < 0 ? (!this.LOGGING ? 1 : 0) : state)
    }
}