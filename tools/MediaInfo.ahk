/*
    MediaInfo
    ----------
    A simple wrapper for MediaInfo CLI

    Requirements:
        - MediaInfo CLI (https://mediaarea.net/en/MediaInfo/Download/Windows)
        - AutoHotkey v2.0 or later

    Usage:
        - For compiled scripts, declare the binary file's location first
        before parsing files.
        * Use MediaInfo.SetBinFile(). Default is set to bin\MediaInfo.exe

        To parse a media file, instantiate using MediaInfo().
        To access a specific property such as video resolution, use "Obj.GetVideoResolution".

        To view a raw data, use MediaInfo.Get(). This will return a JSON string.
        For full information, add a "True" flag on the 2nd argument.

    (c) 2022-2024 Ken Verdadero
    Written 2022-07-23
*/

#Include ../lib/Run.ahk
#Include ../lib/Path.ahk
#Include ../lib/Basic.ahk
#Include ../lib/JSON.ahk
#Include ../lib/Maps.ahk
#Include ../lib/Math.ahk

class MediaInfo {
    static BIN := 'bin\MediaInfo.exe'                                                       ;; Default bin location in libraries

    static SetBinFile(file) {
        /*  Sets a custom binary file for MediaInfo */
        if !FileExist(file) {
            throw Error("Binary file was not found", "SetBinFile", file)
        }
        MediaInfo.BIN := file
    }

    static Get(filename, full := false) {
        /*  Returns an information of the file  */
        SplitPath(MediaInfo.BIN, &BIN_FN, &DIR, , , &DRIVE)
        command := Format(
            'cd /d "{1}" && "{2}" {3} --output=JSON "{4}"',
            DIR, BIN_FN, (full ? '--full' : ''), filename
        )
        return RunWaitOne(command)
    }

    static _Parse(filename) => MapToObj(JSON.Load(MediaInfo.Get(filename)))                 ;; Returns an object containing all parsed data from raw JSON

    static _toHHMMSS(S) {
        DivMod(&H, &R, S, 3600)
        H := Format("{:02}", Floor(H))
        M := Format("{:02}", Floor(R * 60))
        S := Format("{:02}", Mod(S, 60),)
        MS := SubStr(A_TickCount, 5, -1)
        return Format("{1}:{2}:{3}", H, M, S, MS)
    }

    __New(filename) {
        this.__BIN := MediaInfo.BIN
        this.CheckBin()

        for k, v in MediaInfo._Parse(filename).OwnProps() {                                 ;; Apply all parsed data to the instance's props
            this.DefineProp(k, { value: v })
        }

        for i, e in this.media.track {                                                      ;; Define media tracks as this.MT[Number]
            this.DefineProp("MT" i, { value: e })
        }
    }

    CheckBin() {
        /*  Verifies the current binary file */
        if !FileExist(this.__BIN) {
            throw OSError("Binary file was not found.")
        }
    }

    _GetMT(track, query) {
        /*  Handles requests from retrieving media track data */
        try {
            return this.MT%track%[query]
        } catch Error as e {
            return 0                                                                        ;; Value returns 0 if track was not present
        }
    }

    /*  Library information */
    GetLibName() => this.creatingLibrary.name
    GetLibVersion() => this.creatingLibrary.version
    GetLibURL() => this.creatingLibrary.url
    GetFilePath() => this.media.amp_ref                                                     ;; @ref of the file

