# AHKMisc

Libraries, tools, and other fun stuff I made with AutoHotkey v2.

## Why

When I started using AHK, I felt like I was missing some functions that I was used to from other languages like Python and Javascript.

These libraries are not the most efficient way to do things in AHK, and there are many [other libraries](#resources) that perform the same tasks but more effectively. I made this to get a grasp of the language and see what I can do with it.

## Requirements and Usage

- You need to have AutoHotkey v2.0 (or later) installed. You can download it from [here](https://www.autohotkey.com/download).

1. Clone the repository or download from [releases](https://github.com/verdaderoken/AHKMisc/releases).

   ```
   git clone https://github.com/verdaderoken/AHKMisc.git
   ```

2. Include the library you want to use.

   ```autohotkey
   #Include <LibFileName>
   ```

3. Refer to the documentation in the source code.

## Libraries

Some libraries depend on other libraries. Please check the source code for more information.

| Library                    | Description                                                      | Has Dependencies |
| -------------------------- | ---------------------------------------------------------------- | ---------------- |
| [7Zip](lib/7zip.ahk)       | A wrapper for 7z archives                                        | Yes              |
| [Arrays](lib/Arrays.ahk)   | Extended array functions like `ArrayMatch()` and `ArrayFilter()` |                  |
| [Basic](lib/Basic.ahk)     | More basic functions like `Print()` and `Len()`                  | Yes              |
| [Dir](lib/Dir.ahk)         | Directory functions                                              |                  |
| [File](lib/File.ahk)       | File functions                                                   |                  |
| [Format](lib/Format.ahk)   | Format functions                                                 | Yes              |
| [Hotkeys](lib/Hotkeys.ahk) | Hotkey functions                                                 |                  |
| [JSON](lib/JSON.ahk)       | JSON serializer and deserializer                                 |                  |
| [Keys](lib/Keys.ahk)       | List of keys and key groups                                      | Yes              |
| [Maps](lib/Maps.ahk)       | Extended map functions                                           |                  |
| [Math](lib/Math.ahk)       | Additional math functions                                        |                  |
| [Path](lib/Path.ahk)       | Path functions                                                   | Yes              |
| [Run](lib/Run.ahk)         | Run functions                                                    |                  |
| [Strings](lib/Strings.ahk) | Extended string functions                                        | Yes              |
| [Timer](lib/Timer.ahk)     | Class-based AHK Timer                                            |                  |
| [URI](lib/URI.ahk)         | URI functions                                                    |                  |
| [Window](lib/Window.ahk)   | Window functions                                                 |                  |

## Tools

Some tools use the libraries above. Please check the source code for more information.

| Library                                        | Description                                      |
| ---------------------------------------------- | ------------------------------------------------ |
| [AdobePremierePro](tools/AdobePremierePro.ahk) | A very simple wrapper for Adobe Premiere Pro     |
| [AntiGhostKey](tools/AntiGhostKey.ahk)         | A pseudo-ghost key prevention script             |
| [MediaInfo](tools/MediaInfo.ahk)               | Get media file information (similar to FFprobe)  |
| [NumpadBind](tools/NumpadBind.ahk)             | Bind numpad keys to number row for TKL keyboards |
| [Piano](tools/Piano.ahk)                       | Play piano with your keyboard                    |

## Development

I won't be actively maintaining this repository, but I will continue to welcome pull requests and issues. This repository is here for anyone who wants to learn from it or use it as a reference.

## Resources

- [AutoHotkey v2 Documentation](https://www.autohotkey.com/docs/v2/)
- [AutoHotkey Wiki](https://autohotkey.wiki/start)

Other repositories worth checking out:

- [awesome-AutoHotkey](https://github.com/ahkscript/awesome-AutoHotkey)
- [AHK v2 Libraries by Descolada](https://github.com/Descolada/AHK-v2-libraries)

---

AHKMisc © 2024 [Ken Verdadero](https://kenverdadero.com). MIT License
