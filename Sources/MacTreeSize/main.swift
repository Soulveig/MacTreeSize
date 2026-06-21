import SwiftUI
import AppKit
import Darwin

@main
struct MacTreeSizeApp: App {
    @StateObject private var scanner = DiskScanner()
    @State private var showsUpdates = false
    @State private var showsAbout = false
    @AppStorage("AppLanguage") private var languageCode = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some Scene {
        WindowGroup {
            ContentView(showsUpdates: $showsUpdates, showsAbout: $showsAbout)
                .environmentObject(scanner)
                .frame(minWidth: 1080, minHeight: 640)
                .navigationTitle("\(AppInfo.name) \(AppInfo.versionDisplay)")
        }
        .defaultSize(width: 1080, height: 640)
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("\(L10n.text("chooseFolderOrDisk", language))...") {
                    scanner.chooseAndScan()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            CommandGroup(replacing: .appInfo) {
                Button("\(L10n.text("about", language)) \(AppInfo.name)") {
                    showsAbout = true
                }
                Button(L10n.text("changelog", language)) {
                    showsUpdates = true
                }
            }
            CommandGroup(after: .help) {
                Button(L10n.text("changelog", language)) {
                    showsUpdates = true
                }
            }
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case russian = "ru"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case chinese = "zh"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .chinese: return "中文"
        }
    }

    var shortCode: String { rawValue.uppercased() }

    var flag: String {
        switch self {
        case .english: return "🇺🇸"
        case .russian: return "🇷🇺"
        case .german: return "🇩🇪"
        case .french: return "🇫🇷"
        case .spanish: return "🇪🇸"
        case .chinese: return "🇨🇳"
        }
    }
}

enum L10n {
    private static let strings: [String: [AppLanguage: String]] = [
        "chooseFolderOrDisk": [.english: "Choose Folder or Disk", .russian: "Папка/диск", .german: "Ordner/Volume", .french: "Dossier/disque", .spanish: "Carpeta/disco", .chinese: "文件夹/磁盘"],
        "rescan": [.english: "Rescan", .russian: "Снова", .german: "Neu", .french: "Relancer", .spanish: "Repetir", .chinese: "重扫"],
        "stop": [.english: "Stop", .russian: "Стоп", .german: "Stopp", .french: "Arrêter", .spanish: "Detener", .chinese: "停止"],
        "hideFiles": [.english: "Hide Files", .russian: "Скрыть", .german: "Ausblenden", .french: "Masquer", .spanish: "Ocultar", .chinese: "隐藏"],
        "showFiles": [.english: "Show Files", .russian: "Показать", .german: "Anzeigen", .french: "Afficher", .spanish: "Mostrar", .chinese: "显示"],
        "minPercent": [.english: "Min %", .russian: "Мин %", .german: "Min %", .french: "Min %", .spanish: "Mín %", .chinese: "最小 %"],
        "all": [.english: "All", .russian: "Все", .german: "Alle", .french: "Tout", .spanish: "Todo", .chinese: "全部"],
        "update": [.english: "Update", .russian: "Обновить", .german: "Update", .french: "Mise à jour", .spanish: "Actualizar", .chinese: "更新"],
        "changelog": [.english: "Changelog", .russian: "Изменения", .german: "Änderungen", .french: "Notes", .spanish: "Cambios", .chinese: "更新日志"],
        "info": [.english: "Info", .russian: "Инфо", .german: "Info", .french: "Infos", .spanish: "Info", .chinese: "信息"],
        "language": [.english: "Language", .russian: "Язык", .german: "Sprache", .french: "Langue", .spanish: "Idioma", .chinese: "语言"],
        "about": [.english: "About", .russian: "О программе", .german: "Über", .french: "À propos", .spanish: "Acerca de", .chinese: "关于"],
        "fullDiskEnabled": [.english: "Full Disk Access is enabled", .russian: "Полный доступ к диску включен", .german: "Voller Festplattenzugriff aktiv", .french: "Accès complet au disque activé", .spanish: "Acceso total al disco activado", .chinese: "已启用完全磁盘访问"],
        "fullDiskRecommended": [.english: "Full Disk Access is recommended", .russian: "Рекомендуется полный доступ к диску", .german: "Voller Festplattenzugriff empfohlen", .french: "Accès complet au disque recommandé", .spanish: "Se recomienda acceso total al disco", .chinese: "建议启用完全磁盘访问"],
        "fullDiskEnabledDetail": [.english: "MacTreeSize can scan protected folders without repeated permission stops.", .russian: "MacTreeSize может сканировать защищенные папки без повторных запросов.", .german: "MacTreeSize kann geschützte Ordner ohne wiederholte Abfragen scannen.", .french: "MacTreeSize peut analyser les dossiers protégés sans demandes répétées.", .spanish: "MacTreeSize puede analizar carpetas protegidas sin permisos repetidos.", .chinese: "MacTreeSize 可扫描受保护文件夹而无需重复授权。"],
        "fullDiskRecommendedDetail": [.english: "Open Privacy settings, enable MacTreeSize, then relaunch.", .russian: "Откройте настройки приватности, включите MacTreeSize и перезапустите.", .german: "Datenschutz öffnen, MacTreeSize aktivieren und neu starten.", .french: "Ouvrez Confidentialité, activez MacTreeSize, puis relancez.", .spanish: "Abra Privacidad, active MacTreeSize y reinicie.", .chinese: "打开隐私设置，启用 MacTreeSize，然后重新启动。"],
        "check": [.english: "Check", .russian: "Проверить", .german: "Prüfen", .french: "Vérifier", .spanish: "Comprobar", .chinese: "检查"],
        "openSettings": [.english: "Open Settings", .russian: "Настройки", .german: "Einstellungen", .french: "Réglages", .spanish: "Ajustes", .chinese: "设置"],
        "total": [.english: "Total", .russian: "Всего", .german: "Gesamt", .french: "Total", .spanish: "Total", .chinese: "总计"],
        "files": [.english: "Files", .russian: "Файлы", .german: "Dateien", .french: "Fichiers", .spanish: "Archivos", .chinese: "文件"],
        "folders": [.english: "Folders", .russian: "Папки", .german: "Ordner", .french: "Dossiers", .spanish: "Carpetas", .chinese: "文件夹"],
        "scanned": [.english: "Scanned", .russian: "Скан", .german: "Scan", .french: "Scan", .spanish: "Scan", .chinese: "扫描"],
        "usedSize": [.english: "Used Size", .russian: "Занято", .german: "Belegt", .french: "Utilisé", .spanish: "Usado", .chinese: "已用"],
        "usedPercent": [.english: "Used %", .russian: "Занято %", .german: "Belegt %", .french: "Utilisé %", .spanish: "Usado %", .chinese: "已用 %"],
        "pathCopied": [.english: "Path copied", .russian: "Путь скопирован", .german: "Pfad kopiert", .french: "Chemin copié", .spanish: "Ruta copiada", .chinese: "路径已复制"],
        "copyPathHint": [.english: "Click here to copy Path", .russian: "Нажмите здесь, чтобы скопировать путь", .german: "Hier klicken, um den Pfad zu kopieren", .french: "Cliquez ici pour copier le chemin", .spanish: "Clic aquí para copiar la ruta", .chinese: "点击此处复制路径"],
        "none": [.english: "None", .russian: "Нет", .german: "Keine", .french: "Aucun", .spanish: "Ninguno", .chinese: "无"],
        "name": [.english: "Name", .russian: "Имя", .german: "Name", .french: "Nom", .spanish: "Nombre", .chinese: "名称"],
        "size": [.english: "Size", .russian: "Размер", .german: "Größe", .french: "Taille", .spanish: "Tamaño", .chinese: "大小"],
        "emptyPrompt": [.english: "Choose a folder, or scan entire disk", .russian: "Выберите папку или просканируйте весь диск", .german: "Ordner wählen oder ganze Festplatte scannen", .french: "Choisissez un dossier ou analysez tout le disque", .spanish: "Elija una carpeta o analice todo el disco", .chinese: "选择文件夹或扫描整个磁盘"],
        "updates": [.english: "Updates", .russian: "Обновления", .german: "Updates", .french: "Mises à jour", .spanish: "Actualizaciones", .chinese: "更新"],
        "currentVersion": [.english: "Current version", .russian: "Текущая версия", .german: "Aktuelle Version", .french: "Version actuelle", .spanish: "Versión actual", .chinese: "当前版本"],
        "checkNow": [.english: "Check Now", .russian: "Проверить сейчас", .german: "Jetzt prüfen", .french: "Vérifier", .spanish: "Comprobar ahora", .chinese: "立即检查"],
        "checking": [.english: "Checking...", .russian: "Проверка...", .german: "Prüfe...", .french: "Vérification...", .spanish: "Comprobando...", .chinese: "正在检查..."],
        "installUpdate": [.english: "Install Update", .russian: "Установить", .german: "Installieren", .french: "Installer", .spanish: "Instalar", .chinese: "安装更新"],
        "installing": [.english: "Installing...", .russian: "Установка...", .german: "Installiere...", .french: "Installation...", .spanish: "Instalando...", .chinese: "正在安装..."],
        "done": [.english: "Done", .russian: "Готово", .german: "Fertig", .french: "Terminé", .spanish: "Listo", .chinese: "完成"],
        "aboutDescription": [.english: "Native macOS disk usage viewer for quickly finding large folders and files.", .russian: "Нативный просмотрщик использования диска для быстрого поиска больших папок и файлов.", .german: "Native macOS-App zum schnellen Finden großer Ordner und Dateien.", .french: "Visionneuse native macOS pour trouver rapidement les gros dossiers et fichiers.", .spanish: "Visor nativo de uso de disco para encontrar carpetas y archivos grandes.", .chinese: "用于快速查找大型文件夹和文件的原生 macOS 磁盘查看器。"],
        "fullDiskAccess": [.english: "Full Disk Access", .russian: "Полный доступ к диску", .german: "Voller Festplattenzugriff", .french: "Accès complet au disque", .spanish: "Acceso total al disco", .chinese: "完全磁盘访问"],
        "fullDiskAbout": [.english: "macOS requires this permission for protected locations such as Mail, Safari data, Time Machine metadata, and some Library folders. The app can open the correct Settings page, but only the user can grant the permission.", .russian: "macOS требует это разрешение для защищенных мест, таких как Mail, данные Safari, метаданные Time Machine и некоторые папки Library. Приложение может открыть нужную страницу настроек, но выдать доступ может только пользователь.", .german: "macOS benötigt diese Berechtigung für geschützte Orte wie Mail, Safari-Daten, Time-Machine-Metadaten und einige Library-Ordner. Die App kann die richtige Einstellungsseite öffnen, aber nur der Benutzer kann die Berechtigung erteilen.", .french: "macOS exige cette autorisation pour les emplacements protégés comme Mail, les données Safari, les métadonnées Time Machine et certains dossiers Library. L'app peut ouvrir la bonne page Réglages, mais seul l'utilisateur peut accorder l'autorisation.", .spanish: "macOS requiere este permiso para ubicaciones protegidas como Mail, datos de Safari, metadatos de Time Machine y algunas carpetas Library. La app puede abrir la página correcta, pero solo el usuario puede conceder el permiso.", .chinese: "macOS 需要此权限才能访问 Mail、Safari 数据、Time Machine 元数据和部分 Library 文件夹等受保护位置。应用可以打开正确的设置页面，但只有用户能授予权限。"],
        "openInFinder": [.english: "Open in Finder", .russian: "Открыть в Finder", .german: "Im Finder öffnen", .french: "Ouvrir dans Finder", .spanish: "Abrir en Finder", .chinese: "在 Finder 中打开"],
        "rescanFolder": [.english: "Rescan this folder", .russian: "Пересканировать папку", .german: "Diesen Ordner neu scannen", .french: "Réanalyser ce dossier", .spanish: "Reanalizar esta carpeta", .chinese: "重新扫描此文件夹"],
        "limitedChildren": [.english: "Showing %d of %d items. Increase Min %% to narrow this folder.", .russian: "Показано %d из %d элементов. Увеличьте Мин %%, чтобы сузить папку.", .german: "%d von %d Elementen. Min %% erhöhen, um einzugrenzen.", .french: "%d sur %d éléments. Augmentez Min %% pour filtrer.", .spanish: "Mostrando %d de %d elementos. Aumente Mín %% para filtrar.", .chinese: "显示 %d / %d 项。提高最小 %% 可缩小范围。"]
    ]

