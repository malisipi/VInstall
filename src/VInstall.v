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
}

pub struct InstallerData {
    parameters  InstallerParameters
    temp_file   string
    temp_folder string
mut:
    user_decided_install_path string
}

fn install(event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    unsafe {
        if !app.get_object_by_id("accept_license")[0]["c"].bol {
            mui.messagebox("${app_data.parameters.app_name} - Installer", "You need to accept the license terms before install", "ok", "warning")
            return
        } else {
            app_data.user_decided_install_path = app.get_object_by_id("install_path")[0]["text"].str.replace("\0","")
            if os.exists(app_data.user_decided_install_path){
                os.rmdir_all(app_data.user_decided_install_path) or {
                    mui.messagebox("${app_data.parameters.app_name} - Installer", "You need permission to install the path\n* Run As Administrator\n* Install Non-Readonly Folder", "ok", "error")
                    return
                }
            }
            os.mkdir(app_data.temp_folder) or {}
            szip.extract_zip_to_dir(app_data.temp_file, app_data.temp_folder) or { //unicode file path bug on Windows by szip
                mui.messagebox("${app_data.parameters.app_name} - Installer", "Install File Was Corrupted", "ok", "error")
                return
            }
            os.mv(app_data.temp_folder, app_data.user_decided_install_path) or {
                mui.messagebox("${app_data.parameters.app_name} - Installer", "You need permission to install the path\n* Run As Administrator\n* Install Non-Readonly Folder", "ok", "error")
                os.rmdir_all(app_data.temp_folder) or {}
                return
            }
            mut uninstaller_dat:=UninstallerData{
                app_name: app_data.parameters.app_name,
                install_path: app_data.user_decided_install_path,
                files: os.ls(app_data.user_decided_install_path) or {[]string{}}
            }
            uninstaller_dat.files << "uninstall.dat"
            os.write_file("${app_data.user_decided_install_path}/uninstall.dat", json.encode(uninstaller_dat)) or {
                mui.messagebox("${app_data.parameters.app_name} - Installer", "Uninstaller data creation was failed", "ok", "warning")
                println("")
            }
            os.write_file("${app_data.user_decided_install_path}/uninstaller.exe", app_data.parameters.uninstaller.to_string()) or {
                mui.messagebox("${app_data.parameters.app_name} - Installer", "Uninstaller creation was failed", "ok", "warning")
                println("")
            }

            if app_data.parameters.executable_path != "" {
                if app.get_object_by_id("shortcut_app_menu")[0]["c"].bol {
                    make_shortcut(installer_data: app_data, location:.app_menu)
                }
                if app.get_object_by_id("shortcut_desktop")[0]["c"].bol {
                    make_shortcut(installer_data: app_data, location:.desktop)
                }
            }
            mui.messagebox("${app_data.parameters.app_name} - Installer", "Installed!", "ok", "info")
            app.destroy()
        }
    }
}

fn select_folder(event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    unsafe {
        selected_folder:=mui.selectfolderdialog("${app_data.parameters.app_name} - Installer").replace("\\","/")
        if selected_folder!="" {
            app.get_object_by_id("install_path")[0]["text"].str = selected_folder
        }
    }
}

pub fn run(params InstallerParameters)!{
    id:=rand.i64n(100000000)!
    temp_file:="${os.temp_dir()}/installer_${id}_temp.part"
    temp_folder:="C:/.installer_${id}_temp"

    os.write_file(temp_file,params.app_zip.to_string()) or {
        mui.messagebox("${params.app_name} - Installer", "Unable to extract required files", "ok", "error") return
    }

    mut app:=mui.create(title:"${params.app_name} - Installer", draw_mode:.system_native, ask_quit:true, app_data: &InstallerData{parameters:params, temp_file: temp_file, temp_folder: temp_folder})
    app.textarea(id:"license", x:50, y:50, width:"100%x -115", height: "100%y -180", text:params.license_txt.to_string())
    app.scrollbar(id:"license_scroll", x:"# 50", y:50, width:15, height: "100%y -180", connected_widget:app.get_object_by_id("license")[0], vertical:true)
    app.checkbox(id:"accept_license", x:50, y:"# 105", text:"I accept the license terms", width:20, height:20)
    if params.executable_path != "" {
        app.checkbox(id:"shortcut_app_menu", x:50, y:"# 75", text:"App Menu Shortcut", width:20, height:20, checked:params.app_menu_shortcut)
        app.checkbox(id:"shortcut_desktop", x:"50%x", y:"# 75", text:"Desktop Shortcut", width:20, height:20, checked:params.desktop_shortcut)
    }
    app.textbox(id:"install_path", x:50, y:"# 50", height:20, width:"100%x -310", text:params.install_path)
    app.button(id:"install_change_path", x:"# 130", y:"# 50", width: 125, height: 20, text:"Select Folder", onclick:select_folder)
    app.button(id:"install", x:"# 50", y:"# 50", width: 75, height: 20, text:"Install", onclick:install)
    app.label(id:"developer_info", x:20, y:"# 20", width:"100%x -140", height:20, text:"${params.app_name} from ${params.app_developer}", text_align:0)
    app.link(id:"installer_info", x:"# 20", y:"# 20", width:"100", height:20, text:"VInstall", link:"https://github.com/malisipi/VInstall")
    app.run()

    os.rm(temp_file)!
}
