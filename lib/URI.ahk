/*
    URI Encoding/Decoding Functions

    (c) 2023-2024 Ken Verdadero
    2023-10-05
*/


/**
 * Encodes or decodes a URI string.
 * 
 * Uses htmlfile COM object to encode/decode a URI string.
 * @param {string} str - The string to encode/decode
 * @param {number} encode 
 * @param {number} component 
 * @returns {void|number} 
 */
EncodeDecodeURI(str, encode := true, component := true) {
    static doc := 0, js := 0

    if !doc {
        doc := ComObject("htmlfile")
        doc.write('<meta http-equiv="X-UA-Compatible" content="IE=edge">')
        js := doc.parentWindow
        (doc.documentMode < 9 && js.execScript())
    }

    command := (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "")

    switch command {
        case "encodeURI": return js.encodeURI(str)
        case "decodeURI": return js.decodeURI(str)
        case "encodeURIComponent": return js.encodeURIComponent(str)
        case "decodeURIComponent": return js.decodeURIComponent(str)
        default:
            MsgBox("Invalid command")
            return 0
    }
}

/**
 * Shorthand encode URI function
 * @param str - The string to encode
 * @param {number} component - Whether to encode the entire URI or just the component
 * @returns {void|number} - The encoded string
 */
EncodeURI(str, component := true) {
    return EncodeDecodeURI(str, true, component)
}

/**
 * Shorthand decode URI function
 * @param str - The string to decode
 * @param {number} component - Whether to decode the entire URI or just the component
 * @returns {void|number} - The decoded string
 */
DecodeURI(str, component := true) {
    return EncodeDecodeURI(str, false, component)
}