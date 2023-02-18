module main

import malisipi.vinstall

fn main(){
	vinstall.run(
	    app_developer: "developer",
	    app_name: "AppName",
	    install_path:"${vinstall.path_program_files}/MyAppName",
	    license_txt: $embed_file('license.txt'),
	    app_zip: $embed_file('app.zip'),
	    executable_path: executable_path,
	    desktop_shortcut: true,
	    uninstaller: uninstaller
	)!
}
