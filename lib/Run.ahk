/*
    Extended library for Run

    (c) 2022-2024 Ken Verdadero
    2022-06-02
*/


/**
 * Run a command and return the output
 * @param command The command to run
 * @returns {Buffer|String} The output of the command
 */
RunWaitOne(command) {
    FN := Random(10000, 100000)
    shell := ComObject("WScript.Shell")
    cmd := Format('{1} /c {2} > {3}\{4}.txt', A_ComSpec, command, A_Temp, FN)
    exec := shell.Run(cmd, 0, true)
    OUT := FileRead(Format("{1}\{2}.txt", A_Temp, FN))
    FileDelete(Format("{1}\{2}.txt", A_Temp, FN))
    return OUT
}

/**
 * Run or activate a window.
 * 
 * If the window is not found, it will run the process.
 * If the window is found, it will activate the window.
 * 
 * @param Target the target window title
 * @param Proc the process to run
 * @param {Integer} AllowMultiInstance if true, it will run the process even if the window is found.
 */
RunActivate(Target, Proc, AllowMultiInstance := false) {
    (WinExist(Target) ? (AllowMultiInstance ? Run(Proc) : WinActivate(Target)) : Run(Proc))
}

/**
 * Opens the properties window of the file
 * @param path The path of the file
 */
RunProperties(path) {
    shell := ComObject("shell.application")
    shell.namespace(0).parsename(path).invokeverb("Properties")
}