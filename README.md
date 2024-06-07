# VInstall *- A Cross-Platform Installer Creator*

![VInstall](./assets/vinstall.png)

## How to Use?

* Get V compiler from [vlang.io](https://vlang.io/)
* Install MUI library `v install malisipi.mui`
* Instal (the) VInstall library `v install malisipi.VInstall`
* And create some installers
* Resource file support

Basic Installer:

```v
import malisipi.vinstall

vinstall.run(
    app_developer: "developer",
    app_name: "AppName",
    install_path:"C:/Program Files/MyAppName",
    license_txt: $embed_file('license.txt'),
    app_zip: $embed_file('app.zip'),
    executable_path: "app.exe"
)!
```

## Properties

* Integrate with V applications
* Support for Windows 7 & above
* Support for Linux
* Single executable for distirbuting
* Shortcut Support
* Uninstall Capabilities
* Dark Mode Support
* Multilingual Support (English / Turkish / Russian / German / French / Spanish / Chinese)

> Some translations was done with Translate. This translations can be missing as grammar and spelling. Let me know if a translation is wrong.

Note: You need to add `-d extended_language_support` flag to support Chinese. Some of operating systems will not have Chinese font, so font must be included into installer however it will make larger the installer. So the choose was gived to developer.

Note: If you need to save files at installation location, you need to add `-d dont_delete_install_location_files`. Also it's not recommend to use VInstall' Uninstaller, it will wipe entire folder that you chosed as installation location.

Note: To make the installer smaller, you can compress them with UPX.

TODO:

* MacOS support
* Portable install support
* Support downloading install file
* Creation of registry (for Windows) and .INI entries
* Support for passworded and encrypted installs

## Thirdparty

* [MUI](https://github.com/malisipi/mui) (UI-Library) - Licensed with Apache 2.0

## Thanks to V-language for Mention

[![V-language](./assets/vlang_mention.png)](https://twitter.com/v_language/status/1625482422174228486)

## License

* This library licensed with Apache License 2.0.
* Also `assets/Icons` licensed with Apache License 2.0.
