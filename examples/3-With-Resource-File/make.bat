windres installer.rc -O coff -o installer.res
windres uninstaller.rc -O coff -o uninstaller.res
v -skip-unused uninstaller.v
v -skip-unused installer.v
pause