/*
    Extended library for Directory functions.

    (c) 2022-2024 Ken Verdadero
    2022-07-23
*/

/**
 * Lists all files in a directory.
 * 
 * Similar to Python's os.listdir.
 * Add 'R' in mode to list recursively.
 * 
 * @param directory 
 * @param {String} filePattern
 * @param {String} mode 
 * @param {String} exclude 
 * @returns {Array} array of file list
 */
DirList(directory, filePattern := '*.*', mode := 'DF', exclude := '') {
    if Type(directory) != "String" {
        throw TypeError("Expected a String type, got " Type(directory))
    }
    if !RegExMatch(DirExist(directory), 'D') {
        throw ValueError("Not a valid directory", , directory)
    }
    list := []
    loop files directory '\' filePattern, mode {
        if StrLen(exclude) {
            if A_LoopFileAttrib ~= Format("[{1}]", exclude) {
                continue
            }
        }
        list.Push(A_LoopFileFullPath)
    }
    return list
}