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
	return utf8.replace("ı",'"& Chr(253) &"')
		.replace("ş",'"& Chr(254) &"')
		.replace("İ",'"& Chr(221) &"')
		.replace("Ş",'"& Chr(222) &"')
		.replace("ğ",'"& Chr(240) &"')
		.replace("Ğ",'"& Chr(208) &"')
		.replace("ç",'"& Chr(231) &"')
		.replace("Ç",'"& Chr(199) &"')
		.replace("ö",'"& Chr(246) &"')
		.replace("Ö",'"& Chr(214) &"')
		.replace("ü",'"& Chr(252) &"')
		.replace("Ü",'"& Chr(220) &"')
		.replace("é",'"& Chr(233) &"')
		.replace("É",'"& Chr(201) &"')
}

pub fn make_shortcut(params ShortcutConfig) string {
	mut app_location := params.app_location
	mut file_name := params.file_name
	
	if app_location == "" {
		app_location = params.installer_data.parameters.executable_path
	}
	
	if file_name == "" {
		file_name = params.installer_data.parameters.app_name
	}
	
	mut location := ""
	if params.location == .desktop {
		location = path_desktop
	} else {
		location = path_app_menu
	}
	
	shortcut_file_ext := $if windows {
		".lnk"
	} $else {
		".desktop"
	}
	
	shortcut_location := "${location}/${file_name}${shortcut_file_ext}"
	app_exe_location := "${params.installer_data.user_decided_install_path}/${app_location}"
	working_dir := app_exe_location#[0..-os.file_name(app_exe_location).len]
	
	$if windows {
		vbs_file := "${os.temp_dir()}/installer_shortcut.vbs"
		os.write_file(vbs_file, utf8_to_ascii('Set shell = WScript.CreateObject("WScript.Shell")
Set shortcut = shell.CreateShortcut("${shortcut_location}")
shortcut.TargetPath = "${app_exe_location}"
shortcut.Description = "${params.description}"
shortcut.WorkingDirectory = "${working_dir}"
shortcut.Save')) or { return "" }
		os.system("wscript.exe \"${vbs_file}\"")
		os.rm(vbs_file) or {}
		
	} $else {
	     
	     os.write_file(shortcut_location, '[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Terminal=false
Exec=${app_exe_location}
Path=${working_dir}
Name=${file_name}') or {} //TODO: Add `Icon=/path/to/icon`
	     
	}
	
	return shortcut_location
}
