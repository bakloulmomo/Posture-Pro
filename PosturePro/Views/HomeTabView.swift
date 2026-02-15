//
//  HomeTabView.swift
//  PosturePro
//

import SwiftUI
import SpriteKit

struct HomeTabView: View {
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
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.md) {
                        plantSection
                        statusCard
                        #if DEBUG
                        debugSection
                        #endif
                        Spacer(minLength: AppTheme.Spacing.lg)
                    }
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.top, AppTheme.Spacing.xxs)
                }
                
                actionBar
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("SpineSprout")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: postureManager.isPostureGood) { newValue in
            handlePostureChange(newValue)
        }
    }
}

// MARK: - Sections

private extension HomeTabView {
    
    var plantSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.plantCard)
                .fill(.ultraThinMaterial)
                .frame(minHeight: AppTheme.Layout.plantSceneHeight + AppTheme.Spacing.sm)
            
            SpriteView(scene: plantScene, options: [.allowsTransparency])
                .frame(width: AppTheme.Layout.plantSceneWidth, height: AppTheme.Layout.plantSceneHeight)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                .allowsHitTesting(false)
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
    
    var statusCard: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: postureManager.isPostureGood ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(postureManager.isPostureGood ? AppTheme.Colors.success : AppTheme.Colors.warning)
            
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxxs) {
                Text(postureManager.isPostureGood ? "Postura ottima" : "Raddrizza la schiena")
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(.primary)
                Text(postureManager.isPostureGood ? "Continua così!" : "Tieni la schiena dritta")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(AppTheme.Spacing.sm)
        .background(AppTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .animation(.easeInOut(duration: 0.3), value: postureManager.isPostureGood)
    }
    
    var actionBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                if !postureManager.isMonitoring {
                    startButton
                } else {
                    stopButton
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.cardBackground)
        }
        .background(AppTheme.Colors.cardBackground)
    }
    
    private var startButton: some View {
        Button {
            startSession()
        } label: {
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: "play.circle.fill")
                Text("Calibra e inizia")
                    .fontWeight(.semibold)
            }
            .font(.body)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Layout.minTouchTarget)
            .background(AppTheme.Colors.success)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
        }
        .buttonStyle(.plain)
    }
    
    private var stopButton: some View {
        Button {
            endSession()
        } label: {
            HStack(spacing: AppTheme.Spacing.xxs) {
                Image(systemName: "stop.circle.fill")
                Text("Ferma sessione")
                    .fontWeight(.semibold)
            }
            .font(.body)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.Layout.minTouchTarget)
            .background(Color.red.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
        }
        .buttonStyle(.plain)
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

private extension HomeTabView {
    
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
            HapticsManager.shared.playPostureWarning()
        }
        audioManager.adjustEffect(isGoodPosture: isGood)
        (plantSceneInstance ?? plantScene).updatePostureState(isGood: isGood)
    }
}

#Preview {
    HomeTabView()
}
