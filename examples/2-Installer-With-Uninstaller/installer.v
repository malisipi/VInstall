import malisipi.vinstall

vinstall.run(
    app_developer: "developer",
    app_name: "AppName",
    install_path:"C:/Program Files/MyAppName",
    license_txt: $embed_file('license.txt'),
    app_zip: $embed_file('app.zip'),
    executable_path: "app.exe",
    desktop_shortcut: true,
    uninstaller: $embed_file('uninstaller.exe')
)!
