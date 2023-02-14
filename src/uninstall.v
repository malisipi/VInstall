module vinstall

import mui
import json
import os
import rand

pub struct UninstallerData {
    app_name        string
    install_path    string
mut:
    files           []string
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
        for file in uninstaller_dat.files {
            os.rm(file) or {
                os.rmdir_all(file) or {}
            }
        }
        return true
    } else {
        return false
    }
    return true
}
