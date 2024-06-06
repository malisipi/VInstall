module vinstall

import mui

pub const (
	supported_languages = $if extended_language_support? {
			["English", "French", "German", "Russian", "Spanish", "Turkish", "Chinese"]
		} $else {
			["English", "French", "German", "Russian", "Spanish", "Turkish"]
		}
	translation_english = Translation{}
	translation_turkish = Translation{
		accept_license			: "Lisans şartlarını kabul ediyorum"
		select_folder			: "Klasör Seçin"
		install					: "Yükle"
		installer				: "Yükleyici"
		shortcut_app_menu		: "Uygulama Menü Kısayolu"
		shortcut_desktop		: "Masaüstü Kısayolu"
		app_info				: "%developer tarafından %app"
		require_accept_license	: "Yüklemeden önce lisans şartlarını kabul etmelisiniz"
		uninstall_dat_error		: "Kaldırıcı verisi oluşturulamadı"
		uninstall_exe_error		: "Kaldırıcı oluşturulamadı"
		readonly_error			: "Bu dizini yükleyebilmek için izine ihtiyacınız var\n* Yönetici olarak çalıştırın\n* Salt okunur olmayan bir klasöre yükleyin"
		install_file_corrupt	: "Yükleme dosyası bozulmuş"
		uninstaller				: "Kaldırıcı"
		installed				: "Yüklendi!"
		ask_uninstall			: "Kaldırmak istiyor musunuz?"
	}
	translation_russian = Translation{
		accept_license			: "Я принимаю условия лицензии"
		select_folder			: "Выберите папку"
		install					: "Установить"
		installer				: "Установщик"
		shortcut_app_menu		: "Ярлык меню приложения"
		shortcut_desktop		: "Ярлык рабочего стола"
		app_info				: "%app от %developer"
		require_accept_license	: "Перед установкой необходимо принять условия лицензии"
		uninstall_dat_error		: "Не удалось создать данные деинсталлятора"
		uninstall_exe_error		: "Не удалось создать деинсталлятор"
		readonly_error			: "Вам нужно разрешение для установки пути\n* Запустить от имени администратора\n* Установить папку не только для чтения"
		install_file_corrupt	: "Файл установки был поврежден"
//		uninstaller				: "Деинсталлятор"
		installed				: "Установлен!"
		ask_uninstall			: "Вы хотите удалить?"
	}
	translation_german = Translation{
		accept_license			: "Ich akzeptiere die Lizenzbedingungen"
		select_folder			: "Ordner auswählen"
		install					: "Installieren"
		installer				: "Installateur"
		shortcut_app_menu		: "App-Menü-Verknüpfung"
		shortcut_desktop		: "Desktop-Verknüpfung"
		app_info				: "%app von %developer"
		require_accept_license	: "Sie müssen die Lizenzbedingungen vor der Installation akzeptieren"
		uninstall_dat_error		: "Die Erstellung der Deinstallationsdaten war fehlgeschlagen"
		uninstall_exe_error		: "Die Erstellung des Deinstallationsprogramms ist fehlgeschlagen"
		readonly_error			: "Sie benötigen die Berechtigung, den Pfad zu installieren\n* Als Administrator ausführen\n* Installieren Sie den nicht schreibgeschützten Ordner"
		install_file_corrupt	: "Installationsdatei war beschädigt"
		uninstaller				: "Deinstallierer"
		installed				: "Eingerichtet!"
		ask_uninstall			: "Möchten Sie deinstallieren?"
	}
	translation_french = Translation{
		accept_license			: "J`accepte les conditions d`utilisation"
		select_folder			: "Sélectionner le dossier"
		install					: "Installer"
		installer				: "Installateur"
		shortcut_app_menu		: "Raccourci du menu de l`application"
		shortcut_desktop		: "Raccourci de bureau"
		app_info				: "%app de %developer"
		require_accept_license	: "Vous devez accepter les termes de la licence avant l`installation"
		uninstall_dat_error		: "La création des données du programme de désinstallation a échoué"
		uninstall_exe_error		: "La création du programme de désinstallation a échoué"
		readonly_error			: "Vous avez besoin d``une autorisation pour installer le chemin,\n* Exécuter en tant qu`administrateur\n* Installer le dossier non en lecture seule"
		install_file_corrupt	: "Le fichier d`installation a été corrompu"
		uninstaller				: "Programme de désinstallation"
		installed				: "Installé!"
		ask_uninstall			: "Voulez-vous désinstaller?"
	}
	translation_spanish = Translation{
		accept_license			: "Acepto los términos de licencia"
		select_folder			: "Seleccione la carpeta"
		install					: "Instalar"
		installer				: "Instalador"
		shortcut_app_menu		: "Atajo del menú de la aplicación"
		shortcut_desktop		: "Acceso directo de escritorio"
		app_info				: "%app de %developer"
		require_accept_license	: "Debe aceptar los términos de la licencia antes de instalar"
		uninstall_dat_error		: "La creación de datos del desinstalador falló"
		uninstall_exe_error		: "No se pudo crear el desinstalador"
		readonly_error			: "Necesitas permiso para instalar la ruta.\n* Ejecutar como administrador\n* Instalar carpeta de no solo lectura"
		install_file_corrupt	: "El archivo de instalación estaba dañado"
		uninstaller				: "Desinstalador"
		installed				: "¡Instalado!"
		ask_uninstall			: "¿Quieres desinstalar?"
	}
	translation_chinese = Translation{
		accept_license			: "我接受许可条款"
		select_folder			: "选择文件夹"
		install					: "安装"
		installer				: "安装程序"
		shortcut_app_menu		: "应用程序菜单快捷方式"
		shortcut_desktop		: "桌面快捷方式"
		app_info				: "来自 %developer 的 %app"
		require_accept_license	: "您需要在安装前接受许可条款"
		uninstall_dat_error		: "卸载程序数据创建失败"
		uninstall_exe_error		: "卸载程序创建失败"
		readonly_error			: "您需要权限才能安装路径\n* 以管理员身份运行\n* 安装非只读文件夹"
		install_file_corrupt	: "安装文件已损坏"
		uninstaller				: "卸载程序"
		installed				: "已安装！"
		ask_uninstall			: "您要卸载吗？"
	}
)

