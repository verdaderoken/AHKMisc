/*
    Extended library for Arrays

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

/*  Converts string into an array */
Arr(Str) {
    return StrSplit(Str)
}

/*  Displays the array as string (like in Python) */
ArrayAsStr(arr, delims := ", ", end := "", brackets := true, unit := "", unitEnd := true, border := '') {
    if Type(arr) != "Array"
        throw TypeError("Expected an Array type, got " Type(arr), , arr)
    o := (brackets ? "[" : "")
    for i in arr {
        if !InStr("String Integer Float", Type(i))
            i := '<' Type(i) '>'
        try o .= border (!unitEnd ? unit : '') i (unitEnd ? unit : "") border (A_Index == arr.Length ? end : delims)
        catch Error {
            throw Error("Push error in " Type(arr) " type element at index " A_Index)
        }
    }
    o .= (brackets ? ']' : '')
    return o
}

/**
 * Returns the length of the array
 * @param Arr The array to be measured
 * @param {Integer} Reversed If true, the output will be reversed
 * @returns {Array} Returns the length of the array
 */
ArraySort(Arr, Reversed := false) {
    ArrStr := ''
    if !IsObject(Arr) {
        return
    }
    if Reversed {
        _r := []
        while (i := Arr.Length - A_Index + 1) {
            _r.Push(Arr[i])
        }
        Arr := _r
    }

    for e in Arr {
        ArrStr .= e "`n"
    }
    ArrStr := StrSplit(Sort(Trim(ArrStr, "`n"), (Reversed ? "R" : "")), "`n")
    return ArrStr
}

/*  Sorts the array but with numbers */
ArraySortNum(arr, reversed := false) {
    if !reversed {
        out := []
        rev := ArraySortNum(arr, true)
        for i, n in rev {
            out.Push(rev[rev.Length - i + 1])
        }
        return out
    }

    out := []
    last_idx := 1
    while arr.Length {
        last := 0
        for i, n in arr {
            if n > last {
                last := n
                last_idx := i
            }
        }
        try arr.RemoveAt(last_idx)
        catch Error {
            ; MsgBox(ArrayAsStr(arr) ' & ' ArrayAsStr(out))
            arr.RemoveAt(-1)
        }
        out.Push(last)
    }
    return out
}

/* Returns the sum of all elements in an array */
ArraySum(arr) {
    o := 0
    for i in arr {
        (isDigit(String(i)) ? (o += i) : 0)
    }
    return o
}

ArraySubtract(minuend, subtrahend) {
    if Type(minuend) != "Array" && Type(subtrahend) != "Array"
        throw TypeError("Expected an Array type, got " type(minuend))
    o := []
    for i in minuend {
        if !ArrayMatch(i, subtrahend)
            o.Push(i)
    }
    return o
}

/* Returns the average of elements inside the array */
ArrayAvg(arr, remainder := -1) {
    if Type(arr) != "Array"
        throw TypeError("Expected an Array type, got " type(arr))
    try out := ArraySum(arr) / arr.Length
    catch Error {
        out := 0                                                                            ;; When length is zero.
    }
    return (remainder != -1 ? Round(out, remainder) : out)
}


/* Returns true if the needles matches any element in an array */
ArrayMatch(needle, haystack, caseSensitive := false) {
    for i in haystack {
        if (caseSensitive ? (i == needle) : (i = needle)) {
            return 1
        }
    }
    return 0
}


/*  Generates an array from range of numbers
    Also accepts string insertion along with numbers.

    - When strAtEnd is true, the string will be inserted at the end of number
*/
ArrayRange(start, end, str := "", strAtEnd := false) {
    o := []
    while start < end + 1 {
        o.Push(
            (!strAtEnd ? str : "")
            start
            (strAtEnd ? str : "")
        )
        start++
    }
    return o
}

