//
//  PostureManager.swift
//  PosturePro
//
//  Gestisce il monitoraggio della postura tramite sensori AirPods (CMHeadphoneMotionManager).
//

import Foundation
import CoreMotion
import Combine

@MainActor
final class PostureManager: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var isPostureGood: Bool = true
    @Published private(set) var currentPitch: Double = 0.0
    @Published private(set) var isMonitoring: Bool = false
    @Published private(set) var isHeadphonesAvailable: Bool = false
    @Published private(set) var errorMessage: String?
    
    // MARK: - Private
    private let motionManager = CMHeadphoneMotionManager()
    private var referencePitch: Double = 0.0
    private let badPostureThreshold: Double = 15.0
    private let hysteresisMargin: Double = 2.0
    
    // MARK: - Public API
    
    func calibrateAndStart() {
        errorMessage = nil
        referencePitch = currentPitch
        startMonitoring()
    }
    
    func startMonitoring() {
        guard motionManager.isDeviceMotionAvailable else {
            isHeadphonesAvailable = false
            errorMessage = "AirPods non rilevati. Usa lo slider di simulazione."
            return
        }
        
        isHeadphonesAvailable = true
        isMonitoring = true
        errorMessage = nil
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            Task { @MainActor in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                guard let self = self, let motion = motion else { return }
                let pitchDegrees = motion.attitude.pitch * (180 / .pi)
                self.processPitch(pitchDegrees)
            }
        }
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
    
    /// Per testing nel simulatore (senza AirPods)
    func simulatePitch(_ value: Double) {
        processPitch(value)
    }
    
    // MARK: - Internal Logic
    
    private func processPitch(_ pitch: Double) {
        currentPitch = pitch
        let delta = referencePitch - pitch
        
        // Isteresi per evitare flickering
        if delta > badPostureThreshold {
            if isPostureGood { isPostureGood = false }
        } else if delta < (badPostureThreshold - hysteresisMargin) {
            if !isPostureGood { isPostureGood = true }
        }
    }
}
