//
//  HapticsManager.swift
//  PosturePro
//
//  CoreHaptics per feedback aptico quando la postura peggiora.
//

import CoreHaptics
import UIKit

final class HapticsManager {
    
    static let shared = HapticsManager()
    
    private var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    
    private init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        guard supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            engine?.stoppedHandler = { [weak self] _ in
                self?.engine?.reset()
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
        } catch {
            print("CoreHaptics error: \(error)")
        }
    }
    
    /// Doppio tap leggero: "raddrizza la schiena"
    func playPostureWarning() {
        guard supportsHaptics, let engine = engine else {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        
        do {
            try engine.start()
            
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
            
            let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
            let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0.15)
            
            let pattern = try CHHapticPattern(events: [event1, event2], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
}
