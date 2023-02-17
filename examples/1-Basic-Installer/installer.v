import malisipi.vinstall

vinstall.run(
    app_developer: "developer",
    app_name: "AppName",
    install_path:"${vinstall.path_program_files}/MyAppName",
    license_txt: $embed_file('license.txt'),
    app_zip: $embed_file('app.zip')
)!
