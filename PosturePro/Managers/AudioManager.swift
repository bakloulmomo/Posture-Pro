//
//  AudioManager.swift
//  PosturePro
//
//  Gestisce l'audio Lo-Fi e l'effetto filtrato in base alla postura.
//

import AVFoundation

@MainActor
final class AudioManager: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var isPlaying: Bool = false
    
    // MARK: - Private
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var eqNode = AVAudioUnitEQ(numberOfBands: 1)
    private var displayLink: CADisplayLink?
    
    private let goodPostureFrequency: Float = 20000.0
    private let badPostureFrequency: Float = 600.0
    private let transitionDuration: TimeInterval = 0.8
    
    // MARK: - Public API
    
    func setupAudio() {
        let filterParams = eqNode.bands[0]
        filterParams.filterType = .lowPass
        filterParams.frequency = goodPostureFrequency
        filterParams.bypass = false
        filterParams.gain = 0
        
        engine.attach(player)
        engine.attach(eqNode)
        engine.connect(player, to: eqNode, format: nil)
        engine.connect(eqNode, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Audio Engine error: \(error)")
        }
    }
    
    func playLoFiTrack() {
        guard let url = Bundle.main.url(forResource: "lofi", withExtension: "mp3") else {
            print("⚠️ File 'lofi.mp3' non trovato. Aggiungilo al bundle.")
            return
        }
        
        do {
            let file = try AVAudioFile(forReading: url)
            player.scheduleFile(file, at: nil) { [weak self] in
                Task { @MainActor in
                    if self?.isPlaying == true {
                        self?.playLoFiTrack()
                    }
                }
            }
            player.play()
            isPlaying = true
        } catch {
            print("Errore caricamento audio: \(error)")
        }
    }
    
    func stopPlayback() {
        player.stop()
        isPlaying = false
    }
    
    func adjustEffect(isGoodPosture: Bool) {
        let targetFreq = isGoodPosture ? goodPostureFrequency : badPostureFrequency
        eqNode.bands[0].frequency = targetFreq
    }
}
