/*
    Extended library for Formatting

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

#Include ./Arrays.ahk

/**
 * Formats a number with a separator.
 * @param x Number to be formatted
 * @param {String} s Separator (Default: ",")
 * @param {Integer} places Number of places to add separator (Default: 3)
 * @returns {String} Formatted number
 */
FmtNum(x, s := ",", places := 3) {
    return RegExReplace(x, "\G\d+?(?=(\d{" places "})+(?:\D|$))", "$0" s)
}

/**
 * Trims the pass through key if present.
 * @param key Key to be trimmed
 * @returns {String} Trimmed key
 */
TrimPassthrough(key) {
    return (SubStr(key, 1, 1) == "~" && StrLen(key) > 1 ? SubStr(key, 2) : key)
}

/**
 * Fills a string with specified number of zeros.
 * Default is to add leading zeros.
 * 
 * @param strNum number to be filled with zeros
 * @param quantity number of zeros to be added
 * @param {Integer} trailing Add zeros at the end of the string (Default: False)
 * @returns {String} string with zeros
 */
ZFill(strNum, quantity, trailing := false) {
    o := ''
    (trailing ? o .= String(strNum) : 0)
    loop quantity - StrLen(strNum) {
        o .= '0'
    }
    (!trailing ? o .= String(strNum) : 0)
    return o
}

/**
 * Multiplies a string by a specified multiplier.
 * @param str string to be multiplied
 * @param mul multiplier
 * @returns {String} multiplied string
 */
StrMul(str, mul) {
    o := ''
    loop mul {
        o .= str
    }
    return o
}

/**
 * Returns the ordinal value of the number.
 * 
 * Example:
 * - 1 -> 1st
 * - 43 -> 43rd
 * - 13 -> 13th
 * @param n Number
 * @returns {String} Ordinal value of the number
 */
Ordinal(n) {
    suf := Map('1', 'st', '2', 'nd', '3', 'rd')                                             ;; Suffix map
    sec := (StrLen(n) > 1 ? SubStr(n, -2, 1) : 0)                                             ;; Second number from the last. Sets to 0 if the number is a single digit
    last := SubStr(n, -1)                                                                   ;; Last Number
    out := n (last < 4 && last > 0 && (sec = 0 || sec > 1) ? suf[last] : 'th')                                ;; Output. Considers 11th, 12th, and 13th numbers.
    return out
}

/**
 * Converts data units including bits and bytes.
 * Lowercase 'b' stands for bit while the uppercase 'B' stands for byte.
 * Binary counting such as 'kibi' indicates '1024' bytes while 'kilo' is for '1000'
 * 
 * To differentiate:
 *  - Mb (megabits) = 131,072 (or (1024^2)/8) bytes
 *  - MiB (mebibytes) = 1,048,576 (or 1024^2) bytes
 *  - MB (megabytes) = 1,000,000 (or 1000^2) bytes
 * 
 * * Bits is named 'bi' to avoid conflict with bytes symbol.
 * This is because AHK doesn't support case sensitive variable naming.
 * However, inputs of 'b' and 'B' is still recognizable.
 * 
 * @param {Number} inVal - Input value
 * @param {String} inUnit - Input unit
 * @param {String} outUnit - Output unit (Default: Auto)
 * @param {Number} remainder - Remainder (Default: None)
 * @param {Boolean} inclUnit - Include unit (Default: False)
 * @param {Boolean} formatted - Format the output value (Default: False)
 * @param {Boolean} fwd - Forwarded switch (Default: False)
 * @returns {Object} an object containing the converted value and the unit.
 * The inclUnit parameter can be omitted if the outUnit is also omitted.
 * 
 * Method:
 * The input unit will be converted to bytes before converting to the desired unit
 * 
 * Supports up to Petabyte.
 */
DataUnit(inVal, inUnit := 'B', outUnit := 'auto', remainder := 'none',
    inclUnit := false, formatted := false, fwd := false) {
        if !IsNumber(inVal) {
            throw TypeError("Input value must be a number", , inVal)
        }
        if Type(inUnit) != "String" {
            throw TypeError("Input unit must be a string. Only use their unit symbol", , inUnit)
        }

        inUnit := StrReplace(inUnit, 'b', 'bi', true)
        UNITS := {
            names: [[], [], []],
            offset: [1000, 1000, 1024],
        }

        for index, subUnit in ['bi', 'B', 'iB'] {
            UNITS.names[index].Push(subUnit)
            for name in ArrayFromStr("KMGTP") {
                UNITS.names[index].Push(name subUnit)
            }
        }

        loop 3 {
            if ArrayMatch(outUnit, UNITS.names[A_Index]) or outUnit = 'auto' {
                break
            }
            if A_Index = 3 {
                throw ValueError("Output unit is invalid or not supported", , outUnit)
            }
        }

        for subUnit in UNITS.names {                                                            ;; Convert the input value into bytes
            idx := A_Index
            for magnitude, name in subUnit {
                if name != inUnit {
                    continue
                }
                mode := (SubStr(inUnit, -1) == 'iB' ? 3 : SubStr(inUnit, -1) == 'B' ? 2 : 1)      ;; Determine if dividing bits is required
                unitSize := ((UNITS.offset[idx] ** magnitude) / UNITS.offset[idx])                  ;; Calculate the equivalent unit size of the input value in bytes
                unitSize := (mode = 1 ? unitSize / 8 : unitSize)                                    ;; Compensate for bits if needed
                inBytes := unitSize * inVal                                                       ;; Multiply the unit size with the value to get the total bytes
            }
        }

        if outUnit = 'auto' {                                                                   ;; Automatically sets the unit based on magnitude of the input value
            bytes := inBytes
            magnitude := 1
            while bytes > 1 {
                magnitude := A_Index
                bytes /= 1000
            }
            mode := (magnitude = 1 ? 2 : 3)
            return DataUnit(
                inBytes, 'B', UNITS.names[mode][magnitude],
                remainder, inclUnit, formatted, true
            )
        }

        for subUnit in UNITS.names {                                                            ;; Convert the converted-input bytes into desired output
            idx := A_Index
            for magnitude, name in subUnit {
                if name != outUnit {
                    continue
                }
                unitSize := (UNITS.offset[idx] ** magnitude / UNITS.offset[idx])                    ;; Calculate the unit size using magnitude and offset
                loop magnitude - 1 {                                                              ;; Divide by 1,000 to narrow the result
                    inBytes /= UNITS.offset[idx]
                }
            }
        }

        outVal := (remainder != 'none' ? Round(inBytes, remainder) : inBytes)
        outVal := (formatted ? FmtNum(outVal) : outVal)                                           ;; Format with comma separated value and decimals
        if fwd && !inclUnit {                                                                   ;; Returns an object containing both value and unit if disp outUnit is set to auto
            out := {
                value: outVal,
                unit: outUnit,
                valunit: outVal ' ' outUnit,
            }
        } else {
            out := outVal (inclUnit or fwd ? ' ' outUnit : '')
        }
        return out
}