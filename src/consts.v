module vinstall

import os

pub const (
	is_root = get_is_root()
	
	path_desktop = $if windows {
		'${os.getenv("USERPROFILE")}/Desktop'
	} $else {
		os.execute("xdg-user-dir DESKTOP").output.replace("\n","")
	}
	executable_ext = $if windows { "exe" } $else { "out" }
	
	path_app_menu = get_path_app_menu()
	path_program_files = get_path_program_files()
)

fn get_is_root() bool {
	return $if linux {
		C.geteuid() == 0
	} $else {
		false
	}
}

fn get_path_app_menu() string {
	return $if windows {
		'${os.getenv("AppData")}/Microsoft/Windows/Start Menu/Programs'
	} $else {
		if !is_root {
			'${os.getenv("HOME")}/.local/share/applications'
		} else {
			'/usr/share/local'
		}
	}
}

fn get_path_program_files() string {
	return $if windows {
		"C:/Program Files"
	} $else {
		if is_root {
			"/opt"
		} else {
			'${os.getenv("HOME")}/opt'
		}
	}
}
