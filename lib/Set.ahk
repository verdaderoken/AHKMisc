/*
    Extended library for Set

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

/**
 * Converts string (set) into array of characters
 * @param String The string to be converted
 * @returns {Array} The array of characters
 */
Set(String) {
    if Type(String) != "String"
        throw Error("`"" String "`" is not a string")
    o := Array()
    loop parse String {
        o.Push(A_LoopField)
    }
    return o
}