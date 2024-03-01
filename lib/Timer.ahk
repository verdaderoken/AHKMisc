/*
    Extended library for Timer

    (c) 2022-2024 Ken Verdadero
    2022-11-19
*/

/**
 * Timer class.
 * A class-based approach to using timers in AutoHotkey.
 * 
 * @class Timer
 * 
 * @property {Integer} period - The period of the timer
 * @property {Integer} priority - The priority of the timer
 * @property {Integer} defPeriod - The default period of the timer
 * @property {Integer} defPriority - The default priority of the timer 
 * 
 * @example
 * 
 * timer := Timer(MyAppObj, "AutoSave", 1000 * 60, 0)
 * timer.Start()
 */
class Timer {
    __New(obj, method := "Call", defPeriod := 250, defPriority := 0, proxyCallback := "") {
        this.period := defPeriod
        this.priority := defPriority
        this.__callback := Format("{1}.{2}", Type(obj), method)
        this.proxyCallbackFunc := proxyCallback
        this.callback := ObjBindMethod(this, "_ProxyCallback", ObjBindMethod(obj, method))   ;; ! Params in ObjBindMethod is not supported
        this.running := false
    }

    /**
     * A middleware for the callback
     * @param obj the actual callback function
     */
    _ProxyCallback(obj) {
        if Type(this.proxyCallbackFunc) == "Func" {
            this.proxyCallbackFunc.Call()
        }
        obj.Call()
    }

    /**
     * Sets the period of the timer
     * @param {Integer} value 
     */
    SetPeriod(value := 250) {
        if Type(value) != "Integer" {
            throw TypeError("Expected an Integer type. Got " Type(value), , value)
        }
        this.period := value
    }

    /**
     * Sets the priority of the timer
     * @param {Integer} value 
     */
    SetPriority(value := 0) {
        if Type(value) != "Integer" {
            throw TypeError("Expected an Integer type. Got " Type(value), , value)
        }
        this.priority := value
    }


    /**
     * Starts the timer
     * @param {String} period interval in milliseconds
     * @param {String} priority level of priority
     */
    Start(period := '', priority := '') {
        if this.IsRunning() {
            return
        }
        period := (StrLen(period) ? period : this.period)
        SetTimer(
            this.callback,
            period,
            (StrLen(priority) ? priority : this.priority),
        )
        this.running := (period < 0 ? 0 : 1)
    }

    /**
     * Stops the timer
     */
    Stop() {
        try {
            SetTimer(this.callback, 0)
            this.running := false
        }
        catch Error as e {
            throw Error(Format("Cannot terminate timer: {1}", e.Message), , e.Extra)
        }
    }

    /**
     * Returns the running status of the timer
     */
    IsRunning() => (this.running ? 1 : 0)
}