/* Merges array into a single array */
ArrayMerge(arr*) {
    o := []
    for a in arr {                                                                          ;; Loop through every arg (assumed they're all ArrayType)
        if Type(a) != "Array" {                                                             ;; Ignore not array type in variadic EXCEPT for string—
            if Type(a) != "String"                                                          ;; as String can be converted to array
                continue
            a := Array(a)
        }
        for i in a {                                                                        ;; Push every value to a new array object (o)
            o.Push(i)
        }
    }
    return o
}


/**
 * Converts string (set) into array of characters.
 * 
 * If delim is omitted, every character will be an element.
 */
ArrayFromStr(strSet, delim := '') {
    if Type(strSet) != "String"
        throw TypeError("Expected a String type, got " type(strSet))
    o := []
    loop parse strSet, delim {
        o.Push(A_LoopField)
    }
    return o
}

/* Subtracts Array A with Array B */
ArrayDiff(arrA, arrB) {
    if Type(arrA) != "Array" && Type(arrB) != "Array"
        throw TypeError("Expected an Array type, got " type(arrA))
    o := []
    for i in arrA {
        (!ArrayMatch(i, arrB) ? o.push(i) : 0)
    }
    return o
}

/* Merge arrays but discards duplicate elements */
ArrayUnique(arrays*) {
    m := []
    for i in arrays {
        for j in i {
            m.Push(j)
        }
    }
    m := ArrayMerge(m)
    o := []
    for i in m {
        if !ArrayMatch(i, o)
            o.Push(i)
    }
    return o
}

/**
 * Returns matched elements in an array.
 * This method uses regular expression in which it matches all elements
 * that contains the keyword regardless of its position and case-sensitivity.
 * 
 * Default match mode is '`Contains`' which matches all elements that contains
 * the keyword.
 * 
 * Improvements:
 *  - Have an option change match mode (ongoing 2022-06-05)
 * 
 * @param {Array} haystack The array to be filtered
 * @param {String} needle The keyword to be matched
 * @param {String} matchMode The match mode to be used. Default is '`Contains`'
 * @returns {Array} Returns an array of matched elements
 */
ArrayFilter(haystack, needle, matchMode := 'Contains', caseSensitive := false) {
    FILTERED := []
    caseSensitive := (caseSensitive ? "" : "(?i)")
    for e in haystack {
        try {
            switch StrLower(matchMode) {
                case 'contains':
                    if RegExMatch(e, Format("{1}({2})", caseSensitive, needle)) {
                        FILTERED.push(e)
                    }
                case 'exact':
                    if RegExMatch(e, Format("^{1}({2}$)", caseSensitive, needle)) {
                        FILTERED.push(e)
                    }
                case 'startswith':
                    if RegExMatch(e, Format("^{1}({2})", caseSensitive, needle)) {
                        FILTERED.push(e)
                    }
            }
        } catch Error {
            return []
        }
    }
    return FILTERED
}

/*  Finds the index number of the needle element in haystack.
    Throws ValueError if not found.
*/
ArrayFind(haystack, needle, caseSensitive := false) {
    if Type(haystack) != "Array" {
        throw TypeError("Parameter #1 is not an Array type. Got " Type(haystack))
    }
    for i, e in haystack {
        if caseSensitive {
            if e == needle {
                return i
            }
        } else {
            if e = needle {
                return i
            }
        }
    }
    throw ValueError(Format("'{1}' cannot be found in the array", needle))
}

/*  Similar to SubStr but applies to array objects */
ArrayTrunc(arr, startPos := 1, elements := -1) {
    o := []
    e := 0
    startPos := (startPos < 0 ? arr.Length + startPos + 1 : startPos)
    for i in arr {
        if A_Index >= startPos &&
            (elements > 0 ? e < elements : e < arr.Length + elements + 1) {                      ;; Pushes the element if it's in scope of startPos and element number is in range
                o.Push(i)
                e++
        }
    }
    return o
}

/*  Returns the index of the highest value in an array */
ArrayMaxIndex(arr) {
    HIGH := 0
    IDX := 0
    for i in arr {
        if i < HIGH && A_Index > 1
            continue
        HIGH := i
        IDX := A_Index
    }
    return IDX
}

/*  Returns the index of the lowest value in an array */
ArrayMinIndex(arr) {
    LOW := 0
    IDX := 0
    for i in arr {
        if i > LOW && A_Index > 1
            continue
        LOW := i
        IDX := A_Index
    }
    return IDX
}

/*  Returns the lowest value in an array */
ArrayMin(arr) {
    try arr[ArrayMinIndex(arr)]
    catch Error {
        return 0
    }
}

/*  Returns the highest value in an array */
ArrayMax(arr) {
    try arr[ArrayMaxIndex(arr)]
    catch Error {
        return 0
    }
}

/* Reverses an array */
ArrayReverse(arr) {
    o := []
    for i, e in arr {
        o.Push(arr[-i])
    }
    return o
}