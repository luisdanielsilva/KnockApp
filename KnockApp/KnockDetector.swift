import Foundation
import AVFoundation
import AppKit
import Combine // Import for ObservableObject

class KnockDetector: ObservableObject {
    private let engine = AVAudioEngine()
    @Published var isListening = false
    
    // Sensitivity: Set to 0.040 
    // Requires a firm knock, ignores typing noise.
    private let knockThreshold: Float = 0.040
    
    // Prevents echo from triggering multiple knocks
    private var lastKnockTime = Date.distantPast
    
    // List of 10 funny built-in system sounds
    private let randomSounds = [
        "Hero", "Submarine", "Funk", "Basso", "Bottle", 
        "Frog", "Glass", "Ping", "Purr", "Tink"
    ]
    
    // Real-time custom folder usage toggle
    private var useCustomSounds: Bool {
        UserDefaults.standard.bool(forKey: "useCustomSounds")
    }
    
    init() {
        createCustomSoundsFolderIfNeeded()
        // Automatically starts listening
        start()
    }
    
    // Creates 'KnockSounds' in the Music directory if it doesn't exist
    private func createCustomSoundsFolderIfNeeded() {
        let fileManager = FileManager.default
        guard let musicFolder = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first else { return }
        let customSoundsFolder = musicFolder.appendingPathComponent("KnockSounds")
        
        if !fileManager.fileExists(atPath: customSoundsFolder.path) {
            do {
                try fileManager.createDirectory(at: customSoundsFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating KnockSounds folder: \(error)")
            }
        }
    }
    
    func start() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            guard granted, let self = self else {
                print("Audio permission denied.")
                return
            }
            self.setupEngine()
        }
    }
    
    private func setupEngine() {
        let inputNode = engine.inputNode
        let bus = 0
        let format = inputNode.inputFormat(forBus: bus)
        
        inputNode.removeTap(onBus: bus)
        
        inputNode.installTap(onBus: bus, bufferSize: 1024, format: format) { [weak self] (buffer, time) in
            self?.processBuffer(buffer)
        }
        
        do {
            try engine.start()
            DispatchQueue.main.async { self.isListening = true }
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        DispatchQueue.main.async { self.isListening = false }
    }
    
    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = UInt(buffer.frameLength)
        
        var rms: Float = 0.0
        for i in 0..<Int(frameLength) {
            let sample = channelData[i]
            rms += sample * sample
        }
        rms = sqrt(rms / Float(frameLength))
        
        // 0.3 second debounce pause
        if Date().timeIntervalSince(lastKnockTime) < 0.3 { return }
        
        // If vibration exceeds the threshold:
        if rms > knockThreshold {
            // FIX: Lock immediately to prevent race conditions
            lastKnockTime = Date() 
            
            if useCustomSounds {
                playCustomSound()
            } else {
                let somEscolhido = randomSounds.randomElement() ?? "Pop"
                play(sound: somEscolhido)
            }
        }
    }
    
    // Dedicated method for custom folder playback
    private func playCustomSound() {
        let fileManager = FileManager.default
        guard let musicFolder = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first else { return }
        let customSoundsFolder = musicFolder.appendingPathComponent("KnockSounds")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: customSoundsFolder, includingPropertiesForKeys: nil)
            let supportedFiles = files.filter { ["mp3", "wav", "m4a", "aif", "aiff"].contains($0.pathExtension.lowercased()) }
            
            if let customSoundURL = supportedFiles.randomElement() {
                lastKnockTime = Date()
                DispatchQueue.main.async {
                    if let som = NSSound(contentsOf: customSoundURL, byReference: true) {
                        som.play()
                    }
                }
            } else {
                showEmptyFolderAlert()
            }
        } catch {
            showEmptyFolderAlert()
        }
    }
    
    private func showEmptyFolderAlert() {
        lastKnockTime = Date()
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Empty Custom Folder"
            alert.informativeText = "You don't have any sounds in your Music/KnockSounds folder, so I opened this window instead!"
            alert.addButton(withTitle: "OK")
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }
    
    private func play(sound: String) {
        lastKnockTime = Date()
        DispatchQueue.main.async {
            NSSound(named: sound)?.play()
        }
    }
}
