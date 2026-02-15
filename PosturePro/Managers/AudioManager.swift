//
//  AudioManager.swift
//  PosturePro
//
//  AVAudioEngine per riproduzione Lo-Fi con Low Pass EQ in tempo reale.
//  Postura cattiva → filtro a 500Hz = suono ovattato.
//

import AVFoundation

final class AudioManager: ObservableObject {
    
    @Published private(set) var isPlaying: Bool = false
    
    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var eqNode: AVAudioUnitEQ?
    private var format: AVAudioFormat?
    
    private let goodPostureHz: Float = 20000
    private let badPostureHz: Float = 500
    
    func setupAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "lofi", withExtension: "mp3") else {
            print("⚠️ lofi.mp3 non trovato nel bundle")
            return
        }
        
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        let eq = AVAudioUnitEQ(numberOfBands: 1)
        
        let band = eq.bands[0]
        band.filterType = .lowPass
        band.frequency = goodPostureHz
        band.bandwidth = 1
        band.gain = 0
        band.bypass = false
        
        engine.attach(player)
        engine.attach(eq)
        
        let file: AVAudioFile
        do {
            file = try AVAudioFile(forReading: url)
        } catch {
            print("AVAudioFile error: \(error)")
            return
        }
        
        format = file.processingFormat
        guard let format = format else { return }
        
        engine.connect(player, to: eq, format: format)
        engine.connect(eq, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("AVAudioEngine start error: \(error)")
            return
        }
        
        self.engine = engine
        self.playerNode = player
        self.eqNode = eq
    }
    
    func playLoFiTrack() {
        if playerNode == nil {
            setupAudio()
        }
        guard let player = playerNode else { return }
        
        guard let url = Bundle.main.url(forResource: "lofi", withExtension: "mp3") else { return }
        
        do {
            let file = try AVAudioFile(forReading: url)
            player.scheduleFile(file, at: nil) { [weak self] in
                DispatchQueue.main.async {
                    if self?.isPlaying == true {
                        self?.playLoFiTrack()
                    }
                }
            }
            player.play()
            DispatchQueue.main.async { self.isPlaying = true }
        } catch {
            print("scheduleFile error: \(error)")
        }
    }
    
    func stopPlayback() {
        playerNode?.stop()
        engine?.stop()
        DispatchQueue.main.async { self.isPlaying = false }
    }
    
    func adjustEffect(isGoodPosture: Bool) {
        let targetHz = isGoodPosture ? goodPostureHz : badPostureHz
        eqNode?.bands[0].frequency = targetHz
    }
}
