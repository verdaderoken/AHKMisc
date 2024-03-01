/*
    Extended library for Map Object

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

/**
 * Merge multiple maps into one
 * If overflow is defined, array wil be returned. Otherwise, the map itself.
 * 
 * @param maps the maps to be merged
 * @returns {Array|Map} the merged map
 */
MapMerge(maps*) {
  output := Map()
  overflow := Map()
  sendOverflow := false
  for mapObj in maps {
    if Type(mapObj) == "Map" {
      for k, v in mapObj {
        if !output.Has(k) {
          output.Set(k, v)
        } else
          overflow.Set(k, v)
      }
    } else if Type(mapObj) == "String" && InStr(mapObj, '=') {
      pair := StrSplit(mapObj, '=')
      key := StrLower(pair[1])
      value := StrLower(pair[2])
      if key == "overflow" && value {
        sendOverflow := true
      }
    }
  }
  return (sendOverflow ? Array(output, overflow) : output)
}


/*  Returns an array of map keys */
MapGetKeys(mapObj) {
  o := []
  for k, v in mapObj {
    o.Push(k)
  }
  return o
}

/*  Returns an array of map values */
MapGetValues(mapObj) {
  o := []
  for k, v in mapObj {
    o.Push(v)
  }
  return o
}

/**
 * Renders the map object as a string
 * @param mapObj the object to be rendered
 * @param {String} delims delimiter between key-value pairs
 * @param {String} keyDelims delimiter between key and value
 * @param {Integer} braces whether to include braces or not
 * @returns {String} the rendered string
 */
MapAsStr(mapObj, delims := ", ", keyDelims := ":", braces := true) {
  if Type(mapObj) != "Map" && Type(mapObj) != "OrderedMap" {
    throw Error("Expected a map object, got " Type(mapObj))
  }
  k := MapGetKeys(mapObj)
  v := MapGetValues(mapObj)
  o := (braces ? "{" : "")
  for i, e in k {
    if (Type(e) != "String") || (Type(e) != "Integer") || (Type(e) != "Float") {
      e := "<" Type(e) ">"
    }
    if (Type(v[i]) != "String") || (Type(v[i]) != "Integer") || (Type(v[i]) != "Float") {
      v[i] := "<" Type(v[i]) ">"
    }
    o .= e keyDelims v[i] (i != k.Length ? delims : "")
  }
  o .= (braces ? "}" : "")
  return o
}

/**
 * @param {Map} mapObj
 * @param {String} name
 * @returns {Object}
 * @description
 * Converts the map into an object
 * All invalid key names ("./\") will be replaced by an underscore
 * 
 * Conversions:
 * @ - amp_
 */
MapToObj(mapObj, name := '') {
  obj := Object()
  for keyName, val in mapObj {
    switch Type(val) {
      case "Map": val := MapToObj(val, keyName)
    }
    keyName := RegExReplace(keyName, "[\./\\]", '_')
    keyName := RegExReplace(keyName, "@", 'amp_')
    obj.DefineProp(keyName, { value: val })
  }
  return obj
}