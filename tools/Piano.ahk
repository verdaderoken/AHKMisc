/*
	Piano Player for AutoHotkey
	---------------------------

	Allows the user to play a piano by using keyboard as notes
	and binds hotkey for every note.

	This can be used to produce a specific Windows beep tone
    by modifying the frequency of the note.

	When keymap is enabled, the user can play the keyboard using
	the keys across Z to / (lower) and Q to ] (upper)

		LShift	- change octave higher (for lower)
		LCtrl	- change octave lower (for lower)
		RShift	- change octave higher (for higher)
		RCtrl	- change octave lower (for higher)

	For demo, use `Piano.PlayRandom()` to play random notes.

    This is a proof of concept and not intended for serious use. (or is it?)

	(c) 2022-2024 Ken Verdadero

    @version 1.0.0
    @author Ken Verdadero
*/

#Requires AutoHotkey v2.0
#SingleInstance Force

;; Default object (ready to use when imported)
Piano := _Piano()
; Piano.SetEnableKeymap(1) <-- Uncomment to enable keymap

/**
 * Piano class
 */
class _Piano {
    ;; Name of the notes (17)
    ;; Sharps and Flats are separated but has the same value
    static _NOTES := [
        "C", "Cs", "Db", "D", "Ds", "Eb", "E", "F",
        "Fs", "Gb", "G", "Gs", "Ab", "A", "As", "Bb", "B"
    ]
    ;; Map of notes as key in physical keyboard
    static KBDMAP := [
        ["~Z", "~S", "~S", "~X", "~D", "~D", "~C", "~V",
            "~G", "~G", "~B", "~H", "~H", "~N", "~J", "~J",
            "~M", "~,", "~L", "~L", "~.", "~;", "~;", "~/"
        ],
        ["~Q", "~2", "~2", "~W", "~3", "~3", "~E", "~R",
            "~5", "~5", "~T", "~6", "~6", "~Y", "~7", "~7",
            "~U", "~I", "~9", "~9", "~O", "~0", "~0", "~P",
            "~[", "~=", "~=", "~]"
        ]
    ]

    __New(Keymap := 0, lowerOct := 3, upperOct := 4, defaultDuration := 170) {
        this.OCTS := [lowerOct, upperOct]
        this.STATE_KEYMAP := Keymap
        this.DEF_DURATION := defaultDuration
        this._GenerateToneMap()
        this.SetOctave(lowerOct, upperOct)
    }

    /**
     * Generates a map of every note and its specific frequency.
     * Notes ranges from A0 to B8 including sharps and flats
     * 
     * Tone mapping is measured in Hertz at A4 (440Hz)
     * Data from https://web.archive.org/web/20240208225516/https://pages.mtu.edu/~suits/notefreqs.html
     */
    _GenerateToneMap() {
        TONES := Map()
        _TONES := [
            16.35, 17.32, 17.32, 18.35, 19.45, 19.45,
            20.60, 21.83, 23.12, 23.12, 24.50, 25.96,
            25.96, 27.50, 29.14, 29.14, 30.87
        ]

        ;; Loop 9 [octaves] (to include octave 0)
        ;; var 'oct' Represents an octave, -1 to start with octave 0
        loop 9 {
            oct := A_Index - 1
            for i, tone in _TONES {
                loop oct {
                    ;; Frequency of multiplication by octaves
                    ;; Double the value
                    tone *= 2
                }
                TONES.Set(_Piano._NOTES[i] oct, Round(tone, 2))
            }
        }

        for k, v in TONES {
            ;; Apply note properties to the object instance
            this.DefineProp(k, { Call: ObjBindMethod(this, "_Play", v) })
        }
    }


    /**
     * Executes the note as beep
     * @param hz - Frequency of the note
     * @param args - Arguments passed from the note
     */
    _Play(hz, args*) {
        ;; Perform the requested noted as beep
        try SoundBeep(hz, (args[-1] != -1
            and !InStr("Piano String", Type(args[-1])) ?
            args[-1] : this.DEF_DURATION)
        )
    }


