/*
    Extended library for Paths

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

#Include ./Strings.ahk
#Include ./Arrays.ahk

/**
 * Returns the directory specified by levels of parent directory.
 * @param path The path to be traversed
 * @param {Integer} level The number of levels to go up
 */
PathUpFolder(path, level := 1) {
    if Type(path) != "String"
        throw TypeError("Expected a String type, got " Type(path), , path)
    if Type(level) != "Integer"
        throw TypeError("Invalid level. Only use an integer number")
    path := StrSplit(StrReplace(path, "/", "\"), "\")
    (level >= path.Length ? (level := path.Length - 1) : path)
    return path[-level - 1]
}

/**
 * Joins paths with a backslash character.
 * @param paths The paths to be joined
 * @returns {String} The joined path
 */
PathJoin(paths*) {
    out := ""
    for i, path in paths {
        path := Trim(path, '`t`r`n')
        out .= path (i != paths.length && StrLen(path) ? "\" : "")
    }
    return out
}

/**
 * Truncates a path based on the number of levels.
 * @param path The path to be truncated
 * @param {Integer} startPath Starting level of the path
 * @param {Number} endPath Ending level of the path
 * @returns {String} The truncated path
 */
PathTrunc(path, startPath := 1, endPath := -1) {
    path := StrReplace(path, '/', '\')
    path := StrSplit(path, '\')
    return ArrayAsStr(ArrayTrunc(path, startPath, endPath), '\', , false)
}

/**
 * Splits a path into head and tail.
 * @param path The path to be split
 * @returns {Array} The head and tail of the path
 */
PathSplit(path) {
    path := StrReplace(path, '/', '\')
    split := StrSplit(path, '\')
    tail := split[-1]
    split.RemoveAt(-1)
    head := ArrayAsStr(split, '\', , false)
    return [head, tail]
}

/**
 * Checks if a folder exists.
 * @param directory The directory to be checked
 * @param {Integer} autoCreate If true, creates the directory if it does not exist
 * @returns {Integer} 1 if the folder exists, 0 otherwise
 */
IsFolderExists(directory, autoCreate := false) {
    out := (InStr(FileExist(directory), "D") ? True : False)
    if !out && autoCreate {
        DirCreate(directory)
        return 0
    }
    return out
}

/**
 * Launches the directory using the default file manager.
 * 
 * The difference between this and `Run` is that this function
 * automatically checks if the path is a directory.
 * 
 * @param path The directory to be launched.
 */
OpenFolder(path) {
    if !InStr(FileGetAttrib(path), 'D') {
        path := StrSplit(StrReplace(path, '/', '\'), '\')
        path.RemoveAt(-1)
        path := ArrayAsStr(path, '/', , false)
    }
    if !IsFolderExists(path) {
        throw Error("Folder does not exist", , path)
    }
    Run(path)
}

/**
 * Splits the file extension.
 * @param filename The filename to be split
 * @param {Integer} dot If true, includes the dot in the extension
 * @returns {Array} The root and extension of the file
 */
SplitExt(filename, dot := false) {
    filename := StrReplace(filename, '/', '\')
    pair := StrSplit(filename, '.')
    tail := StrCount(pair[-1], '\\')
    root := Join(ArrayTrunc(pair, 1, -2), '.')
    ext := dot ? '.' : '' pair[-1]
    if FileExist(filename) {
        if StrCount(FileGetAttrib(filename), 'D') {
            tail := -1
        }
    }
    return (tail ? [filename, ''] : [root, ext])
}

/**
 * Shortens a path based on directory levels and filename length.
 * @param path The path to be shortened
 * @param {Integer} maxLen The maximum length of the path
 * @param {Float} balance The balance of the path
 * @returns {String} The shortened path
 */
PathShorten(path, maxLen := 20, balance := 0.6) {
    ;; TODO: Consider very long file names. They should be truncated
    path := StrReplace(path, '/', '\')
    pathLen := StrLen(path)
    timeout := 7

    while pathLen > maxLen {
        _pathLen := pathLen
        if !timeout {
            break
        }

        _fragments := StrSplit(path, '\')
        fragments := []
        for frag in _fragments {
            if !RegExMatch(frag, ".{3}\.\.\.") {
                fragments.Push(frag)
            }
        }
        fragLen := fragments.Length
        brIdx := Round(fragLen * balance)
        target := fragments[brIdx]
        if StrLen(target) > 3 {
            l := SubStr(fragments[brIdx], 1, 3)
            r := SubStr(fragments[brIdx], -2)
            fragments.RemoveAt(brIdx)
            fragments.InsertAt(brIdx, l "...")
        } else {
            fragments.RemoveAt(brIdx)
            fragments.InsertAt(brIdx, "...")
        }

        result := Join(fragments, '\')
        path := result
        pathLen := StrLen(result)
        if pathLen == _pathLen {
            break
        }
        timeout--
    }

    return path
}