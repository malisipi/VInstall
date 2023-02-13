module vinstall

import malisipi.mui
import szip
import os
import rand
import v.embed_file

pub struct InstallerParameters {
    app_developer       string                      = "unknown"
    app_name            string                      = "unknown_app"
    install_path        string                      = os.temp_dir()
    license_txt         embed_file.EmbedFileData    = embed_file.EmbedFileData {uncompressed:&[]u8{}}
    app_zip             embed_file.EmbedFileData    = embed_file.EmbedFileData {uncompressed:&[]u8{}}
}

struct InstallerData {
    parameters  InstallerParameters
    temp_file   string
}

fn install(event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
    unsafe {
        if !app.get_object_by_id("accept_license")[0]["c"].bol {
            mui.messagebox("${app_data.parameters.app_name} - Installer", "You need to accept the license terms before install", "ok", "warning")
            return
        } else {
            install_path:=app.get_object_by_id("install_path")[0]["text"].str.replace("\0","")
            if !os.exists(install_path){
                os.mkdir(install_path) or {
                    mui.messagebox("${app_data.parameters.app_name} - Installer", "You need permission to install the path\n* Run As Administrator\n* Install Non-Readonly Folder", "ok", "error")
                    return
                }
            }
            szip.extract_zip_to_dir(app_data.temp_file, install_path) or {
                mui.messagebox("${app_data.parameters.app_name} - Installer", "Install File Was Corrupted", "ok", "error")
                return
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

    os.write_file(temp_file,params.app_zip.to_string()) or {
        mui.messagebox("${params.app_name} - Installer", "Unable to extract required files", "ok", "error") return
    }

    mut app:=mui.create(title:"${params.app_name} - Installer", draw_mode:.system_native, app_data: &InstallerData{parameters:params, temp_file: temp_file})
    app.textarea(id:"license", x:50, y:50, width:"100%x -115", height: "100%y -180", text:params.license_txt.to_string())
    app.scrollbar(id:"license_scroll", x:"# 50", y:50, width:15, height: "100%y -180", connected_widget:app.get_object_by_id("license")[0], vertical:true)
    app.checkbox(id:"accept_license", x:50, y:"# 90", text:"I accept the license terms", width:20, height:20)
    app.textbox(id:"install_path", x:50, y:"# 50", height:20, width:"100%x -310", text:params.install_path)
    app.button(id:"install_change_path", x:"# 130", y:"# 50", width: 125, height: 20, text:"Select Folder", onclick:select_folder)
    app.button(id:"install", x:"# 50", y:"# 50", width: 75, height: 20, text:"Install", onclick:install)
    app.label(id:"developer_info", x:20, y:"# 20", width:"100%x -140", height:20, text:"${params.app_name} from ${params.app_developer}", text_align:0)
    app.link(id:"installer_info", x:"# 20", y:"# 20", width:"100", height:20, text:"VInstall", link:"https://github.com/malisipi/VInstall")
    app.run()

    os.rm(temp_file)!
}
