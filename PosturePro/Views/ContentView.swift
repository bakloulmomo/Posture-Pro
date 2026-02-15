//
//  ContentView.swift
//  PosturePro
//
//  Interfaccia principale con design Apple Human Interface Guidelines.
//

import SwiftUI
import SpriteKit
import CoreHaptics

struct ContentView: View {
    @StateObject private var postureManager = PostureManager()
    @StateObject private var audioManager = AudioManager()
    
    @State private var plantSceneInstance: PlantScene?
    
    private var plantScene: PlantScene {
        if let existing = plantSceneInstance { return existing }
        let scene = PlantScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        DispatchQueue.main.async { plantSceneInstance = scene }
        return scene
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero: Pianta SpriteKit
                    plantSection
                    
                    // Stato postura
                    statusCard
                    
                    // Azioni
                    actionSection
                    
                    #if DEBUG
                    debugSection
                    #endif
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SpineSprout")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: postureManager.isPostureGood) { _, newValue in
            handlePostureChange(newValue)
        }
    }
    
    // MARK: - Subviews
    
    private var plantSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .frame(height: 420)
            
            SpriteView(scene: plantScene, options: [.allowsTransparency])
                .frame(width: 300, height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.vertical, 8)
    }
    
    private var statusCard: some View {
        HStack(spacing: 16) {
            Image(systemName: postureManager.isPostureGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(postureManager.isPostureGood ? Color.green : Color.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(postureManager.isPostureGood ? "Postura ottima" : "Raddrizza la schiena")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(postureManager.isPostureGood ? "Continua così!" : "La pianta ha bisogno di te")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut(duration: 0.3), value: postureManager.isPostureGood)
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            if !postureManager.isMonitoring {
                Button {
                    startSession()
                } label: {
                    Label("Calibra e inizia", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            } else {
                Button(role: .destructive) {
                    endSession()
                } label: {
                    Label("Ferma sessione", systemImage: "stop.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    #if DEBUG
    private var debugSection: some View {
        DisclosureGroup("Simulatore (no AirPods)") {
            VStack(alignment: .leading, spacing: 8) {
                Slider(value: Binding(
                    get: { postureManager.currentPitch },
                    set: { postureManager.simulatePitch($0) }
                ), in: -40...40)
                Text("Angolo: \(Int(postureManager.currentPitch))°")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    #endif
    
    // MARK: - Actions
    
    private func startSession() {
        postureManager.calibrateAndStart()
        audioManager.setupAudio()
        audioManager.playLoFiTrack()
    }
    
    private func endSession() {
        postureManager.stopMonitoring()
        audioManager.stopPlayback()
    }
    
    private func handlePostureChange(_ isGood: Bool) {
        if !isGood {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
        audioManager.adjustEffect(isGoodPosture: isGood)
        (plantSceneInstance ?? plantScene).updatePostureState(isGood: isGood)
    }
}

#Preview {
    ContentView()
}