    /*  General media track */
    GetVideoCount() => this._GetMT(1, 'VideoCount')
    GetAudioCount() => this._GetMT(1, 'AudioCount')
    GetFileExt() => this._GetMT(1, 'FileExtension')
    GetFormat() => this._GetMT(1, 'Format')
    GetFormatProfile() => this._GetMT(1, 'Format_Profile')
    GetCodecID() => this._GetMT(1, 'CodecID')
    GetCodecIDCompatible() => this._GetMT(1, 'CodecID_Compatible')
    GetFileSize() => this._GetMT(1, 'FileSize')
    GetDuration(decimals := 0) => Round(this._GetMT(1, 'Duration'), decimals)                 ;; General Duration
    GetOverallBitRate() => this._GetMT(1, 'OverallBitRate')
    GetFrameRate() => this._GetMT(1, 'FrameRate')
    GetFrameCount() => this._GetMT(1, 'FrameCount')
    GetStreamSize() => this._GetMT(1, 'StreamSize')
    GetHeaderSize() => this._GetMT(1, 'HeaderSize')
    GetDataSize() => this._GetMT(1, 'DataSize')
    GetFooterSize() => this._GetMT(1, 'FooterSize')
    IsStreamable() => (this._GetMT(1, 'IsStreamable') = "Yes" ? 1 : 0)
    GetFileCreatedDateUTC() => this._GetMT(1, 'File_Created_Date')
    GetFileCreatedDate() => this._GetMT(1, 'File_Created_Date_Local')
    GetFileModifiedDateUTC() => this._GetMT(1, 'File_Modified_Date')
    GetFileModifiedDate() => this._GetMT(1, 'File_Modified_Date_Local')
    GetExtra() => this._GetMT(1, 'extra')

    /*  Video media track */
    GetVideoStreamOrder() => this._GetMT(2, 'StreamOrder')
    GetVideoID() => this._GetMT(2, 'ID')
    GetVideoFormat() => this._GetMT(2, 'Format')
    GetVideoFormatProfile() => this._GetMT(2, 'Format_Profile')
    GetVideoFormatLevel() => this._GetMT(2, 'Format_Level')
    GetVideoFormatSettingsCABAC() => this._GetMT(2, 'Format_Settings_CABAC')
    GetVideoFormatSettingsRefFrames() => this._GetMT(2, 'Format_Settings_RefFrames')
    GetVideoCodecID() => this._GetMT(2, 'CodecID')
    GetVideoDuration() => this._GetMT(2, 'Duration')                                              ;; Video Duration
    GetVideoBitRate() => this._GetMT(2, 'BitRate')
    GetVideoWidth() => this._GetMT(2, 'Width')
    GetVideoHeight() => this._GetMT(2, 'Height')
    GetVideoSampledWidth() => this._GetMT(2, 'Sampled_Width')
    GetVideoSampledHeight() => this._GetMT(2, 'Sampled_Height')
    GetVideoPixelAspectRatio() => this._GetMT(2, 'PixelAspectRatio')
    GetVideoDisplayAspectRatio() => this._GetMT(2, 'DisplayAspectRatio')
    GetVideoRotation() => this._GetMT(2, 'Rotation')
    GetVideoFrameRateMode() => this._GetMT(2, 'FrameRate_Mode')
    GetVideoFrameRateModeOriginal() => this._GetMT(2, 'FrameRate_Mode_Original')
    GetVideoFrameRate() => this._GetMT(2, 'FrameRate')
    GetVideoFrameCount() => this._GetMT(2, 'FrameCount')
    GetVideoColorSpace() => this._GetMT(2, 'ColorSpace')
    GetVideoChromaSubsampling() => this._GetMT(2, 'ChromaSubsampling')
    GetVideoBitDepth() => this._GetMT(2, 'BitDepth')
    GetVideoScanType() => this._GetMT(2, 'ScanType')
    GetVideoStreamSize() => this._GetMT(2, 'StreamSize')
    GetVideoEncodedLib() => this._GetMT(2, 'Encoded_Library')
    GetVideoEncodedLibName() => this._GetMT(2, 'Encoded_Library_Name')
    GetVideoEncodedLibVersion() => this._GetMT(2, 'Encoded_Library_Version')
    GetVideoEncodedLibSettings() => this._GetMT(2, 'Encoded_Library_Settings')
    VideoColorDescPresent() => (this._GetMT(2, 'colour_description_present') = "Yes" ? 1 : 0)
    GetVideoColorDescPresentSource() => this._GetMT(2, 'colour_description_present_Source')
    GetVideoColorRange() => this._GetMT(2, 'colour_range')
    GetVideoColorRangeSource() => this._GetMT(2, 'colour_range_Source')
    GetVideoColorPrimaries() => this._GetMT(2, 'colour_primaries')
    GetVideoColorPrimariesSource() => this._GetMT(2, 'colour_primaries_Source')
    GetVideoTransferCharacteristics() => this._GetMT(2, 'transfer_characteristics')
    GetVideoTransferCharacteristicsSource() => this._GetMT(2, 'transfer_characteristics_Source')
    GetVideoMatrixCoef() => this._GetMT(2, 'matrix_coefficients')
    GetVideoMatrixCoefSource() => this._GetMT(2, 'matrix_coefficients_Source')
    GetVideoExtra() => this._GetMT(2, 'extra')

