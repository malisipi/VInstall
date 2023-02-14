module vinstall

import os

pub struct ShortcutConfig {
mut:
	installer_data	InstallerData
	app_location	string //as relative
	file_name		string //without extensions like .lnk
	location		ShortcutLocation
	description		string
}

pub enum ShortcutLocation {
	desktop
	app_menu	//aka program list
}

fn utf8_to_ascii(utf8 string) string {
	return utf8.replace("ı",'"& Chr(253) &"').replace("ş",'"& Chr(254) &"').replace("İ",'"& Chr(221) &"').replace("Ş",'"& Chr(222) &"').replace("ğ",'"& Chr(240) &"').replace("Ğ",'"& Chr(208) &"').replace("ç",'"& Chr(231) &"').replace("Ç",'"& Chr(199) &"').replace("ö",'"& Chr(246) &"').replace("Ö",'"& Chr(214) &"').replace("ü",'"& Chr(252) &"').replace("Ü",'"& Chr(220) &"')
}

pub fn make_shortcut(params ShortcutConfig){
	$if windows {
		mut app_location := params.app_location
		mut file_name := params.file_name
		if app_location == "" {
			app_location = params.installer_data.parameters.executable_path
		}
		if file_name == "" {
			file_name = params.installer_data.parameters.app_name
		}
		file_name += ".lnk"
		mut location := ""
		if params.location == .desktop {
			location = '${os.getenv("USERPROFILE")}/Desktop/'
		} else {
			location = '${os.getenv("AppData")}/Microsoft/Windows/Start Menu/Programs/'
		}
		app_exe_location := "${params.installer_data.user_decided_install_path}/${app_location}"
		vbs_file := "${os.temp_dir()}/installer_shortcut.vbs"
		os.write_file(vbs_file, utf8_to_ascii('Set shell = WScript.CreateObject("WScript.Shell")
Set shortcut = shell.CreateShortcut("${location}${file_name}")
shortcut.TargetPath = "${app_exe_location}"
shortcut.Description = "${params.description}"
shortcut.WorkingDirectory = "${app_exe_location#[0..-os.file_name(app_exe_location).len]}"
shortcut.Save')) or { return }
		os.system("wscript.exe \"${vbs_file}\"")
		//os.rm(vbs_file) or {}
	}
	return
}
