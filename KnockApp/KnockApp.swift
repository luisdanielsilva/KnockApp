import SwiftUI

@main
struct KnockApp: App {
    @StateObject private var detector = KnockDetector()
    @AppStorage("useCustomSounds") private var useCustomSounds = false
    
    var body: some Scene {
        MenuBarExtra {
            
            Text("Status: Always Listening...")
            
            Divider()
            
            Toggle("Use My Sounds Folder", isOn: $useCustomSounds)
            
            Button("Open Sounds Folder...") {
                let fileManager = FileManager.default
                if let musicFolder = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first {
                    let customSoundURL = musicFolder.appendingPathComponent("KnockSounds")
                    NSWorkspace.shared.open(customSoundURL)
                }
            }
            
            Divider()
            
            // Info Button
            Button("About App") {
                let alert = NSAlert()
                alert.messageText = "KnockApp"
                alert.informativeText = "Version: 1.0\nLead Creator: Antigravity (Gemini)\nCo-Creator: Luís Silva"
                alert.addButton(withTitle: "OK")
                
                // Convert Drum Emoji into NSImage
                let emoji = "🥁"
                let font = NSFont.systemFont(ofSize: 64)
                let string = NSAttributedString(string: emoji, attributes: [.font: font])
                let image = NSImage(size: string.size())
                image.lockFocus()
                string.draw(at: .zero)
                image.unlockFocus()
                alert.icon = image
                
                // Force window to foreground
                NSApp.activate(ignoringOtherApps: true)
                alert.runModal()
            }
            
            Divider()
            
            Button("Quit") {
                detector.stop()
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text("🥁")
        }
    }
}
