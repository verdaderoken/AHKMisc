/*
    SevenZip (7Zip) Parser
    -----------------------
    Uses 7z.exe to parse a zip file (.7z)

    License: https://www.7-zip.org/license.txt

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/

#Include ./Run.ahk
#Include ./Path.ahk
#Include ./Arrays.ahk

/**
 * A simple archive wrapper.
 * 
 * This uses 7z.exe to parse an archive file.
 * 
 * @param {String} zip The zip file to parse
 * @param {String} password The password for the zip file
 * @param {String} bin The path to 7z.exe
 * @param {String} dll The path to 7z.dll
 * @returns {Object} SevenZip
 * @throws {Error} If 7z.exe or 7z.dll is not found
 * @example
 * zip := new SevenZip("C:\path\to\file.7z")
 * zip := new SevenZip("C:\path\to\file.7z", "password")
 * zip := new SevenZip("C:\path\to\file.7z", "password", "C:\path\to\7z.exe")
 */
Class SevenZip {
    __New(zip, password := '', bin := 'bin\7z.exe', dll := 'bin\7z.dll') {
        bin := (!InStr(bin, '.exe') ? bin '.exe' : bin)
        if !FileExist(bin) {
            Throw Error('Binary 7z was not found: ' bin, , bin)
        }
        if !FileExist(dll) {
            Throw Error('7z.dll was not found: ' dll, , dll)
        }
        this.ZIP := zip
        this.BIN := bin
        this.DLL := dll
        this.PW := password
        this.META := this._ParseZip()
        this.ZIP_SIZE := this.META.ZIP.SIZE
        this.PATHS := this.META.PATH
        this.SIZES := this.META.SIZE
        this.MODIFIEDS := this.META.MODIFIED
        this.CRCS := this.META.CRC
        this.METHODS := this.META.METHOD
    }

    /**
     * Parses the whole 7zip file
     * @returns {Object} meta
     */
    _ParseZip() {
        SplitPath(this.BIN)
        command := Format('{1} l "{2}" -slt {3}',
            this.BIN, this.ZIP, (StrLen(this.PW) ? '-p"' this.PW '"' : '')
        )
        zip := StrSplit(RunWaitOne(command), '`n')

        meta := Object()
        for prop in ['Path', 'Size', 'Modified', 'Attributes', 'CRC', 'Method'] {           ;; File properties
            meta.DefineProp(prop, { value: Array() })
        }
        meta.Zip := {                                                                       ;; Metadata for the target zip
            Size: 0                                                                         ;; Size of the zip in bytes
        }

        for line in zip {
            line := Trim(line, ' `t`r`n')
            if !StrLen(line) {
                continue
            }
            if InStr(line, "Codec Load Error") {
                return 1
            }

            key := StrSplit(line, ' ')[1]                                                   ;; Property key
            val := Trim(ArrayAsStr(ArrayTrunc(StrSplit(line, ' '), 3), ' ', , false),        ;; Trimmed value
                ' `t`r`n')
            switch key {
                case '1': meta.Zip.Size := StrSplit(val, ' ')[1]
                case 'Path': meta.Path.Push(val)
                case 'Size': meta.Size.Push(val)
                case 'Modified': meta.Modified.Push(val)
                case 'Attributes': meta.Attributes.Push(val)
                case 'CRC': meta.CRC.Push(val)
                case 'Method': meta.Method.Push(val)
            }
        }
        return meta
    }

    /**
     * Extracts a file from the zip
     * @param filename The file to extract
     * @param {String} destination Destination directory
     * @param {Integer} overwrite Overwrite existing file
     * @returns {Integer} 0 if successful, 1 if file not found, 2 if file exists and overwrite is false
     */
    Extract(filename, destination := '', overwrite := false) {
        filename := StrReplace(filename, '/', '\')
        destination := (StrLen(destination) ? destination : A_WorkingDir)                    ;; Set destination to working directory if not specified
        destination := StrReplace(destination, '/', '\')                                    ;; Convert all forward slashes to a backslash
        if !ArrayMatch(filename, this.PATHS) {                                              ;; Verify if the filename is in archive
            return 1
        }
        if FileExist(PathJoin(destination, PathSplit(filename)[2])) and !overwrite {
            return 2
        }
        if !FileExist(this.BIN) {
            throw Error('Binary 7z was not found: ' this.BIN, , "Binary")
        }
        if !FileExist(this.DLL) {
            throw Error('7z.dll was not found: ' this.DLL, , "Library")
        }
        switchs := (overwrite ? '-aoa' : '')
        command := Format(
            '{1} e "{2}" "{3}" -o"{4}" -p"{5}" {6}',
            this.BIN, this.ZIP, filename, destination, this.PW, switchs
        )
        RunWaitOne(command)
        return 0
    }

    /**
     * Returns the file info of the specified file
     * @param filename The file to get info from
     * @returns {Integer|Object} 1 if file not found, Object if file is found
     */
    GetInfo(filename) {
        filename := StrReplace(filename, '/', '\')
        if !ArrayMatch(filename, this.PATHS) {
            return 1
        }
        idx := ArrayFind(filename, this.PATHS)
        return {
            Path: filename,
            Size: this.SIZES[idx],
            Modified: this.MODIFIEDS[idx],
            CRC: this.CRCS[idx],
            Method: this.METHODS[idx]
        }
    }
}