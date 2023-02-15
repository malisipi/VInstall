module vinstall

import json
import os

struct LimitedTranslation{
    uninstaller   string
    ask_uninstall string
}

pub struct UninstallerData {
    app_name        string
    install_path    string
    limited_translation    LimitedTranslation
mut:
    files           []string
    shortcuts       []string
}

fn C.MessageBoxW(int, &u16, &u16, int) int

fn get_uninstall_dat()! UninstallerData {
    return json.decode(UninstallerData, os.read_file(os.abs_path("uninstall.dat"))or{"."})!
}

pub fn uninstall() bool {
    uninstaller_dat := get_uninstall_dat() or {
        C.MessageBoxW(C.NULL, "uninstall.dat not found!".to_wide(), "Uninstaller".to_wide(), C.MB_ICONERROR | C.MB_OK | C.MB_DEFBUTTON1 | C.MB_TOPMOST)
        return false
    }
    if C.MessageBoxW(C.NULL, uninstaller_dat.limited_translation.ask_uninstall.to_wide(), "${uninstaller_dat.app_name} - ${uninstaller_dat.limited_translation.uninstaller}".to_wide(), C.MB_ICONWARNING | C.MB_YESNO | C.MB_DEFBUTTON2 | C.MB_TOPMOST) == C.IDYES {
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