    /*  Audio media track */
    GetAudioStreamOrder() => this._GetMT(3, 'StreamOrder')
    GetAudioID() => this._GetMT(3, 'ID')
    GetAudioFormat() => this._GetMT(3, 'Format')
    GetAudioFormatAddFeat() => this._GetMT(3, 'Format_AdditionalFeatures')
    GetAudioCodecID() => this._GetMT(3, 'CodecID')
    GetAudioDuration() => this._GetMT(3, 'Duration')                                              ;; Audio Duration
    GetAudioDurationLastFrame() => this._GetMT(3, 'Duration_LastFrame')
    GetAudioBitRateMode() => this._GetMT(3, 'BitRate_Mode')
    GetAudioBitRate() => this._GetMT(3, 'BitRate')
    GetAudioChannels() => this._GetMT(3, 'Channels')
    GetAudioChannelPositions() => this._GetMT(3, 'ChannelPositions')
    GetAudioChannelLayout() => this._GetMT(3, 'ChannelLayout')
    GetAudioSamplesPerFrame() => this._GetMT(3, 'SamplesPerFrame')
    GetAudioSamplingRate() => this._GetMT(3, 'SamplingRate')
    GetAudioSamplingCount() => this._GetMT(3, 'SamplingCount')
    GetAudioFrameRate() => this._GetMT(3, 'FrameRate')
    GetAudioFrameCount() => this._GetMT(3, 'FrameCount')
    GetAudioCompressionMode() => this._GetMT(3, 'Compression_Mode')
    GetAudioStreamSize() => this._GetMT(3, 'StreamSize')
    GetAudioStreamSizeProportion() => this._GetMT(3, 'StreamSize_Proportion')
    GetAudioDefault() => (this._GetMT(3, 'StreamSize_Proportion') = "Yes" ? 1 : 0)
    GetAudioAlternateGroup() => this._GetMT(3, 'AlternateGroup')

    /*  Simplified data */
    GetAllDuration() {
        return [this.GetDuration(), this.GetVideoDuration(), this.GetAudioDuration()]
    }
    GetVideoResolution() => this.GetVideoWidth() 'x' this.GetVideoHeight()
    GetFileName() => PathTrunc(this.GetFilePath(), -1)
    GetFileDir() => PathTrunc(this.GetFilePath(), 1, -2)
    GetFileDrive() => PathTrunc(this.GetFilePath(), 1, 1)
    GetFileSizeFormatted(decimals := 2) => DataUnit(this.GetFileSize(), 'B', 'auto', decimals)
    GetDurationFormatted() => MediaInfo._toHHMMSS(Round(this.GetDuration()))
    GetVideoBitRateFormatted(unit := 'auto', decimals := 0) {
        return DataUnit(this.GetVideoBitRate(), 'B', unit, decimals, , 1)
    }
    GetOverallBitRateFormatted(unit := 'auto', decimals := 0) {
        return DataUnit(this.GetOverallBitRate(), 'B', unit, decimals, , 1)
    }
}