    static func text(_ key: String, _ language: AppLanguage) -> String {
        strings[key]?[language] ?? strings[key]?[.english] ?? key
    }
}

final class LanguageMenuPresenter: NSObject {
    static let shared = LanguageMenuPresenter()

    private var onSelect: ((AppLanguage) -> Void)?

    func show(current: AppLanguage, onSelect: @escaping (AppLanguage) -> Void) {
        self.onSelect = onSelect

        let menu = NSMenu()
        for language in AppLanguage.allCases {
            let item = NSMenuItem(title: "\(language.flag) \(language.name)", action: #selector(selectLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = language.rawValue
            item.state = language == current ? .on : .off
            menu.addItem(item)
        }

        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let language = AppLanguage(rawValue: rawValue) else { return }
        onSelect?(language)
    }
}

struct ContentView: View {
    @EnvironmentObject private var scanner: DiskScanner
    @Binding var showsUpdates: Bool
    @Binding var showsAbout: Bool
    @StateObject private var updater = AppUpdater()
    @State private var minimumPercent = 0.0
    @State private var hideFiles = false
    @State private var expandedPaths = Set<String>()
    @State private var rootPathWasCopied = false
    @AppStorage("AppLanguage") private var languageCode = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider()
            accessBanner
            Divider()
            summary
            Divider()
            header
            Divider()
            content
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showsAbout) {
            AboutAppView()
        }
        .sheet(isPresented: $showsUpdates) {
            UpdatesView(updater: updater)
        }
        .onAppear {
            scanner.refreshFullDiskAccessStatus()
            updater.checkForUpdatesIfNeeded()
        }
    }

    private var toolbar: some View {
        HStack(spacing: 8) {
            toolbarPrimaryControls
                .layoutPriority(2)
                .fixedSize(horizontal: true, vertical: false)

            Spacer(minLength: 16)

            toolbarUtilityControls
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var toolbarPrimaryControls: some View {
        HStack(spacing: 8) {
            Button {
                scanner.chooseAndScan()
            } label: {
                toolbarButtonLabel(L10n.text("chooseFolderOrDisk", language), systemImage: "folder")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .fixedSize(horizontal: true, vertical: false)

            Button {
                scanner.rescan()
            } label: {
                toolbarButtonLabel(L10n.text("rescan", language), systemImage: "arrow.clockwise")
            }
            .disabled(scanner.selectedURL == nil || scanner.isScanning)
            .controlSize(.regular)
            .fixedSize(horizontal: true, vertical: false)

            Button {
                scanner.stopScan()
            } label: {
                toolbarButtonLabel(L10n.text("stop", language), systemImage: "stop.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .disabled(!scanner.isScanning)
            .keyboardShortcut(".", modifiers: [.command])
            .tint(scanner.isScanning ? .red : .secondary)
            .fixedSize(horizontal: true, vertical: false)

            Button {
                hideFiles.toggle()
            } label: {
                toolbarButtonLabel(hideFiles ? L10n.text("showFiles", language) : L10n.text("hideFiles", language), systemImage: "doc")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .fixedSize(horizontal: true, vertical: false)

            HStack(spacing: 4) {
                Text(L10n.text("minPercent", language))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Slider(value: $minimumPercent, in: 0...10, step: 0.5)
                    .frame(width: 90)
                Text(minimumPercent == 0 ? L10n.text("all", language) : String(format: "%.1f", minimumPercent))
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 36, alignment: .leading)
            }
            .padding(.leading, 4)
            .frame(height: 24, alignment: .center)
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var toolbarUtilityControls: some View {
        HStack(spacing: 8) {
            updateToolbarButton

            Button {
                showsAbout = true
            } label: {
                toolbarButtonLabel(L10n.text("info", language), systemImage: "info.circle")
            }
            .controlSize(.regular)
            .help(L10n.text("about", language))
            .fixedSize(horizontal: true, vertical: false)

            Button {
                LanguageMenuPresenter.shared.show(current: language) { selected in
                    languageCode = selected.rawValue
                }
            } label: {
                toolbarLanguageLabel(language)
            }
            .controlSize(.regular)
            .help(L10n.text("language", language))
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    @ViewBuilder
    private var updateToolbarButton: some View {
        if updater.updateAvailable {
            Button {
                showsUpdates = true
            } label: {
                toolbarButtonLabel(L10n.text("update", language), systemImage: "arrow.down.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .tint(.green)
            .help(L10n.text("update", language))
            .fixedSize(horizontal: true, vertical: false)
        } else {
            Button {
                showsUpdates = true
            } label: {
                toolbarButtonLabel(L10n.text("update", language), systemImage: "arrow.down.circle")
            }
            .controlSize(.regular)
            .help(L10n.text("update", language))
            .fixedSize(horizontal: true, vertical: false)
        }
    }

    private func toolbarButtonLabel(_ title: String, systemImage: String, textWidth: CGFloat? = nil) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .imageScale(.small)
                .frame(width: 16, height: 16, alignment: .center)
            Text(title)
                .font(.system(size: 13))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .frame(width: textWidth, alignment: .center)
        }
        .padding(.horizontal, 3)
        .frame(height: 22, alignment: .center)
    }

    private func toolbarLanguageLabel(_ language: AppLanguage) -> some View {
        HStack(spacing: 5) {
            Text(language.flag)
            Text(language.shortCode)
            Image(systemName: "chevron.down")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 13))
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, 3)
        .frame(height: 22, alignment: .center)
    }

    private var accessBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: scanner.hasFullDiskAccess ? "checkmark.shield" : "exclamationmark.shield")
                .foregroundStyle(scanner.hasFullDiskAccess ? .green : .orange)
                .font(.system(size: 18, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(scanner.hasFullDiskAccess ? L10n.text("fullDiskEnabled", language) : L10n.text("fullDiskRecommended", language))
                    .font(.system(size: 13, weight: .semibold))
                Text(scanner.hasFullDiskAccess ? L10n.text("fullDiskEnabledDetail", language) : L10n.text("fullDiskRecommendedDetail", language))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(width: 380, alignment: .leading)

            Spacer(minLength: 12)

            HStack(spacing: 12) {
                Button {
                    scanner.refreshFullDiskAccessStatus()
                } label: {
                    Label(L10n.text("check", language), systemImage: "checkmark.circle")
                }

                Button {
                    scanner.openFullDiskAccessSettings()
                } label: {
                    Label(L10n.text("openSettings", language), systemImage: "gearshape")
                }
                .buttonStyle(.borderedProminent)
                .tint(scanner.hasFullDiskAccess ? .secondary : .accentColor)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(scanner.hasFullDiskAccess ? Color.green.opacity(0.08) : Color.orange.opacity(0.10))
    }

    private var summary: some View {
        HStack(spacing: 8) {
            rootMetric
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                metric(L10n.text("total", language), ByteCountFormatter.diskString(scanner.root?.size ?? 0), width: 74, alignment: .trailing)
                metric(L10n.text("files", language), scanner.root.map { NumberFormatter.groupedString($0.fileCount) } ?? "0", width: 74, alignment: .trailing)
                metric(L10n.text("folders", language), scanner.root.map { NumberFormatter.groupedString($0.folderCount) } ?? "0", width: 74, alignment: .trailing)
                metric(L10n.text("scanned", language), scanner.progress.itemsScanned.formatted(), width: 82, alignment: .trailing)
                metric(L10n.text("usedSize", language), ByteCountFormatter.diskString(scanner.uniqueSizeForDisplay), width: 86, alignment: .trailing)
                metric(L10n.text("usedPercent", language), scanner.uniqueDiskPercentText, width: 70, alignment: .trailing)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private var rootMetric: some View {
        Button {
            copyRootPath()
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(rootPathWasCopied ? L10n.text("pathCopied", language) : L10n.text("copyPathHint", language))
                    .foregroundStyle(rootPathWasCopied ? .green : .secondary)
                .font(.caption)
                Text(scanner.selectedURL?.path(percentEncoded: false) ?? L10n.text("none", language))
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .frame(minWidth: 300, maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(scanner.selectedURL == nil)
        .help(L10n.text("copyPathHint", language))
    }

    private func metric(_ label: String, _ value: String, width: CGFloat, alignment: HorizontalAlignment = .leading) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: frameAlignment(for: alignment))
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, alignment: frameAlignment(for: alignment))
        }
        .frame(width: width, alignment: frameAlignment(for: alignment))
    }

    private func frameAlignment(for alignment: HorizontalAlignment) -> Alignment {
        alignment == .trailing ? .trailing : .leading
    }

    private func copyRootPath() {
        guard let path = scanner.selectedURL?.path(percentEncoded: false) else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(path, forType: .string)
        rootPathWasCopied = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            rootPathWasCopied = false
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text(L10n.text("name", language))
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 12) {
                Text(L10n.text("size", language))
                    .frame(width: 120, alignment: .trailing)
                Text("%")
                    .frame(width: 60, alignment: .trailing)
                Text(L10n.text("files", language))
                    .frame(width: 70, alignment: .trailing)
                Text(L10n.text("folders", language))
                    .frame(width: 70, alignment: .trailing)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }

    @ViewBuilder
    private var content: some View {
        if let root = scanner.root {
            ScrollView {
                LazyVStack(spacing: 0) {
                    DiskNodeRow(
                        node: root,
                        rootSize: max(root.size, 1),
                        depth: 0,
                        minimumPercent: minimumPercent,
                        showFiles: !hideFiles,
                        language: language,
                        expandedPaths: $expandedPaths,
                        openFolder: scanner.openFolder,
                        rescanFolder: scanner.rescanFolder
                    )
                }
                .padding(.vertical, 4)
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "externaldrive")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text(L10n.text("emptyPrompt", language))
                    .font(.title3)
                HStack(spacing: 10) {
                    Button {
                        scanner.chooseAndScan()
                    } label: {
                        Label(L10n.text("chooseFolderOrDisk", language), systemImage: "folder")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct UpdatesView: View {
    @ObservedObject var updater: AppUpdater
    @Environment(\.dismiss) private var dismiss
    @AppStorage("AppLanguage") private var languageCode = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: updater.statusIconName)
                    .font(.system(size: 30))
                    .foregroundStyle(updater.statusColor)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.text("updates", language))
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(L10n.text("currentVersion", language)) \(AppInfo.versionDisplay)")
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(updater.title)
                    .font(.headline)
                Text(updater.message)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            Text(L10n.text("changelog", language))
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(AppInfo.changelog) { release in
                        VStack(alignment: .leading, spacing: 7) {
                            HStack(spacing: 8) {
                                Text(release.version)
                                    .font(.headline)
                                Text(release.date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(release.items, id: \.self) { item in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundStyle(.secondary)
                                    Text(item)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 170)

            HStack {
                Spacer()

                Button(L10n.text("done", language)) {
                    dismiss()
                }

                Button {
                    updater.checkForUpdates()
                } label: {
                    Label(updater.isChecking ? L10n.text("checking", language) : L10n.text("checkNow", language), systemImage: "arrow.clockwise")
                }
                .disabled(updater.isChecking || updater.isInstalling)

                if updater.updateAvailable {
                    Button {
                        updater.installUpdate()
                    } label: {
                        Label(updater.isInstalling ? L10n.text("installing", language) : L10n.text("installUpdate", language), systemImage: "arrow.down.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(updater.isInstalling)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 520, idealWidth: 520, minHeight: 260, alignment: .topLeading)
        .onAppear {
            updater.checkForUpdatesIfNeeded()
        }
    }
}

struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("AppLanguage") private var languageCode = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "internaldrive")
                    .font(.system(size: 34))
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(AppInfo.name)
                        .font(.title2.weight(.semibold))
                    Text(AppInfo.versionDisplay)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text(L10n.text("aboutDescription", language))
                .foregroundStyle(.secondary)

            Text(AppInfo.copyright)
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Text(L10n.text("fullDiskAccess", language))
                .font(.headline)
            Text(L10n.text("fullDiskAbout", language))
                .foregroundStyle(.secondary)

            HStack {
                Spacer()
                Button(L10n.text("done", language)) {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520)
    }
}

@MainActor
final class AppUpdater: ObservableObject {
    @Published private(set) var latestRelease: AppUpdateRelease?
    @Published private(set) var updateAvailable = false
    @Published private(set) var isChecking = false
    @Published private(set) var isInstalling = false
    @Published private(set) var title = "Ready to check"
    @Published private(set) var message = "MacTreeSize can check a hosted update manifest and open the download page when a newer version is available."
    @Published private(set) var statusIconName = "arrow.down.circle"
    @Published private(set) var statusColor = Color.accentColor

    private var hasCheckedThisSession = false

    func checkForUpdatesIfNeeded() {
        guard hasCheckedThisSession == false else { return }
        checkForUpdates()
    }

    func checkForUpdates() {
        guard isChecking == false, isInstalling == false else { return }
        hasCheckedThisSession = true

        guard let manifestURL = Self.manifestURL else {
            latestRelease = nil
            updateAvailable = false
            title = "Update feed is not configured"
            message = "Add an HTTPS update manifest URL to MTUpdateManifestURL in Info.plist or the UpdateManifestURL user default."
            statusIconName = "exclamationmark.triangle"
            statusColor = .orange
            return
        }

        isChecking = true
        title = "Checking for updates..."
        message = manifestURL.absoluteString
        statusIconName = "arrow.clockwise"
        statusColor = .secondary

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: manifestURL)
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    throw AppUpdateError.badStatus(httpResponse.statusCode)
                }

                let manifest = try JSONDecoder().decode(AppUpdateManifest.self, from: data)
                let release = try manifest.release()
                let isNewer = Self.compareVersions(release.version, AppInfo.version) == .orderedDescending

                latestRelease = release
                updateAvailable = isNewer
                isChecking = false

                if isNewer {
                    title = "Version \(release.version) is available"
                    message = "A newer MacTreeSize build is ready to download."
                    statusIconName = "arrow.down.circle.fill"
                    statusColor = .green
                } else {
                    title = "MacTreeSize is up to date"
                    message = "You are using \(AppInfo.versionDisplay)."
                    statusIconName = "checkmark.circle.fill"
                    statusColor = .green
                }
            } catch {
                latestRelease = nil
                updateAvailable = false
                isChecking = false
                title = "Could not check for updates"
                message = error.localizedDescription
                statusIconName = "exclamationmark.triangle"
                statusColor = .orange
            }
        }
    }

    func installUpdate() {
        guard isInstalling == false, let release = latestRelease, updateAvailable else { return }

        isInstalling = true
        title = "Downloading version \(release.version)..."
        message = release.downloadURL.absoluteString
        statusIconName = "arrow.down.circle.fill"
        statusColor = .green

        Task {
            do {
                let downloadedArchive = try await Self.downloadArchive(from: release.downloadURL)
                title = "Preparing update..."
                message = "Unpacking MacTreeSize \(release.version)."

                let tempRoot = FileManager.default.temporaryDirectory
                    .appendingPathComponent("MacTreeSizeUpdate-\(UUID().uuidString)", isDirectory: true)
                let archiveURL = tempRoot.appendingPathComponent("MacTreeSize.zip")
                let expandedURL = tempRoot.appendingPathComponent("expanded", isDirectory: true)

                try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
                try FileManager.default.moveItem(at: downloadedArchive, to: archiveURL)
                try FileManager.default.createDirectory(at: expandedURL, withIntermediateDirectories: true)
                try Self.runProcess("/usr/bin/ditto", arguments: ["-x", "-k", archiveURL.path, expandedURL.path])

                let newAppURL = try Self.findAppBundle(in: expandedURL)
                let currentAppURL = Bundle.main.bundleURL
                let installFolder = currentAppURL.deletingLastPathComponent()
                if let protectedFolderName = Self.protectedUserFolderName(for: currentAppURL) {
                    title = "macOS permission may be required"
                    message = "MacTreeSize is running from your \(protectedFolderName) folder. If macOS asks for access, choose Allow so the updater can replace the app."
                    try await Task.sleep(nanoseconds: 1_500_000_000)
                }

                guard FileManager.default.isWritableFile(atPath: installFolder.path) else {
                    throw AppUpdateError.installFolderNotWritable(installFolder.path)
                }

                title = "Installing update..."
                message = "MacTreeSize will restart automatically."
                try Self.launchInstallHelper(currentAppURL: currentAppURL, newAppURL: newAppURL, tempRoot: tempRoot)
                exit(0)
            } catch {
                isInstalling = false
                title = "Could not install update"
                message = error.localizedDescription
                statusIconName = "exclamationmark.triangle"
                statusColor = .orange
            }
        }
    }

    private static var manifestURL: URL? {
        let defaultValue = UserDefaults.standard.string(forKey: "UpdateManifestURL")
        let bundleValue = Bundle.main.object(forInfoDictionaryKey: "MTUpdateManifestURL") as? String
        let rawValue = [defaultValue, bundleValue, AppInfo.updateManifestURLString]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { $0.isEmpty == false }

        guard let rawValue, let url = URL(string: rawValue) else { return nil }
        if url.pathExtension.isEmpty {
            return url.appendingPathComponent("update.json")
        }
        return url
    }

    private static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let left = lhs.split(separator: ".").map { Int($0) ?? 0 }
        let right = rhs.split(separator: ".").map { Int($0) ?? 0 }
        let count = max(left.count, right.count)

        for index in 0..<count {
            let a = index < left.count ? left[index] : 0
            let b = index < right.count ? right[index] : 0
            if a < b { return .orderedAscending }
            if a > b { return .orderedDescending }
        }

        return .orderedSame
    }

    private static func downloadArchive(from url: URL) async throws -> URL {
        let (downloadedURL, response) = try await URLSession.shared.download(from: url)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw AppUpdateError.badStatus(httpResponse.statusCode)
        }
        return downloadedURL
    }

    private static func findAppBundle(in folder: URL) throws -> URL {
        guard let enumerator = FileManager.default.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            throw AppUpdateError.invalidArchive
        }

        for case let url as URL in enumerator {
            if url.pathExtension == "app", url.lastPathComponent == "\(AppInfo.name).app" {
                return url
            }
        }

        throw AppUpdateError.invalidArchive
    }

    private static func launchInstallHelper(currentAppURL: URL, newAppURL: URL, tempRoot: URL) throws {
        let helperURL = tempRoot.appendingPathComponent("install-update.sh")
        let script = """
        #!/bin/sh
        set -e
        APP_PID=\(getpid())
        CURRENT_APP=\(shellQuoted(currentAppURL.path))
        NEW_APP=\(shellQuoted(newAppURL.path))
        TEMP_ROOT=\(shellQuoted(tempRoot.path))
        LOG_FILE="$TEMP_ROOT/install.log"

        exec >> "$LOG_FILE" 2>&1
        echo "Starting MacTreeSize update at $(date)"
        echo "Current app: $CURRENT_APP"
        echo "New app: $NEW_APP"

        WAIT_COUNT=0
        while kill -0 "$APP_PID" 2>/dev/null && [ "$WAIT_COUNT" -lt 50 ]; do
            sleep 0.2
            WAIT_COUNT=$((WAIT_COUNT + 1))
        done

        if kill -0 "$APP_PID" 2>/dev/null; then
            echo "App did not exit in time, sending TERM"
            kill -TERM "$APP_PID" 2>/dev/null || true
            sleep 1
        fi

        if kill -0 "$APP_PID" 2>/dev/null; then
            echo "App still running, sending KILL"
            kill -KILL "$APP_PID" 2>/dev/null || true
            sleep 0.5
        fi

        BACKUP_APP="$CURRENT_APP.previous.$(date +%s)"
        if [ -e "$CURRENT_APP" ]; then
            /bin/mv "$CURRENT_APP" "$BACKUP_APP"
        fi

        /usr/bin/ditto "$NEW_APP" "$CURRENT_APP"
        /usr/bin/xattr -dr com.apple.quarantine "$CURRENT_APP" 2>/dev/null || true
        /usr/bin/open "$CURRENT_APP"
        if [ -n "${BACKUP_APP:-}" ] && [ -e "$BACKUP_APP" ]; then
            rm -rf "$BACKUP_APP"
        fi
        rm -rf "$TEMP_ROOT"
        """

        try script.write(to: helperURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: helperURL.path)

        let nullDevice = try FileHandle(forWritingTo: URL(fileURLWithPath: "/dev/null"))
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/nohup")
        process.arguments = ["/bin/sh", helperURL.path]
        process.standardOutput = nullDevice
        process.standardError = nullDevice
        try process.run()
    }

    private static func protectedUserFolderName(for url: URL) -> String? {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let protectedFolders = [
            ("Documents", home.appendingPathComponent("Documents").path),
            ("Desktop", home.appendingPathComponent("Desktop").path),
            ("Downloads", home.appendingPathComponent("Downloads").path)
        ]

        let appPath = url.standardizedFileURL.path
        return protectedFolders.first { _, folderPath in
            appPath == folderPath || appPath.hasPrefix(folderPath + "/")
        }?.0
    }

    private static func runProcess(_ executable: String, arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw AppUpdateError.processFailed(executable, Int(process.terminationStatus))
        }
    }

    private static func shellQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }
}

struct AppUpdateManifest: Decodable {
    let version: String
    let downloadURL: URL
    let releaseNotes: String?

    func release() throws -> AppUpdateRelease {
        guard version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw AppUpdateError.invalidManifest
        }

        return AppUpdateRelease(version: version, downloadURL: downloadURL, releaseNotes: releaseNotes)
    }
}

struct AppUpdateRelease {
    let version: String
    let downloadURL: URL
    let releaseNotes: String?
}

enum AppUpdateError: LocalizedError {
    case badStatus(Int)
    case invalidManifest
    case invalidArchive
    case installFolderNotWritable(String)
    case processFailed(String, Int)

    var errorDescription: String? {
        switch self {
        case .badStatus(let code):
            return "The update server returned HTTP \(code)."
        case .invalidManifest:
            return "The update manifest is missing required version information."
        case .invalidArchive:
            return "The downloaded archive does not contain MacTreeSize.app."
        case .installFolderNotWritable(let path):
            return "MacTreeSize cannot replace itself because the install folder is not writable: \(path)."
        case .processFailed(let executable, let code):
            return "\(executable) exited with status \(code)."
        }
    }
}

struct DiskNodeRow: View {
    let node: DiskNode
    let rootSize: UInt64
    let depth: Int
    let minimumPercent: Double
    let showFiles: Bool
    let language: AppLanguage
    @Binding var expandedPaths: Set<String>
    let openFolder: (DiskNode) -> Void
    let rescanFolder: (DiskNode) -> Void

    init(
        node: DiskNode,
        rootSize: UInt64,
        depth: Int,
        minimumPercent: Double,
        showFiles: Bool,
        language: AppLanguage,
        expandedPaths: Binding<Set<String>>,
        openFolder: @escaping (DiskNode) -> Void,
        rescanFolder: @escaping (DiskNode) -> Void
    ) {
        self.node = node
        self.rootSize = rootSize
        self.depth = depth
        self.minimumPercent = minimumPercent
        self.showFiles = showFiles
        self.language = language
        self._expandedPaths = expandedPaths
        self.openFolder = openFolder
        self.rescanFolder = rescanFolder
    }

    private var visibleChildren: [DiskNode] {
        node.children.filter { child in
            if child.isDirectory == false && showFiles == false {
                return false
            }
            let pct = Double(child.size) * 100 / Double(max(rootSize, 1))
            return pct >= minimumPercent || child === node.children.first
        }
    }

    private var renderedChildren: [DiskNode] {
        Array(visibleChildren.prefix(Self.maximumRenderedChildrenPerFolder))
    }

    private var hiddenChildCount: Int {
        max(visibleChildren.count - renderedChildren.count, 0)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Color.clear.frame(width: CGFloat(depth * 18))
                    if node.children.isEmpty {
                        if node.isDirectory {
                            folderActionButtons
                        } else {
                            Image(systemName: "doc")
                                .foregroundStyle(.secondary)
                                .frame(width: 16)
                        }
                    } else {
                        Button {
                            toggleExpanded()
                        } label: {
                            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .frame(width: 16)

                        folderActionButtons
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(node.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.secondary.opacity(0.12))
                                Capsule()
                                    .fill(sizeColor.opacity(0.72))
                                    .frame(width: max(2, proxy.size.width * percentage / 100))
                            }
                        }
                        .frame(height: 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(ByteCountFormatter.diskString(node.size))
                    .monospacedDigit()
                    .frame(width: 120, alignment: .trailing)
                Text(String(format: "%.1f", percentage))
                    .monospacedDigit()
                    .frame(width: 60, alignment: .trailing)
                Text(NumberFormatter.groupedString(node.fileCount))
                    .monospacedDigit()
                    .frame(width: 70, alignment: .trailing)
                Text(NumberFormatter.groupedString(node.folderCount))
                    .monospacedDigit()
                    .frame(width: 70, alignment: .trailing)
            }
            .font(.system(size: 13))
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(depth == 0 ? Color.accentColor.opacity(0.08) : Color.clear)

            if isExpanded {
                ForEach(renderedChildren) { child in
                    DiskNodeRow(
                        node: child,
                        rootSize: rootSize,
                        depth: depth + 1,
                        minimumPercent: minimumPercent,
                        showFiles: showFiles,
                        language: language,
                        expandedPaths: $expandedPaths,
                        openFolder: openFolder,
                        rescanFolder: rescanFolder
                    )
                }

                if hiddenChildCount > 0 {
                    limitedChildrenNotice
                }
            }
        }
    }

    private static let maximumRenderedChildrenPerFolder = 2_000

    private var isExpanded: Bool {
        depth == 0 || expandedPaths.contains(node.path)
    }

    private func toggleExpanded() {
        if expandedPaths.contains(node.path) {
            expandedPaths.remove(node.path)
        } else {
            expandedPaths.insert(node.path)
        }
    }

    private var folderActionButtons: some View {
        HStack(spacing: 3) {
            Button {
                openFolder(node)
            } label: {
                Image(systemName: "folder")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .frame(width: 16)
            .help(L10n.text("openInFinder", language))

            Button {
                rescanFolder(node)
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 16)
            .help(L10n.text("rescanFolder", language))
        }
    }

    private var limitedChildrenNotice: some View {
        HStack(spacing: 8) {
            Color.clear.frame(width: CGFloat((depth + 1) * 18 + 38))
            Image(systemName: "ellipsis.circle")
                .foregroundStyle(.secondary)
                .frame(width: 16)
            Text(String(format: L10n.text("limitedChildren", language), renderedChildren.count, visibleChildren.count))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
        }
        .font(.system(size: 12))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
    }

    private var percentage: Double {
        Double(node.size) * 100 / Double(max(rootSize, 1))
    }

    private var sizeColor: Color {
        switch percentage {
        case 35...: return .red
        case 15..<35: return .orange
        case 5..<15: return .yellow
        default: return .green
        }
    }
}

@MainActor
final class DiskScanner: ObservableObject {
    @Published var root: DiskNode?
    @Published var selectedURL: URL?
    @Published var isScanning = false
    @Published var hasFullDiskAccess = false
    @Published var progress = ScanProgress()
    @Published var scanVolumeCapacity: UInt64 = 0

    private var scanTask: Task<Void, Never>?
    private var activeScanID: UUID?
    private var cancellation: ScanCancellation?

    var uniqueDiskPercentText: String {
        guard scanVolumeCapacity > 0 else { return "n/a" }
        let percent = min(Double(uniqueSizeForDisplay) * 100 / Double(scanVolumeCapacity), 100)
        return String(format: "%.2f%%", percent)
    }

    var uniqueSizeForDisplay: UInt64 {
        if isScanning {
            return progress.bytesScanned
        }
        return root?.size ?? progress.bytesScanned
    }

    func chooseAndScan() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Choose a folder to analyze"

        if panel.runModal() == .OK, let url = panel.url {
            scan(url)
        }
    }

    func rescan() {
        guard let selectedURL else { return }
        scan(selectedURL, excludesMountedVolumes: selectedURL.path == "/")
    }

    func openFolder(_ node: DiskNode) {
        guard node.isDirectory else { return }
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: node.path)])
    }

    func rescanFolder(_ node: DiskNode) {
        guard node.isDirectory, let currentRoot = root, isScanning == false else { return }
        let url = URL(fileURLWithPath: node.path)
        let scanID = UUID()
        let cancellation = ScanCancellation()
        activeScanID = scanID
        self.cancellation = cancellation
        isScanning = true
        progress = ScanProgress()

        scanTask = Task {
            let reporter = ScanReporter { progress in
                Task { @MainActor [weak self] in
                    guard let self, self.activeScanID == scanID else { return }
                    self.progress = progress
                }
            }
            let excludesMountedVolumes = self.selectedURL?.path == "/"
            let scanScope = ScanScope(excludesMountedVolumes: excludesMountedVolumes, rootVolumeIdentifier: excludesMountedVolumes ? Self.volumeIdentifier(for: url) : nil)
            let rescanned = await DiskScanner.scanNode(at: url, reporter: reporter, cancellation: cancellation, scanScope: scanScope)

            await MainActor.run {
                guard self.activeScanID == scanID else { return }
                self.activeScanID = nil
                self.cancellation = nil
                self.scanTask = nil
                self.isScanning = false

                guard cancellation.isCancelled == false, let rescanned else {
                    return
                }

                self.root = Self.replacingNode(path: node.path, in: currentRoot, with: rescanned).node
            }
        }
    }

    func stopScan() {
        cancellation?.cancel()
        scanTask?.cancel()
        scanTask = nil
        activeScanID = nil
        isScanning = false
    }

    func refreshFullDiskAccessStatus() {
        hasFullDiskAccess = Self.canReadProtectedLocation()
    }

    func openFullDiskAccessSettings() {
        let urls = [
            "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles",
            "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles"
        ]

        for value in urls {
            guard let url = URL(string: value) else { continue }
            if NSWorkspace.shared.open(url) {
                return
            }
        }
    }

    func scan(_ url: URL, excludesMountedVolumes: Bool = false) {
        cancellation?.cancel()
        scanTask?.cancel()
        let scanID = UUID()
        let cancellation = ScanCancellation()
        activeScanID = scanID
        self.cancellation = cancellation
        selectedURL = url
        root = nil
        isScanning = true
        progress = ScanProgress()
        scanVolumeCapacity = Self.volumeCapacity(for: url)

        scanTask = Task {
            let reporter = ScanReporter { progress in
                Task { @MainActor [weak self] in
                    guard let self, self.activeScanID == scanID else { return }
                    self.progress = progress
                }
            }
            let scanScope = ScanScope(excludesMountedVolumes: excludesMountedVolumes, rootVolumeIdentifier: excludesMountedVolumes ? Self.volumeIdentifier(for: url) : nil)
            let scanned = await DiskScanner.scanNode(at: url, reporter: reporter, cancellation: cancellation, scanScope: scanScope)
            await MainActor.run {
                guard self.activeScanID == scanID else { return }
                self.activeScanID = nil
                self.cancellation = nil
                self.scanTask = nil
                if cancellation.isCancelled || scanned == nil {
                    self.isScanning = false
                    return
                }
                self.root = scanned
                self.isScanning = false
                self.refreshFullDiskAccessStatus()
            }
        }
    }

    nonisolated private static func scanNode(at url: URL, reporter: ScanReporter, cancellation: ScanCancellation, scanScope: ScanScope) async -> DiskNode? {
        await Task.detached(priority: .userInitiated) {
            var progress = ScanProgress()
            var seenFileIDs = Set<String>()
            let node = buildNode(at: url, progress: &progress, reporter: reporter, cancellation: cancellation, scanScope: scanScope, seenFileIDs: &seenFileIDs, isRoot: true)
            reporter.report(progress, force: true)
            return node
        }.value
    }

    nonisolated private static func buildNode(at url: URL, progress: inout ScanProgress, reporter: ScanReporter, cancellation: ScanCancellation, scanScope: ScanScope, seenFileIDs: inout Set<String>, isRoot: Bool = false) -> DiskNode? {
        if cancellation.isCancelled {
            return nil
        }

        if scanScope.excludesMountedVolumes && !isRoot && isSkippedMountPath(url) {
            return nil
        }

        let resourceKeys: Set<URLResourceKey> = [
            .isDirectoryKey,
            .isSymbolicLinkKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
            .isPackageKey,
            .volumeIdentifierKey,
            .fileResourceIdentifierKey
        ]

        let values = try? url.resourceValues(forKeys: resourceKeys)
        if scanScope.excludesMountedVolumes && !isRoot && isDifferentVolume(values: values, scanScope: scanScope) {
            return nil
        }

        let isDirectory = values?.isDirectory == true
        let isSymbolicLink = values?.isSymbolicLink == true
        let name = url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent
        progress.itemsScanned += 1

        if isSymbolicLink {
            reporter.report(progress)
            return DiskNode(name: name, path: url.path, size: 0, fileCount: 0, folderCount: 0, isDirectory: false, children: [])
        }

        if isDirectory {
            progress.foldersScanned += 1
            reporter.report(progress)

            let childURLs = (try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: Array(resourceKeys),
                options: []
            )) ?? []

            var children: [DiskNode] = []
            children.reserveCapacity(childURLs.count)
            for childURL in childURLs {
                if cancellation.isCancelled {
                    return nil
                }
                if let child = buildNode(at: childURL, progress: &progress, reporter: reporter, cancellation: cancellation, scanScope: scanScope, seenFileIDs: &seenFileIDs) {
                    children.append(child)
                }
            }
            children = sortedChildren(children)

            let directSize = UInt64(values?.totalFileAllocatedSize ?? values?.fileAllocatedSize ?? 0)
            let childrenSize = children.reduce(UInt64(0)) { $0 + $1.size }
            let files = children.reduce(0) { $0 + $1.fileCount }
            let folders = children.reduce(0) { $0 + $1.folderCount } + 1

            return DiskNode(
                name: name,
                path: url.path,
                size: directSize + childrenSize,
                fileCount: files,
                folderCount: folders,
                isDirectory: true,
                children: children
            )
        }

        let size = UInt64(values?.totalFileAllocatedSize ?? values?.fileAllocatedSize ?? 0)
        let fileID = values?.fileResourceIdentifier.map { String(describing: $0) }
        let isDuplicateHardLink = fileID.map { seenFileIDs.contains($0) } ?? false
        if let fileID, isDuplicateHardLink == false {
            seenFileIDs.insert(fileID)
        }

        let countedSize = isDuplicateHardLink ? 0 : size
        progress.filesScanned += 1
        progress.duplicateFilesSkipped += isDuplicateHardLink ? 1 : 0
        progress.bytesScanned += countedSize
        reporter.report(progress)
        return DiskNode(name: name, path: url.path, size: countedSize, fileCount: 1, folderCount: 0, isDirectory: false, children: [])
    }

    nonisolated private static func replacingNode(path: String, in node: DiskNode, with replacement: DiskNode) -> (node: DiskNode, didReplace: Bool) {
        if node.path == path {
            return (replacement, true)
        }

        var didReplace = false
        let replacedChildren = node.children.map { child in
            let result = replacingNode(path: path, in: child, with: replacement)
            didReplace = didReplace || result.didReplace
            return result.node
        }

        guard didReplace else {
            return (node, false)
        }

        let sorted = sortedChildren(replacedChildren)
        let childrenSize = sorted.reduce(UInt64(0)) { $0 + $1.size }
        let files = sorted.reduce(0) { $0 + $1.fileCount }
        let folders = sorted.reduce(0) { $0 + $1.folderCount } + (node.isDirectory ? 1 : 0)

        return (DiskNode(
            name: node.name,
            path: node.path,
            size: childrenSize,
            fileCount: files,
            folderCount: folders,
            isDirectory: node.isDirectory,
            children: sorted
        ), true)
    }

    nonisolated private static func sortedChildren(_ children: [DiskNode]) -> [DiskNode] {
        children.sorted {
            if $0.isDirectory != $1.isDirectory {
                return $0.isDirectory && !$1.isDirectory
            }
            if $0.size != $1.size {
                return $0.size > $1.size
            }
            return $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    nonisolated private static func canReadProtectedLocation() -> Bool {
        let protectedPaths = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Mail").path,
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Safari").path
        ]

        return protectedPaths.contains { path in
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue else {
                return false
            }
            return (try? FileManager.default.contentsOfDirectory(atPath: path)) != nil
        }
    }

    nonisolated private static func volumeCapacity(for url: URL) -> UInt64 {
        let values = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey])
        return UInt64(values?.volumeTotalCapacity ?? 0)
    }

    nonisolated private static func volumeIdentifier(for url: URL) -> String? {
        let values = try? url.resourceValues(forKeys: [.volumeIdentifierKey])
        return values?.volumeIdentifier.map { String(describing: $0) }
    }

    nonisolated private static func isDifferentVolume(values: URLResourceValues?, scanScope: ScanScope) -> Bool {
        guard let rootVolumeIdentifier = scanScope.rootVolumeIdentifier else { return false }
        guard let volumeIdentifier = values?.volumeIdentifier.map({ String(describing: $0) }) else { return false }
        return volumeIdentifier != rootVolumeIdentifier
    }

    nonisolated private static func isSkippedMountPath(_ url: URL) -> Bool {
        let path = url.path
        if path == "/Volumes" || path == "/System/Volumes" {
            return false
        }
        return path.hasPrefix("/Volumes/")
            || path.hasPrefix("/System/Volumes/")
            || path == "/Network"
            || path.hasPrefix("/Network/")
            || path == "/net"
            || path.hasPrefix("/net/")
    }
}

