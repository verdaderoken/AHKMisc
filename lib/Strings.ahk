/*
    Extended library for Strings

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

#Include ./Format.ahk
#Include ./Arrays.ahk

/**
 * Concatenates an array of strings into a single string.
 * @param Arr The array of strings to be concatenated
 * @param {String} separator The separator to be used
 * @param {String} unit The unit to be used
 * @param {Integer} unitEnd If true, the unit is appended at the end of the string
 * @returns {String} The concatenated string
 */
Join(Arr, separator := '', unit := '', unitEnd := true) {
    return ArrayAsStr(Arr, separator, , false, unit, unitEnd)
}

/**
 * Counts the number of occurences in string
 * @param str The string to be searched
 * @param matchStr The string to be matched
 * @param {Integer} caseSense If true, the search is case sensitive
 * @returns {Integer} Number of occurences
 */
StrCount(str, matchStr, caseSense := false) {
    count := 0
    pos := 0
    loop {
        pos++
        pos := RegExMatch(str, matchStr, , pos)
        if !pos {
            return count
        }
        count++
    }
}

/**
 * Returns a singular or plural word along with the quantity.
 * The word must be in a singular form.
 * 
 * Ex:
 * 1. 4, apple -> 4 apples
 * 2. 7 church -> 7 churches
 * 3. 3 city -> 3 cities
 * 
 * Note:
 * Doesn't work perfectly because of some natural plurals like "Man" -> "Men"
 * instead of "Mans" or word exceptions like "parenthesis"
 * which should be "parentheses" instead of "parenthesisses" or "belief"
 * with "beliefs" instead of "believes"
 * 
 * @param qty number of items
 * @param word word to be inflected
 * @param {Integer} wordOnly If true, only the word is returned. If false, the quantity is also returned.
 * @param {Integer} formatNum If true, the quantity is formatted with commas.
 * @returns {String} Inflected word
 */
Inflect(qty, word, wordOnly := true, formatNum := false) {

    if ArrayMatch(SubStr(word, -3, 3), ['ves', 'ies'])
        || ArrayMatch(SubStr(word, -2), ['es']) {
            throw ValueError("Word must be in singular form", , word)
    }
    if qty != 1 {
        switch SubStr(word, -2) {
            case 'ch': word .= 'es'
            case 'sh': word .= 'es'
            case 'ss': word .= 'es'
            case 'fe': word := SubStr(word, 1, -2) 'ves'
        }

        switch SubStr(word, -1) {
            case 'x': word .= 'es'
            case 'z': word .= 'es'
            case 'f': word := SubStr(word, 1, -1) 'ves'
            case 'o':
                switch ArrayMatch(SubStr(word, -2, 1), ArrayFromStr("aeiou")) {
                    case 0: word .= 'es'
                    case 1: word .= 's'
                }
            case 'y':                                                                       ;; Ending in y; when follows a consonant, the suffix is 'ies', vowel turns suffix to 's'
                switch ArrayMatch(SubStr(word, -2, 1), ArrayFromStr("aeiou")) {
                    case 0: word := SubStr(word, 1, -1) 'ies'
                    case 1: word .= 's'
                }
            case 's':
                if !ArrayMatch(SubStr(word, -2, 2), ['es', 'ves']) {
                    word .= 'ses'                                                           ;; ! Not in rules
                }
            default:                                                                        ;; General 's' rule
                if !ArrayMatch(SubStr(word, -2, 2), ['es', 'ves']) {                        ;; Prevent adding another 's' if the word was already modified
                    word .= 's'
                }
        }
    }
    return (!wordOnly ? (formatNum ? FmtNum(qty) : qty) ' ' : '') word
}

/**
 * Converts a string to a sentence case.
 * 
 * Does not recognize proper nouns unless specified with backticks around it.
 * Trims leading spaces on both ends of the string.
 * 
 * States:
 * [1] - Full stop state.
 * [2] - Space after period confirmation.
 * [3] - Left side tick
 * [4] - Right side tick
 * 
 * @param str The string to be converted
 * @returns {String} Sentence case converted string
 */
StrSentence(str) {
    if Type(str) != "String" {
        throw TypeError("Only use string type in parameter #1", , str)
    }
    out := ''
    spc := 1
    st := [0, 0, 0, 0]

    loop parse Trim(str) {
        i := A_Index
        c := StrLower(A_LoopField)                                                          ;; Current character
        ca := SubStr(Trim(str), i + 1, 1)                                                     ;; Character ahead of the current one

        if st[3] && c == '``' {
            st[4] := 1
            st[3] := 0
            spc := 1
            continue
        }

        if st[3] && spc {                                                                   ;; S3 upper case for every after spaces since it is a proper noun
            c := StrUpper(c)
            spc := 0
        }

        if st[3] && c == ' ' {                                                              ;; Resets the space indicator for S3
            spc := 1
        }

        if c == '``' && ca != '``' {                                                        ;; S3 trigger as tick is present
            st[3] := 1
            continue
        }


        if st[1] && st[2] {                                                                 ;; New sentence after confirming from S1 and S2
            c := StrUpper(c)
            st[1] := 0
            st[2] := 0
        }
        if RegExMatch(c, "[.?!]") {                                                         ;; S1 trigger
            st[1] := 1
        }
        if c == ' ' && st[1] {                                                              ;; S2 trigger if S1 is high
            st[2] := 1
        }
        if i == 1 && c != ' ' {                                                             ;; Make the first letter uppercase
            c := StrUpper(c)
        }
        out .= c
    }
    return out
}


/**
 * Converts a camelCase format to a normal case string.
 * 
 * [1] Sentence Case: myExampleString -> My example string
 * [2] Title Case: myExampleString -> My Example String
 * [3] Upper Case: myExampleString -> MY EXAMPLE STRING
 * [4] Lower Case: myExampleString -> my example string
 */
StrFromCamel(str, mode := 0) {
    arr := []
    prevI := 1
    loop parse str {
        i := A_Index
        ca := SubStr(str, i + 1, 1)
        if IsUpper(ca) {
            arr.Push(SubStr(str, prevI, i - prevI + 1))
            prevI := i + 1
        }
    }
    switch mode {
        case 1: return StrSentence(Join(arr, ' '))
        case 2: return StrTitle(Join(arr, ' '))
        case 3: return StrUpper(Join(arr, ' '))
        case 4: return StrLower(Join(arr, ' '))
        default: return Join(arr, ' ')
    }
}