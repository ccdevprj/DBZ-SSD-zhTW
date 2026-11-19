import AppKit
import Foundation
import UniformTypeIdentifiers
let fm = FileManager.default
let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("DBZ SSD RC2")
let bundle = Bundle.main
let res = bundle.resourceURL!
let game = bundle.bundleURL.appendingPathComponent("Contents/MacOS/ssd-recompiled")
func dialog(_ title: String, _ msg: String, _ buttons: [String]) -> Int {
    let a = NSAlert(); a.messageText = title; a.informativeText = msg
    for b in buttons { a.addButton(withTitle: b) }
    return a.runModal().rawValue - 1000
}
func pick(_ title: String, _ exts: [String]) -> URL? {
    let p = NSOpenPanel(); p.title = title; p.canChooseDirectories = false
    p.allowsMultipleSelection = false
    p.allowedContentTypes = exts.compactMap { UTType(filenameExtension: $0) }
    return p.runModal() == .OK ? p.url : nil
}
NSApplication.shared.setActivationPolicy(.accessory)
NSApplication.shared.activate(ignoringOtherApps: true)
do {
    try fm.createDirectory(at: base.appendingPathComponent("fonts"), withIntermediateDirectories: true)
    for s in ["zh-tw.tsv", "ui-zh-tw.tsv", "zh-hk.tsv", "ui-zh-hk.tsv", "fonts/LXGWWenKaiTC-Regular.ttf"] {
        let dst = base.appendingPathComponent(s)
        if !fm.fileExists(atPath: dst.path) { try fm.copyItem(at: res.appendingPathComponent(s), to: dst) }
    }
    var args = ["--mode", "enhanced", "--hd-scale", "4"]
    if !fm.fileExists(atPath: base.appendingPathComponent("cache/rom/canonical.sfc").path) {
        let kind = dialog("七龍珠Z 超賽亞傳說", "Select your own game file. For Japanese Rev 1, also select the Klepto v1.02 IPS patch. Your originals stay unchanged.", ["Patched English ROM", "Japanese ROM + IPS", "Cancel"])
        guard kind < 2, let rom = pick("Choose your game ROM", ["sfc", "smc"]) else { exit(0) }
        args += ["--rom", rom.path]
        if kind == 1 { guard let ips = pick("Choose dbz102.ips", ["ips"]) else {exit(0)}; args += ["--ips", ips.path] }
    }
    let p = Process(); p.executableURL = game; p.arguments = args
    p.currentDirectoryURL = base
    var env = ProcessInfo.processInfo.environment; env["SSD_DATA_DIR"] = base.path; p.environment = env
    let log = base.appendingPathComponent("Last Run.log"); try Data().write(to: log)
    let handle = try FileHandle(forWritingTo: log); p.standardError = handle; p.standardOutput = handle
    try p.run(); p.waitUntilExit(); try handle.close()
    if p.terminationStatus != 0 { _ = dialog("Game stopped", "See " + log.path + " for details.", ["OK"]) }
    exit(p.terminationStatus)
} catch { _ = dialog("Could not start", error.localizedDescription, ["OK"]); exit(1) }