final class DiskNode: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let size: UInt64
    let fileCount: Int
    let folderCount: Int
    let isDirectory: Bool
    let children: [DiskNode]

    init(name: String, path: String, size: UInt64, fileCount: Int, folderCount: Int, isDirectory: Bool, children: [DiskNode]) {
        self.name = name
        self.path = path
        self.size = size
        self.fileCount = fileCount
        self.folderCount = folderCount
        self.isDirectory = isDirectory
        self.children = children
    }
}

struct ScanProgress: Sendable {
    var itemsScanned = 0
    var filesScanned = 0
    var foldersScanned = 0
    var bytesScanned: UInt64 = 0
    var duplicateFilesSkipped = 0
}

struct ScanScope: Sendable {
    let excludesMountedVolumes: Bool
    let rootVolumeIdentifier: String?
}

final class ScanReporter: @unchecked Sendable {
    private let lock = NSLock()
    private var lastReport = Date.distantPast
    private let interval: TimeInterval = 0.12
    private let handler: @Sendable (ScanProgress) -> Void

    init(handler: @escaping @Sendable (ScanProgress) -> Void) {
        self.handler = handler
    }

    func report(_ progress: ScanProgress, force: Bool = false) {
        lock.lock()
        let now = Date()
        let shouldReport = force || now.timeIntervalSince(lastReport) >= interval
        if shouldReport {
            lastReport = now
        }
        lock.unlock()

        if shouldReport {
            handler(progress)
        }
    }
}

