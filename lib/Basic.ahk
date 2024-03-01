/*
    Extended library for Basic functions.
    Mostly used for debugging.

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

#Include ./Arrays.ahk


/**
 *  Tooltip with a timeout (in seconds) before clearing
 *  Default value: 3 seconds
 * 
 *  When timeout is a float, it is always measured in milliseconds
 */
ToolTipX(Message := "", Timeout := 3, X := "", Y := "", WhichTooltip := 1) {
    IsNumber(X) && IsNumber(Y) ? ToolTip(Message, X, Y, WhichTooltip) :
        ToolTip(Message, , , WhichTooltip)
    If Timeout > 0 {
        SetTimer(removeTooltip, -(Timeout * (IsFloat(Timeout) ? 1 : 1000)))
    }

    removeTooltip() {
        ToolTip()
    }
}

/**
 *  Message report. Useful for debugging
 * 
 *  Mode: 0 = Tooltip, 1 = MsgBox
 */
Report(Mode, MsgArray) {
    OUT := Format("Report ({} Args)", MsgArray.Length)
    for i, e in MsgArray {
        if !ArrayMatch(Type(e), ["String", "Float", "Integer"])
            e := "<" Type(e) ">"
        OUT := OUT "`nP" i ": " (StrLen(e) > 0 ? e : "<Empty>")
    }

    if (Mode == 0) {
        ToolTipX(OUT, 5)
    } else {
        MsgBox(OUT, "Message", "4160")
    }
}

/* Message report. Useful for debugging */
MsgRep(Message*) {
    Report(1, Message)
}


/* Just like Message report but using tooltips. Useful for debugging */
ToolRep(Message*) {
    Report(0, Message)
}

/*  Returns OS Bit version (32-bit / 64-bit) */
GetOSBit(type := 0) {
    return (type ? (A_Is64bitOS ? "64-bit" : "32-bit") : (A_Is64bitOS ? "x64" : "x86"))
}

/*  Returns length of the enumerator */
Len(enumerator) {
    o := 0
    for i in enumerator {
        o++
    }
    return o
}

/*  Returns true if the number is between low and high, otherwise false */
InRange(num, low, high) {
    return (num >= low and num <= high ? 1 : 0)
}

/*  Prints value to stdout */
Print(values*) {
    try stdout := FileOpen("*", "w")
    catch Error {
        return
    }
    if Type(values) == "String" {
        stdout.WriteLine(StrLen(values) ? values : "<Empty>")
        return
    }

    for v in values {
        stdout.Write(v)
        (A_Index < values.Length ? stdout.Write(' ') : 0)
    }
}

/*  Prints value to stdout with a new line */
PrintLn(values*) {
    Print('`n')
    for i in values {
        Print(i)
    }
}