pub struct Translation {
	accept_license			string = "I accept the license terms"
	select_folder			string = "Select Folder"
	install					string = "Install"
	installer				string = "Installer"
	shortcut_app_menu		string = "App Menu Shortcut"
	shortcut_desktop		string = "Desktop Shortcut"
	app_info				string = "%app from %developer"
	require_accept_license	string = "You need to accept the license terms before install"
	uninstall_dat_error		string = "Uninstaller data creation was failed"
	uninstall_exe_error		string = "Uninstaller creation was failed"
	readonly_error			string = "You need permission to install the path\n* Run As Administrator\n* Install Non-Readonly Folder"
	install_file_corrupt	string = "Install File Was Corrupted"
	uninstaller				string = "Uninstaller"
	installed				string = "Installed!"
	ask_uninstall			string = "Do you want to uninstall?"
}

fn change_language (event_details mui.EventDetails, mut app &mui.Window, mut app_data InstallerData){
	translation := match event_details.value{
		"English" {
			translation_english
		} "Turkish" {
			translation_turkish
		} "Russian" {
			translation_russian
		} "German" {
			translation_german
		} "French" {
			translation_french
		} "Spanish" {
			translation_spanish
		} "Chinese" {
			translation_chinese
		} else {
			translation_english
		}
	}

	app.set_title("${app_data.parameters.app_name} - ${translation.installer}")
	app.get_object_by_id("accept_license")[0]["text"].str = translation.accept_license
	app.get_object_by_id("shortcut_app_menu")[0]["text"].str = translation.shortcut_app_menu
	app.get_object_by_id("shortcut_desktop")[0]["text"].str = translation.shortcut_desktop
	app.get_object_by_id("install_change_path")[0]["text"].str = translation.select_folder
	app.get_object_by_id("install")[0]["text"].str = translation.install
	app.get_object_by_id("app_info")[0]["text"].str = translation.app_info.replace("%app", app_data.parameters.app_name).replace("%developer", app_data.parameters.app_developer)

	app_data.active_language_pack = &translation
}
