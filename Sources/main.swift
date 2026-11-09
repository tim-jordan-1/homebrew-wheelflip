import AppKit
import ApplicationServices
import ServiceManagement

private let onScrollEvent: CGEventTapCallBack = { _, type, event, info in
    let app = Unmanaged<App>.fromOpaque(info!).takeUnretainedValue()
    if type == .scrollWheel {
        app.handle(event)
    } else {
        // macOS turns a tap off after a timeout or heavy input.
        app.enableTap()
    }
    return Unmanaged.passUnretained(event)
}

final class App: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let stateLine = NSMenuItem()
    private let countLine = NSMenuItem()
    private let verticalItem = NSMenuItem(title: "Invert Vertical Scrolling", action: #selector(toggleVertical), keyEquivalent: "")
    private let horizontalItem = NSMenuItem(title: "Invert Horizontal Scrolling", action: #selector(toggleHorizontal), keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Open at Login", action: #selector(toggleLogin), keyEquivalent: "")
    private let settingsItem = NSMenuItem(title: "Open Accessibility Settings…", action: #selector(openSettings), keyEquivalent: "")

    private var tap: CFMachPort?
    private var tapSource: CFRunLoopSource?
    private var invertVertical = true
    private var invertHorizontal = false
    private var mouseEvents = 0
    private var trackpadEvents = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["InvertVertical": true, "InvertHorizontal": false])
        invertVertical = UserDefaults.standard.bool(forKey: "InvertVertical")
        invertHorizontal = UserDefaults.standard.bool(forKey: "InvertHorizontal")

        let menu = NSMenu()
        menu.delegate = self
        menu.autoenablesItems = false
        stateLine.isEnabled = false
        countLine.isEnabled = false
        for item in [stateLine, countLine, .separator(), verticalItem, horizontalItem, .separator(), loginItem, settingsItem, .separator()] {
            item.target = self
            menu.addItem(item)
        }
        menu.addItem(withTitle: "Quit WheelFlip", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu

        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
        refresh()
        // Permission can be granted or revoked at any time, and macOS sends no notification for it.
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.refresh() }
    }

    func handle(_ event: CGEvent) {
        if flipMouseScroll(event, vertical: invertVertical, horizontal: invertHorizontal) {
            mouseEvents += 1
        } else {
            trackpadEvents += 1
        }
    }

    func enableTap() {
        if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
    }

    private func refresh() {
        if !AXIsProcessTrusted() {
            removeTap()
        } else if tap == nil {
            createTap()
        } else if let tap, !CGEvent.tapIsEnabled(tap: tap) {
            enableTap()
        }
        updateIcon()
    }

    private func createTap() {
        guard let port = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
            callback: onScrollEvent,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }
        let source = CFMachPortCreateRunLoopSource(nil, port, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: port, enable: true)
        tap = port
        tapSource = source
    }

    private func removeTap() {
        guard let tap else { return }
        CFRunLoopRemoveSource(CFRunLoopGetMain(), tapSource, .commonModes)
        CFMachPortInvalidate(tap)
        self.tap = nil
        tapSource = nil
    }

    private func updateIcon() {
        let image = tap == nil ? NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil) : NSImage(named: "MenuBarIconTemplate")
        image?.accessibilityDescription = tap == nil ? "WheelFlip is not active" : "WheelFlip is active"
        statusItem.button?.image = image
    }

    func menuWillOpen(_ menu: NSMenu) {
        let trusted = AXIsProcessTrusted()
        stateLine.title = tap != nil ? "Active" : trusted ? "Not active: quit and reopen WheelFlip" : "Not active: needs Accessibility access"
        countLine.title = "Mouse events: \(mouseEvents), trackpad events ignored: \(trackpadEvents)"
        verticalItem.state = invertVertical ? .on : .off
        horizontalItem.state = invertHorizontal ? .on : .off
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        settingsItem.isHidden = trusted
    }

    @objc private func toggleVertical() {
        invertVertical.toggle()
        UserDefaults.standard.set(invertVertical, forKey: "InvertVertical")
    }

    @objc private func toggleHorizontal() {
        invertHorizontal.toggle()
        UserDefaults.standard.set(invertHorizontal, forKey: "InvertHorizontal")
    }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
    }

    @objc private func openSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}

let delegate = App()
NSApplication.shared.delegate = delegate
NSApplication.shared.run()
