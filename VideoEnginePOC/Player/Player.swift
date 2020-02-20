//
//  Player.swift
//  NexusPOC
//
//  Created by Chris Baltzer on 2019-12-04.
//  Copyright © 2019 Chris Baltzer. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation


class Player {

    // Renderers
    private var synchronizer: AVSampleBufferRenderSynchronizer = AVSampleBufferRenderSynchronizer()
    private var videoRenderer: AVSampleBufferDisplayLayer
    private var audioRenderer: AVSampleBufferAudioRenderer
    
    // Assets
    private var asset: AVAsset?
    private var reader: AVAssetReader?
    
    
    // Accessors for UI
    public var displayLayer: AVSampleBufferDisplayLayer {
        get {
            return videoRenderer
        }
    }
    
    public var frame: CGRect {
        get {
            return displayLayer.frame
        }
        set {
            displayLayer.frame = newValue
        }
    }

    
    init() {
        synchronizer.setRate(0.0, time: .zero)
        
        // video setup
        videoRenderer = AVSampleBufferDisplayLayer()
        videoRenderer.videoGravity = .resizeAspect
        videoRenderer.backgroundColor = UIColor.black.cgColor
        synchronizer.addRenderer(videoRenderer)
        
        // audio set
        audioRenderer = AVSampleBufferAudioRenderer()
        synchronizer.addRenderer(audioRenderer)
    }
        
    
    func load(url: URL) {
        do {

            print("Creating asset")
            asset = AVURLAsset(url: url)
                
            print("Creating asset reader")
            reader = try AVAssetReader(asset: asset!)
        
            var videoOutput: AVAssetReaderTrackOutput? = nil
            var audioOutput: AVAssetReaderTrackOutput? = nil
            if let track = asset?.tracks(withMediaType: .video).first {
                print("Found video track, adding reader output")
                videoOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
                reader!.add(videoOutput!)
            }
            
            if let track = asset?.tracks(withMediaType: .audio).first {
                print("Found audio track, adding reader output")
                audioOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
                reader!.add(audioOutput!)
            }
            
            self.startReading(reader: reader, videoOutput: videoOutput, audioOutput: audioOutput)
            
        } catch {
            print("Error setting up asset reader: \(error)")
        }
        
    }
    
    
    func startReading(reader: AVAssetReader?,
                      videoOutput: AVAssetReaderTrackOutput?,
                      audioOutput: AVAssetReaderTrackOutput?) {
        
        guard reader != nil, videoOutput != nil, audioOutput != nil else {
            print("Reader misconfigured")
            return
        }
        
        if (reader?.startReading())! {
            print("Starting reading")
            startRequestingMediaData(renderer: videoRenderer, output: videoOutput!)
            startRequestingMediaData(renderer: audioRenderer, output: audioOutput!)
        }
    }
    
    
    func startRequestingMediaData(renderer: AVQueuedSampleBufferRendering, output: AVAssetReaderTrackOutput) {
        print("Renderer \(renderer) requesting media data from \(output)")
        renderer.requestMediaDataWhenReady(on: DispatchQueue.global(qos: .default)) {
            while renderer.isReadyForMoreMediaData {
                if let buffer = output.copyNextSampleBuffer() {
                    let desc = CMSampleBufferGetFormatDescription(buffer)
                    if desc != nil {
                        renderer.enqueue(buffer)
                    }
                    
                }
            }
        }
    }
    
    
    private func setRate(_ rate: Double) {
        print("Setting rate: \(rate)")
        
        let current = synchronizer.currentTime()
        synchronizer.setRate(Float(rate), time: current)
        
        print("- status: \(displayLayer.status)")
        print("- error: \(String(describing: displayLayer.error))")
    
    }
    
}


// Controls
extension Player {
    
    public func load(filename: String) {
        if let fileURL = Bundle.main.url(forResource: filename, withExtension: "mp4") {
            load(url: fileURL)
        } else {
            print("File not found")
        }
    }
    
    
    public func play() {
        setRate(1.0)
    }
    
    
    public func pause() {
        setRate(0.0)
    }
    
}
