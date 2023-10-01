//
//  ContentView.swift
//  AudioProcessor
//

import SwiftUI
import AVFoundation

class AudioRecorder: ObservableObject {
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var isReverbEnabled = false
    @Published var isDelayEnabled = false
    @Published var isDistortionEnabled = false
    var audioEngine = AVAudioEngine()
    var audioPlayerNode = AVAudioPlayerNode()
    var audioReverb = AVAudioUnitReverb()
    var audioDistortion = AVAudioUnitDistortion()
    var audioDelay = AVAudioUnitDelay()
    var audioRecorder: AVAudioRecorder?

    init() {
        setupAudio()
    }

    func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Attaching processing nodes to audio engine
            audioEngine.attach(audioPlayerNode)
            audioEngine.attach(audioReverb)
            audioEngine.attach(audioDistortion)
            audioEngine.attach(audioDelay)
            
            // Connecting nodes to creat audio processing graph
            audioEngine.connect(audioPlayerNode, to: audioReverb, format: nil)
            audioEngine.connect(audioReverb, to: audioDistortion, format: nil)
            audioEngine.connect(audioDistortion, to: audioDelay, format: nil)
            audioEngine.connect(audioDelay, to: audioEngine.outputNode, format: nil)
            
            try audioEngine.start()
            
        } catch {
            print("Error setting up audio: \(error.localizedDescription)")
        }
    }

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("myAudioRecording.wav")
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
            isRecording = false
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
    }

    func playAudio() {
        if audioRecorder != nil {
            do {
                let audioFile = try AVAudioFile(forReading: audioRecorder!.url)
                audioPlayerNode.stop()
                audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
                audioPlayerNode.play()
                isPlaying = true
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
        }
    }
    
    func stopAudio() {
        audioPlayerNode.stop()
        isPlaying = false
    }

    func toggleReverb() {
        isReverbEnabled.toggle()
        let preset: AVAudioUnitReverbPreset = isReverbEnabled ? .largeHall : .cathedral
        audioReverb.loadFactoryPreset(preset)
        audioReverb.wetDryMix = isReverbEnabled ? 50 : 0
    }
    
    func toggleDistortion() {
        isDistortionEnabled.toggle()
        let preset: AVAudioUnitDistortionPreset = isDistortionEnabled ? .drumsBitBrush : .drumsLoFi
        audioDistortion.loadFactoryPreset(preset)
        audioDistortion.wetDryMix = isDistortionEnabled ? 50 : 0
    }
    
    func toggleDelay() {
        isDelayEnabled.toggle()
        audioDelay.wetDryMix = isDelayEnabled ? 50 : 0
    }

    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct ContentView: View {
    @ObservedObject var audioRecorder = AudioRecorder()

    var body: some View {
        VStack {
            Button(action: {
                audioRecorder.isRecording ? audioRecorder.stopRecording() : audioRecorder.startRecording()})
            {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
            }
            .padding()

            Button(action: {
                audioRecorder.isPlaying ? audioRecorder.stopAudio() : audioRecorder.playAudio()})
            {
                Text(audioRecorder.isPlaying ? "Stop Audio" : "Play Audio")
            }
            .padding()

            Button(action: {
                audioRecorder.toggleReverb()})
            {
                Text("Toggle Reverb")
            }
            .padding()
            
            Button(action: {
                audioRecorder.toggleDistortion()})
            {
                Text("Toggle Distortion")
            }
            .padding()
            
            Button(action: {
                audioRecorder.toggleDelay()})
            {
                Text("Toggle Delay")
            }
            .padding()
        }
    }
}




