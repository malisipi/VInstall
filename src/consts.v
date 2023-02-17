module vinstall

import os

pub const (
	path_desktop = $if windows {
		'${os.getenv("USERPROFILE")}/Desktop/'
	} $else { '000' }
	
	path_app_menu = $if windows {
		'${os.getenv("AppData")}/Microsoft/Windows/Start Menu/Programs/'
	} $else { '000' }
	
	path_program_files = $if windows {
		"C:/Program Files"
	} $else {
		"/opt"
	}
)
