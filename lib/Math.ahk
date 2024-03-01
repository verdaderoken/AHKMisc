/*
    Extended library for Math

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

/**
 * Modified version of Mod() function which only accepts value.
 * @param value The value to be processed.
 * @param {Integer} decimals The number of decimal places to round the result.
 * @returns {Integer|String} The remainder of the division.
 */
ModX(value, decimals := 3) {
    if !IsNumber(value)
        throw TypeError("Expected a number, got " Type(value))
    return Round(Mod(value, 1), decimals)
}

/**
 * Returns the ratio of two numbers in decimal.
 * Prevents ZeroDivisionError.
 * @param a numerator
 * @param b denominator
 * @param {Integer} remainder The number of decimal places to round the result.
 * @param {Integer} sign True if "%" sign is included, otherwise False.
 * @returns {Integer} The ratio in decimal.
 */
Percent(a, b, remainder := 0, sign := true) {
    try {
        o := a / b
    } catch Error {
        return 0
    } else {
        o := Round((a / b) * 100, remainder)
        return (sign ? o "%" : o)
    }
}

/**
 * Returns the percentage of change (delta) between two values.
 * 
 * @param before number before
 * @param after number after
 * @param {Integer} remainder The number of decimal places to round the result. 
 * @param {Integer} mode The output format. 0 = Raw; 1 = Signed using '+' and '-' with '%'; 2 = Signed using
 * @returns {Integer|String} The percentage of change (delta) between two values.
 */
PercentDelta(before, after, remainder := 0, mode := 0) {
    try o := Round(((after - before) / abs(before)) * 100, remainder)
    catch Error {
        return 0
    }
    switch mode {
        /*  Output formats */
        case 1: return (o > 0 ? '+' : '-') abs(o) '%'                                           ;; Signed using '+' and '-' with '%'
        case 2: return abs(o) '% ' (o > 0 ? 'higher' : 'lower')                                 ;; Signed using 'higher' and 'lower' with '%'
        default: return o                                                                   ;; Raw; As is.
    }
}

/**
 * Returns the quotient and remainder of the division.
 * @param Quotient the result of the division.
 * @param Remainder the remainder of the division.
 * @param Dividend the number to be divided.
 * @param Divisor the number to divide by.
 */
DivMod(&Quotient, &Remainder, Dividend, Divisor) {
    Quotient := Floor(Dividend / Divisor)
    Remainder := "0." StrSplit(Dividend / Divisor, ".")[-1]
}

/**
 * Returns the ratio of two numbers in fraction.
 * Prevents ZeroDivisionError.
 * @param antecedent the numerator
 * @param consequent the denominator
 * @returns {String} The ratio in fraction.
 */
Ratio(antecedent, consequent) {
    a := antecedent
    b := consequent
    try a := Integer(a / Gcd(a, b))
    catch Error {
        a := 0
    }
    try b := Integer(b / Gcd(a, b))
    catch Error {
        b := 0
    }
    return Format("{1}:{2}", a, b)
}

/**
 * Returns the greatest common divisor of two numbers.
 * https://autohotkey.com/boards/viewtopic.php?p=23995#p23995 
 * 
 * @param a The first number.
 * @param b The second number.
 * @returns {Float|Integer} The greatest common divisor (GCD) of two numbers.
 */
Gcd(a, b) {
    while b {
        b := Mod(a | 0x0, a := b)
    }
    return a
}