final class ScanCancellation: @unchecked Sendable {
    private let lock = NSLock()
    private var cancelled = false

    var isCancelled: Bool {
        lock.lock()
        let value = cancelled
        lock.unlock()
        return value
    }

    func cancel() {
        lock.lock()
        cancelled = true
        lock.unlock()
    }
}

extension ByteCountFormatter {
    static let disk: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.includesUnit = true
        formatter.isAdaptive = true
        return formatter
    }()

    static func diskString(_ bytes: UInt64) -> String {
        disk.string(fromByteCount: Int64(clamping: bytes))
    }
}

extension NumberFormatter {
    static func groupedString(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct AppInfo {
    static let name = "MacTreeSize"
    static let version = "0.5.38"
    static let versionDisplay = "v\(version)"
    static let updateManifestURLString = "https://mactreesize.ru/update/"
    static let copyright = "Copyright © 2026 Golovatyuk Alexey"

    static let changelog = [
        ReleaseNote(
            version: "0.5.38",
            date: "2026-06-21",
            items: [
                "Added an in-app language selector with English, Russian, German, French, Spanish, and Chinese.",
                "Localized the main toolbar, access banner, summary, table headers, empty state, About, Updates, and Changelog screens.",
                "Matched the language selector button height and spacing with the other toolbar buttons."
            ]
        ),
        ReleaseNote(
            version: "0.5.37",
            date: "2026-06-18",
            items: [
                "Moved update checks to mactreesize.ru.",
                "Renamed Unique Size and Unique % to Used Size and Used %.",
                "Added space-grouped file and folder counts.",
                "Aligned right-side toolbar, access, summary, and table header columns to the app edge.",
                "Replaced the Root label with the path-copy hint and hid it while Path copied is visible."
            ]
        ),
        ReleaseNote(
            version: "0.5.36",
            date: "2026-06-17",
            items: [
                "Aligned the right edge of Open Settings with the Info toolbar button."
            ]
        ),
        ReleaseNote(
            version: "0.5.35",
            date: "2026-06-17",
            items: [
                "Pinned the Full Disk Access action buttons to the right edge shown in the toolbar layout."
            ]
        ),
        ReleaseNote(
            version: "0.5.34",
            date: "2026-06-17",
            items: [
                "Restored the compact Full Disk Access banner height while keeping its action buttons aligned to the right."
            ]
        ),
        ReleaseNote(
            version: "0.5.33",
            date: "2026-06-17",
            items: [
                "Kept the Full Disk Access action buttons on the right while aligning Open Settings with the Info toolbar button."
            ]
        ),
        ReleaseNote(
            version: "0.5.32",
            date: "2026-06-17",
            items: [
                "Aligned the Full Disk Access Open Settings button with the Info toolbar button at the default window width."
            ]
        ),
        ReleaseNote(
            version: "0.5.31",
            date: "2026-06-17",
            items: [
                "Aligned Full Disk Access action buttons with the main toolbar controls on the default window width."
            ]
        ),
        ReleaseNote(
            version: "0.5.30",
            date: "2026-06-17",
            items: [
                "Removed the update button from About and replaced the default macOS About item with the custom build-number-free About window."
            ]
        ),
        ReleaseNote(
            version: "0.5.29",
            date: "2026-06-16",
            items: [
                "Removed obsolete scan status and current-path state left over from earlier toolbar layouts."
            ]
        ),
        ReleaseNote(
            version: "0.5.28",
            date: "2026-06-16",
            items: [
                "Added clearer macOS folder-permission messaging for automatic updates from Documents, Desktop, or Downloads."
            ]
        ),
        ReleaseNote(
            version: "0.5.27",
            date: "2026-06-16",
            items: [
                "Prepared a test release for the fixed automatic updater."
            ]
        ),
        ReleaseNote(
            version: "0.5.26",
            date: "2026-06-16",
            items: [
                "Fixed the automatic updater so the old app exits reliably before replacement."
            ]
        ),
        ReleaseNote(
            version: "0.5.25",
            date: "2026-06-16",
            items: [
                "Prepared a test release for the automatic update installer."
            ]
        ),
        ReleaseNote(
            version: "0.5.24",
            date: "2026-06-16",
            items: [
                "Added download, install, replace, and restart flow for in-app updates."
            ]
        ),
        ReleaseNote(
            version: "0.5.23",
            date: "2026-06-16",
            items: [
                "Prepared a test release for the hosted update workflow."
            ]
        ),
        ReleaseNote(
            version: "0.5.22",
            date: "2026-06-16",
            items: [
                "Pointed the update checker to the public MacTreeSize update folder."
            ]
        ),
        ReleaseNote(
            version: "0.5.21",
            date: "2026-06-16",
            items: [
                "Made the Update toolbar button turn green when a newer version is available."
            ]
        ),
        ReleaseNote(
            version: "0.5.20",
            date: "2026-06-16",
            items: [
                "Removed the top-right scan status from the toolbar and restored the default window width."
            ]
        ),
        ReleaseNote(
            version: "0.5.19",
            date: "2026-06-16",
            items: [
                "Added an in-app update checker that reads a hosted JSON manifest and opens the download link for newer versions."
            ]
        ),
        ReleaseNote(
            version: "0.5.18",
            date: "2026-06-15",
            items: [
                "Fixed app bundle signing during release packaging to avoid macOS treating the app as damaged after transfer."
            ]
        ),
        ReleaseNote(
            version: "0.5.17",
            date: "2026-06-15",
            items: [
                "Limited very large expanded folders to the first 2,000 visible rows to avoid SwiftUI crashes on huge trees.",
                "Made disk-size formatting safe for extremely large counters."
            ]
        ),
        ReleaseNote(
            version: "0.5.16",
            date: "2026-06-15",
            items: [
                "Restored native macOS system toolbar button styling."
            ]
        ),
        ReleaseNote(
            version: "0.5.15",
            date: "2026-06-15",
            items: [
                "Replaced system toolbar button chrome with a compact custom style."
            ]
        ),
        ReleaseNote(
            version: "0.5.14",
            date: "2026-06-15",
            items: [
                "Reduced toolbar button horizontal padding."
            ]
        ),
        ReleaseNote(
            version: "0.5.13",
            date: "2026-06-15",
            items: [
                "Normalized toolbar button icon widths and horizontal padding."
            ]
        ),
        ReleaseNote(
            version: "0.5.12",
            date: "2026-06-15",
            items: [
                "Fixed the Min % value wrapping when set to 10.0."
            ]
        ),
        ReleaseNote(
            version: "0.5.11",
            date: "2026-06-15",
            items: [
                "Corrected the file visibility button label states."
            ]
        ),
        ReleaseNote(
            version: "0.5.10",
            date: "2026-06-15",
            items: [
                "Fixed the Show Files / Hide Files icon jumping by using a stable icon frame."
            ]
        ),
        ReleaseNote(
            version: "0.5.9",
            date: "2026-06-15",
            items: [
                "Normalized toolbar button heights and centered labels/icons.",
                "Matched Min % labels color and tightened spacing around the slider value."
            ]
        ),
        ReleaseNote(
            version: "0.5.8",
            date: "2026-06-15",
            items: [
                "Removed the separate Scan Disk button.",
                "Renamed Choose Folder to Choose Folder or Disk.",
                "Replaced the file visibility checkbox with a stable button to avoid vertical jumping."
            ]
        ),
        ReleaseNote(
            version: "0.5.7",
            date: "2026-06-15",
            items: [
                "Widened the Hide Files / Show Files toggle so neither label truncates."
            ]
        ),
        ReleaseNote(
            version: "0.5.6",
            date: "2026-06-15",
            items: [
                "Stabilized the Hide Files / Show Files toggle width, font, and vertical alignment.",
                "Added a little more spacing before the Min % slider."
            ]
        ),
        ReleaseNote(
            version: "0.5.5",
            date: "2026-06-15",
            items: [
                "Compacted the right-side summary metrics to leave more room for the Root path.",
                "Changed the file visibility toggle to Hide Files / Show Files behavior."
            ]
        ),
        ReleaseNote(
            version: "0.5.4",
            date: "2026-06-15",
            items: [
                "Increased the default window width.",
                "Kept the scan spinner and status text grouped on the right edge.",
                "Right-aligned scan metrics while keeping the Root path left-aligned.",
                "Clicking the Root path now copies it and shows Path copied feedback."
            ]
        ),
        ReleaseNote(
            version: "0.5.3",
            date: "2026-06-15",
            items: [
                "Removed the currently scanned path from the top-right status.",
                "Renamed the toolbar Open button to Choose Folder."
            ]
        ),
        ReleaseNote(
            version: "0.5.2",
            date: "2026-06-15",
            items: [
                "Added copyright notice for Golovatyuk Alexey to the app metadata and About window."
            ]
        ),
        ReleaseNote(
            version: "0.5.1",
            date: "2026-06-15",
            items: [
                "Expanded folders now stay expanded after rescanning and resorting a subtree."
            ]
        ),
        ReleaseNote(
            version: "0.5.0",
            date: "2026-06-15",
            items: [
                "Folder icons in the tree now open that folder in Finder.",
                "Added per-folder rescan buttons in tree rows.",
                "Per-folder rescan replaces that subtree, recalculates parent sizes, and resorts rows."
            ]
        ),
        ReleaseNote(
            version: "0.4.9",
            date: "2026-06-15",
            items: [
                "Fixed a crash after large disk scans by no longer expanding the entire tree by default.",
                "Only the root node opens initially; child folders expand on demand."
            ]
        ),
        ReleaseNote(
            version: "0.4.8",
            date: "2026-06-15",
            items: [
                "Hard-linked files are now counted by size only once during a scan.",
                "Renamed Found Size and Found % to Unique Size and Unique %."
            ]
        ),
        ReleaseNote(
            version: "0.4.7",
            date: "2026-06-15",
            items: [
                "Moved the user-facing version from the summary bar into the window title.",
                "Renamed Open Folder to Choose Folder in the empty state."
            ]
        ),
        ReleaseNote(
            version: "0.4.6",
            date: "2026-06-15",
            items: [
                "Prevented toolbar button labels from being compressed.",
                "Reduced the Min % slider width and made the scan status shrink before buttons."
            ]
        ),
        ReleaseNote(
            version: "0.4.5",
            date: "2026-06-15",
            items: [
                "Restored the toolbar layout behavior and removed the oversized fixed status area.",
                "Kept a small spinner placeholder so scan start does not nudge the buttons."
            ]
        ),
        ReleaseNote(
            version: "0.4.4",
            date: "2026-06-15",
            items: [
                "Removed build numbers from user-facing version labels.",
                "Fixed toolbar layout shifts when scanning starts or stops."
            ]
        ),
        ReleaseNote(
            version: "0.4.3",
            date: "2026-06-15",
            items: [
                "Scan Disk now stays on the starting volume by volume identifier to avoid crossing into mounted disks.",
                "Found percent is capped at 100% in the interface.",
                "Restored text labels for Changelog and Info toolbar buttons.",
                "Updated the empty-state message and made Stop visibly red while scanning."
            ]
        ),
        ReleaseNote(
            version: "0.4.2",
            date: "2026-06-15",
            items: [
                "Removed duplicated scan counters from the top-right toolbar status.",
                "Kept scan counters in the summary bar for a cleaner default window layout."
            ]
        ),
        ReleaseNote(
            version: "0.4.1",
            date: "2026-06-15",
            items: [
                "Renamed Disk % to Found % so it is not mistaken for scan completion progress.",
                "Changed Scan Disk to skip mounted volume trees such as /Volumes and /System/Volumes.",
                "Reduced accidental double-counting caused by macOS mount points during full disk scans."
            ]
        ),
        ReleaseNote(
            version: "0.4.0",
            date: "2026-06-15",
            items: [
                "Made toolbar utility buttons more compact so Changelog fits at the default window size.",
                "Added scanned bytes as a percentage of the selected disk volume capacity.",
                "Changed Scan Disk to skip remote network volumes mounted under /Volumes.",
                "Added an original app icon and bundled it as a macOS .icns file."
            ]
        ),
        ReleaseNote(
            version: "0.3.0",
            date: "2026-06-15",
            items: [
                "Added Stop button and Command-period shortcut for cancelling active scans.",
                "Added live scanned item, file, folder, and byte counters.",
                "Added current scanned path in the toolbar so long scans visibly move."
            ]
        ),
        ReleaseNote(
            version: "0.2.0",
            date: "2026-06-15",
            items: [
                "Added Full Disk Access status detection and a direct button to macOS Privacy settings.",
                "Added Scan Disk action for scanning the root volume.",
                "Added in-app version display, About window, and Changelog window."
            ]
        ),
        ReleaseNote(
            version: "0.1.0",
            date: "2026-06-15",
            items: [
                "Initial SwiftUI disk usage tree.",
                "Added folder scanning, size sorting, file visibility toggle, and minimum-percent filter.",
                "Added macOS app bundle build script."
            ]
        )
    ]
}

struct ReleaseNote: Identifiable {
    var id: String { version }
    let version: String
    let date: String
    let items: [String]
}
