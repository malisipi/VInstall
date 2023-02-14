module vinstall

import mui
import json
import os

pub struct UninstallerData {
    app_name        string
    install_path    string
mut:
    files           []string
    shortcuts       []string
}

fn get_uninstall_dat()! UninstallerData {
    return json.decode(UninstallerData, os.read_file(os.abs_path("uninstall.dat"))or{"."})!
}

pub fn uninstall() bool {
    uninstaller_dat := get_uninstall_dat() or {
        mui.messagebox("Uninstaller", "uninstall.dat not found!", "ok", "error")
        return false
    }
    if mui.messagebox("${uninstaller_dat.app_name} - Uninstaller", "Do you want to uninstall?", "yesno", "warning") == 1 {
        for temp_file in uninstaller_dat.files {
            file:="${uninstaller_dat.install_path}/${temp_file}"
            os.rm(file) or {
                os.rmdir_all(file) or {}
            }
        }
        for file in uninstaller_dat.shortcuts {
            os.rm(file) or {}
        }
        return true
    } else {
        return false
    }
    return true
}
