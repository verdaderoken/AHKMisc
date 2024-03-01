/*
    JSON Serializer Deserializer for AHK2
    --------------------------------------
    Inspired and forked from https://github.com/cocobelgica/AutoHotkey-JSON

    (c) 2015 cocobelgica (https://github.com/cocobelgica)
    (c) 2022 Ken Verdadero
*/

class JSON {
    static parse(src, args*) {
        return JSON.load(src, args*)
    }
    static stringify(obj, args*) {
        return JSON.dump(obj, args*)
    }
    static load(src, args*) {
        try src := FileRead(src)
        catch Error as e {
            src := src
        }

        key := "", is_key := false
        stack := [tree := []]
        is_arr := Map(tree, 1) ; ahk v2
        next := '"{[01234567890-tfn'
        pos := 0

        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")

                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))

                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                        : (next == "\") ? "Invalid \escape"
                        : (next == ":") ? "Expecting ':' delimiter"
                        : (next == '"') ? "Expecting object key enclosed in double quotes"
                        : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                        : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                        : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                        : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                            , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                    , ln, col, pos)

                throw Error(msg, -1, ch)
            }

            obj := stack[1]
            memType := Type(obj)
            is_array := (memType = "Array") ? 1 : 0

            if i := InStr("{[", ch) {                                                       ;; Start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2

                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)

                is_arr[val] := !(is_key := ch == "{")
                next := '"' (is_key ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := stack[1] == tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else {                                                                        ;; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue

                    pos := i ; update pos

                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")

                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2

                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }

                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }

                    pos += i - 1
                }

                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }

        return tree[1]
    }

    static dump(obj, indent := "", lvl := 1) {
        if IsObject(obj) {
            memType := Type(obj) ; Type.Call(obj)
            is_array := (memType = "Array") ? 1 : 0

            if (memType ? (memType != "Object" and memType != "Map" and memType != "Array") : (ObjGetCapacity(obj) == ""))
                throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

            if IsInteger(indent)
            {
                if (indent < 0)
                    throw Error("Indent parameter must be a postive integer.", -1, indent)
                spaces := indent, indent := ""

                Loop spaces ; ===> changed
                    indent .= " "
            }
            indt := ""

            Loop indent ? lvl : 0
                indt .= indent

            lvl += 1, out := "" ; Make #Warn happy
            for k, v in obj {
                if IsObject(k) || (k == "")
                    throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

                if !is_array ;// key ; ObjGetCapacity([k], 1)
                    out .= (ObjGetCapacity([k]) ? JSON.dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

                out .= JSON.dump(v, indent, lvl) ; value
                    . (indent ? ",`n" . indt : ",") ; token + indent
            }

            if (out != "") {
                out := Trim(out, ",`n" . indent)
                if (indent != "")
                    out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
            }

            return is_array ? "[" . out . "]" : "{" . out . "}"
        } else { ; Number
            If (Type(obj) != "String")
                return obj
            Else
                return escape_str(obj)
        }

        escape_str(obj) {
            obj := StrReplace(obj, "\", "\\")
            obj := StrReplace(obj, "`t", "\t")
            obj := StrReplace(obj, "`r", "\r")
            obj := StrReplace(obj, "`n", "\n")
            obj := StrReplace(obj, "`b", "\b")
            obj := StrReplace(obj, "`f", "\f")
            obj := StrReplace(obj, "/", "\/")
            obj := StrReplace(obj, '"', '\"')

            return '"' obj '"'
        }
    }
}