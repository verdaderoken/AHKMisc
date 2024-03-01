/*
    Extended library for File

    (c) 2022-2024 Ken Verdadero
    2022-06-10
*/

/**
 * Similar to FileAppend but handles deletion of the existing file.
 * 
 * @param content the content to be written to the file
 * @param filename the file to be written to
 * @param {Integer} append True if the content should be appended to the file, False if the file should be overwritten
 * @param {String} options 
 * @param {Integer} ignoreErrors True if the function should ignore errors, False if the function should throw an error
 * @param {String} encoding The encoding to be used when writing to the file
 */
FileWrite(content, filename, append := false, options := '', ignoreErrors := false, encoding := "") {
    if FileExist(filename) && !append {
        try {
            file := FileOpen(filename, "w", encoding)
            file.write("")
            file.close()
        } catch Error {
            if !ignoreErrors {
                throw Error("File access is denied.")
            }
        }
    }
    try FileAppend(content, filename, options)
    catch Error {
        if !ignoreErrors {
            throw Error("Cannot save the file")
        }
    }
    return filename
}

/**
 * Transfer the contents of a file without deleting the file.
 * @param source the source file
 * @param dest the destination file
 */
FileTransfer(source, dest) {
    src := FileOpen(source, "r")
    dst := FileOpen(dest, "w")
    dst.Write(src.Read())
    src.Close()
    dst.Close()
}