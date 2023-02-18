module vinstall

import malisipi.mui
import szip
import os
import rand
import v.embed_file
import json

pub struct InstallerParameters {
    app_developer       string                      = "unknown"
    app_name            string                      = "unknown_app"
    install_path        string                      = os.temp_dir()
    license_txt         embed_file.EmbedFileData    = embed_file.EmbedFileData {uncompressed:&[]u8{}}
    app_zip             embed_file.EmbedFileData    = embed_file.EmbedFileData {uncompressed:&[]u8{}}
    uninstaller         embed_file.EmbedFileData    = embed_file.EmbedFileData {uncompressed:&[]u8{}}
    executable_path     string
    desktop_shortcut    bool
    app_menu_shortcut   bool
    default_language    string                      = "English"
}

pub struct InstallerData {
    parameters  InstallerParameters
    temp_file   string
    temp_folder string
mut:
    user_decided_install_path string
    active_language_pack      &Translation = &translation_english
}

fn install(event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    unsafe {
        if !app.get_object_by_id("accept_license")[0]["c"].bol {
            mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.require_accept_license, "ok", "warning")
            return
        } else {
            app_data.user_decided_install_path = app.get_object_by_id("install_path")[0]["text"].str.replace("\0","")
            if os.exists(app_data.user_decided_install_path){
                os.rmdir_all(app_data.user_decided_install_path) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.readonly_error, "ok", "error")
                    return
                }
            }
            $if windows { //unicode file path bug on Windows by szip
            	os.mkdir(app_data.temp_folder) or {}
                szip.extract_zip_to_dir(app_data.temp_file, app_data.temp_folder) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.install_file_corrupt, "ok", "error")
                    return
                }
                os.mv(app_data.temp_folder, app_data.user_decided_install_path) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.readonly_error, "ok", "error")
                    os.rmdir_all(app_data.temp_folder) or {}
                    return
		        }
            } $else {
                os.mkdir_all(app_data.user_decided_install_path) or {}
                szip.extract_zip_to_dir(app_data.temp_file, app_data.user_decided_install_path) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.install_file_corrupt, "ok", "error")
                    return
                }
            }
            mut uninstaller_dat:=UninstallerData{
                is_root: is_root
                app_name: app_data.parameters.app_name,
                install_path: app_data.user_decided_install_path,
                files: os.ls(app_data.user_decided_install_path) or {[]string{}}
                limited_translation: LimitedTranslation{
                    uninstaller: app_data.active_language_pack.uninstaller
                    ask_uninstall: app_data.active_language_pack.ask_uninstall
                }
            }
            uninstaller_dat.files << "uninstall.dat"
            $if !windows {
            	uninstaller_dat.files << "uninstaller.${executable_ext}"
            }

            if app_data.parameters.executable_path != "" {
                if app.get_object_by_id("shortcut_app_menu")[0]["c"].bol {
                    uninstaller_dat.shortcuts << make_shortcut(installer_data: app_data, location:.app_menu)
                    uninstaller_dat.shortcuts << make_shortcut(installer_data: app_data, location:.app_menu, app_location:"uninstaller.${executable_ext}", file_name:"${app_data.parameters.app_name} - ${app_data.active_language_pack.uninstaller}", description:"${app_data.parameters.app_name} - ${app_data.active_language_pack.uninstaller}")
                }
                if app.get_object_by_id("shortcut_desktop")[0]["c"].bol {
                    uninstaller_dat.shortcuts << make_shortcut(installer_data: app_data, location:.desktop)
                }
            }

            if app_data.parameters.uninstaller.to_string().len > 0 {
                os.write_file("${app_data.user_decided_install_path}/uninstall.dat", json.encode(uninstaller_dat)) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.uninstall_dat_error, "ok", "warning")
                    println("")
                }
                os.write_file("${app_data.user_decided_install_path}/uninstaller.${executable_ext}", app_data.parameters.uninstaller.to_string()) or {
                    mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.uninstall_exe_error, "ok", "warning")
                    println("")
                }
                $if !windows {
                    os.chmod("${app_data.user_decided_install_path}/uninstaller.${executable_ext}", 0o755) or {
                        mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", app_data.active_language_pack.uninstall_exe_error, "ok", "warning")
                        println("")
                    }
                }
            }
            mui.messagebox("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}", "${app_data.active_language_pack.installed}", "ok", "info")
            app.destroy()
        }
    }
}

fn select_folder(event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    unsafe {
        selected_folder:=mui.selectfolderdialog("${app_data.parameters.app_name} - ${app_data.active_language_pack.installer}").replace("\\","/")
        if selected_folder!="" {
            app.get_object_by_id("install_path")[0]["text"].str = selected_folder
        }
    }
}

pub fn run(params InstallerParameters)!{
    id:=rand.i64n(100000000)!
    temp_file:="${os.temp_dir()}/installer_${id}_temp.part"
    temp_folder:=$if windows {
        "C:/.installer_${id}_temp"
    } $else {
        ""
    }
    
    os.write_file(temp_file,params.app_zip.to_string()) or {
        mui.messagebox("${params.app_name} - Installer", "Unable to extract required files", "ok", "error") return
    }

    mut app_data := InstallerData{parameters:params, temp_file: temp_file, temp_folder: temp_folder}
    mut app := mui.create(title:"${params.app_name} - Installer", draw_mode:.system_native, ask_quit:true, app_data: &app_data, init_fn: fn (event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    	change_language(mui.EventDetails{value:app_data.parameters.default_language}, mut app, mut app_data) //load default language
    })
    app.selectbox(id:"language", x:"# 20", y:20, width:120, height:20 list: supported_languages, onchange: change_language, text:params.default_language)
    app.textarea(id:"license", x:50, y:50, width:"100%x -115", height: "100%y -180", text:params.license_txt.to_string())
    app.scrollbar(id:"license_scroll", x:"# 50", y:50, width:15, height: "100%y -180", connected_widget:app.get_object_by_id("license")[0], vertical:true)
    app.checkbox(id:"accept_license", x:50, y:"# 105", width:20, height:20)
    if params.executable_path != "" {
        app.checkbox(id:"shortcut_app_menu", x:50, y:"# 75", width:20, height:20, checked:params.app_menu_shortcut)
        app.checkbox(id:"shortcut_desktop", x:"50%x", y:"# 75",width:20, height:20, checked:params.desktop_shortcut)
    }
    app.textbox(id:"install_path", x:50, y:"# 50", height:20, width:"100%x -310", text:params.install_path)
    app.button(id:"install_change_path", x:"# 130", y:"# 50", width: 125, height: 20,onclick:select_folder)
    app.button(id:"install", x:"# 50", y:"# 50", width: 75, height: 20,onclick:install)
    app.label(id:"app_info", x:20, y:"# 20", width:"100%x -140", height:20, text_align:0)
    app.link(id:"installer_info", x:"# 20", y:"# 20", width:"100", height:20, text:"VInstall", link:"https://github.com/malisipi/VInstall")

    app.run()

    os.rm(temp_file)!
}
