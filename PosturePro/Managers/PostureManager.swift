//
//  PostureManager.swift
//  PosturePro
//
//  Monitora la postura tramite CMHeadphoneMotionManager (AirPods Pro/Max).
//  Pitch positivo = chin down (cattiva postura). Calibrazione imposta lo "zero" corretto.
//

import Foundation
import CoreMotion

@MainActor
final class PostureManager: ObservableObject {
    
    @Published private(set) var isPostureGood: Bool = true
    @Published private(set) var currentPitch: Double = 0.0
    @Published private(set) var isMonitoring: Bool = false
    @Published private(set) var isHeadphonesAvailable: Bool = false
    @Published private(set) var errorMessage: String?
    
    private let motionManager = CMHeadphoneMotionManager()
    private var referencePitch: Double = 0.0
    private let badPostureThresholdDegrees: Double = 12.0
    private let hysteresisDegrees: Double = 3.0
    
    func calibrateAndStart() {
        errorMessage = nil
        referencePitch = currentPitch
        startMonitoring()
    }
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else {
            isHeadphonesAvailable = false
            errorMessage = "Collega gli AirPods Pro o Max per usare il sensore."
            return
        }
        
        isHeadphonesAvailable = true
        isMonitoring = true
        errorMessage = nil
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async { self.errorMessage = error.localizedDescription }
                return
            }
            guard let motion = motion else { return }
            let pitchDegrees = motion.attitude.pitch * (180.0 / .pi)
            self.processPitch(pitchDegrees)
        }
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
    
    func simulatePitch(_ value: Double) {
        processPitch(value)
    }
    
    /// Pitch aumenta quando guardi in basso (chin down). Soglia superata = postura cattiva.
    private func processPitch(_ pitchDegrees: Double) {
        currentPitch = pitchDegrees
        let delta = pitchDegrees - referencePitch
        
        if delta > badPostureThresholdDegrees {
            if isPostureGood { isPostureGood = false }
        } else if delta < (badPostureThresholdDegrees - hysteresisDegrees) {
            if !isPostureGood { isPostureGood = true }
        }
    }
}
