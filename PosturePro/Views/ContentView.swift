//
//  ContentView.swift
//  PosturePro
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var postureManager = PostureManager()
    @StateObject private var audioManager = AudioManager()
    @State private var plantSceneInstance: PlantScene?
    
    private var plantScene: PlantScene {
        if let existing = plantSceneInstance { return existing }
        let scene = PlantScene()
        scene.size = CGSize(width: AppTheme.Layout.plantSceneWidth, height: AppTheme.Layout.plantSceneHeight)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .clear
        DispatchQueue.main.async { plantSceneInstance = scene }
        return scene
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.md) {
                    plantSection
                    statusCard
                    actionSection
                    #if DEBUG
                    debugSection
                    #endif
                }
                .padding(AppTheme.Spacing.sm)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("SpineSprout")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: postureManager.isPostureGood) { _, newValue in
            handlePostureChange(newValue)
        }
    }
}

// MARK: - Sections

private extension ContentView {
    
    var plantSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.plantCard)
                .fill(.ultraThinMaterial)
                .frame(height: AppTheme.Layout.plantSceneHeight + AppTheme.Spacing.xs)
            
            SpriteView(scene: plantScene, options: [.allowsTransparency])
                .frame(width: AppTheme.Layout.plantSceneWidth, height: AppTheme.Layout.plantSceneHeight)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
    
    var statusCard: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            statusIcon
            statusText
            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.sm)
        .frame(minHeight: AppTheme.Layout.minTouchTarget + AppTheme.Spacing.xxs)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .animation(.easeInOut(duration: 0.3), value: postureManager.isPostureGood)
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        Image(systemName: postureManager.isPostureGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
            .font(.system(size: 44))
            .foregroundStyle(postureManager.isPostureGood ? AppTheme.Colors.success : AppTheme.Colors.warning)
    }
    
    @ViewBuilder
    private var statusText: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
            Text(postureManager.isPostureGood ? "Postura ottima" : "Raddrizza la schiena")
                .font(AppTheme.Typography.headline)
                .foregroundStyle(.primary)
            Text(postureManager.isPostureGood ? "Continua così!" : "La pianta ha bisogno di te")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    var actionSection: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            if !postureManager.isMonitoring {
                primaryButton
            } else {
                secondaryButton
            }
        }
    }
    
    private var primaryButton: some View {
        Button { startSession() } label: {
            Label("Calibra e inizia", systemImage: "play.circle.fill")
                .font(AppTheme.Typography.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppTheme.Layout.minTouchTarget)
                .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .buttonStyle(.borderedProminent)
        .tint(AppTheme.Colors.success)
    }
    
    private var secondaryButton: some View {
        Button(role: .destructive) { endSession() } label: {
            Label("Ferma sessione", systemImage: "stop.circle.fill")
                .font(AppTheme.Typography.headline)
                .frame(maxWidth: .infinity)
                .frame(minHeight: AppTheme.Layout.minTouchTarget)
                .padding(.horizontal, AppTheme.Spacing.sm)
        }
        .buttonStyle(.bordered)
    }
    
    #if DEBUG
    var debugSection: some View {
        DisclosureGroup("Simulatore (no AirPods)") {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                Slider(
                    value: Binding(
                        get: { postureManager.currentPitch },
                        set: { postureManager.simulatePitch($0) }
                    ),
                    in: -40...40
                )
                Text("Angolo: \(Int(postureManager.currentPitch))°")
                    .font(AppTheme.Typography.captionMuted)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, AppTheme.Spacing.xxs)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
    }
    #endif
}

// MARK: - Actions

private extension ContentView {
    
    func startSession() {
        postureManager.calibrateAndStart()
        audioManager.setupAudio()
        audioManager.playLoFiTrack()
    }
    
    func endSession() {
        postureManager.stopMonitoring()
        audioManager.stopPlayback()
    }
    
    func handlePostureChange(_ isGood: Bool) {
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