    /**
     * Sets the octave for the keymap.
     * There are lower and upper octave and both octaves can be set between range of 0-8.
     * @param {number} lowerOct 
     * @param {number} upperOct 
     */
    SetOctave(lowerOct := 3, upperOct := 4) {
        for i in _Piano.KBDMAP {
            ;; Determine the target octave from KBDMAP
            Oct := (A_Index > 1 ? upperOct : lowerOct)

            ;; Loop through keys in keyboard octave index
            for k in _Piano.KBDMAP[A_Index] {
                try {
                    ;; Bind notes into hotkey map
                    Hotkey(k, ObjBindMethod(this,
                        _Piano._NOTES[A_Index] Oct),
                        (this.STATE_KEYMAP ? "On" : "Off")
                    )
                } catch Error {
                    ;; Overflowing notes are considered in upper octave
                    Hotkey(k, ObjBindMethod(this,
                        _Piano._NOTES[A_Index - 17] Oct + 1),
                        (this.STATE_KEYMAP ? "On" : "Off")
                    )
                }
            }
        }

        ;; Bind controls for changing octaves
        Hotkey("~LShift", ObjBindMethod(this, "_UpOctave", (this.STATE_KEYMAP ? "On" : "Off"), 1))
        Hotkey("~LCtrl", ObjBindMethod(this, "_DownOctave", (this.STATE_KEYMAP ? "On" : "Off"), 1))
        Hotkey("~RShift", ObjBindMethod(this, "_UpOctave", (this.STATE_KEYMAP ? "On" : "Off"), 2))
        Hotkey("~RCtrl", ObjBindMethod(this, "_DownOctave", (this.STATE_KEYMAP ? "On" : "Off"), 2))
        this.OCTS := [lowerOct, upperOct]
    }

    /**
     * Sets or toggles the keymap hotkeys for piano
     * 
     * @param {number} state
     * 	0 - Keymaps are disabled
     * 	1 - Keymaps are enabled
     * 
     * When state is omitted, the opposite of current
     * state will apply.
     */
    SetEnableKeymap(state := -1) {
        if !IsNumber(state)
            throw Error("Not an valid state. Only 0 or 1 is acceptable")
        this.STATE_KEYMAP := (state < 0 ? (!this.STATE_KEYMAP ? 1 : 0) : state)
        this.SetOctave(this.OCTS[1], this.OCTS[2])
    }

    /**
     * Returns the current state of keymap
     * @returns {number} 0 or 1
     */
    IsKeymapEnabled() => this.STATE_KEYMAP

    /**
     * Changes the default duration of the note
     * @param duration - Default duration of the note
     */
    SetDefaultDuration(duration) {
        if !IsDigit(String(duration))
            throw Error("Not a valid unsigned number")
        this.DEF_DURATION := duration
    }

    /**
     * Returns the current default duration of the note
     * @returns {number} Default duration of the note
     */
    _UpOctave(a*) {
        this.SetOctave(this.OCTS[1] + (a[-2] == 1 ? 1 : 0),
            this.OCTS[2] + (a[-2] == 2 ? 1 : 0))
    }

    /**
     * Returns the current default duration of the note
     * @param a - Arguments passed from the note
     */
    _DownOctave(a*) {
        this.SetOctave(this.OCTS[1] - (a[-2] == 1 ? 1 : 0),
            this.OCTS[2] - (a[-2] == 2 ? 1 : 0))
    }

    /**
     * Plays a random note
     * @param loops - Number of loops to play
     */
    PlayRandom(loops := 30, durationRange := [100, 1000]) {
        Loop loops {
            ObjBindMethod(Piano, _Piano._NOTES[Random(1, _Piano._NOTES.Length)]
                Random(3, 6))(Random(durationRange[1], durationRange[2]))
        }
    }
}