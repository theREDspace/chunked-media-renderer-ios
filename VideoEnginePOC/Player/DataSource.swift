//
//  DataSource.swift
//  VideoEnginePOC
//
//  Created by Chris Baltzer on 2020-07-31.
//  Copyright © 2020 Redspace. All rights reserved.
//

import Foundation
import CoreMedia


public protocol DataSource {

    init(url: URL)
    func load()
    func nextSampleBuffer() -> CMSampleBuffer?

}


public class FileDataSource: DataSource {


    var file: Data

    // Unused for now, future memory/scanning optimization
    var currentOffset: Int = 0
    var currentData: Data = Data()


    var moov: Box?


    var buffers: [CMSampleBuffer] = []



    public required init(url: URL) {
        file = Data()
        do {
            file = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])
        } catch {
            print("[FileDataSource] Could not load file")
        }
    }


    public func load() {
        readNextByteRange()
    }


    private func readNextByteRange() {
        print("[FileDataSource] Loaded \(file.count) bytes")
        currentData = file
        scanBoxes()
    }


    private func scanBoxes() {
        repeat {
            let box = Box(from: currentData)
            print(box)

            if box.type == .moov {
                moov = box
            }

            if currentData.count > box.size {
                currentData = currentData.advanced(by: box.size)
            } else {
                break
            }
        } while currentData.count > 0
    }


    public func nextSampleBuffer() -> CMSampleBuffer? {

        print("[FileDataSource] Creating sample buffer")

        if let moov = moov {
            print("[FileDataSource] moov: \(moov.data)")

            if let spsNAL = findNAL(data: moov.data, type: .SPS) {
                print("SPS NAL: \(spsNAL.nalType) length \(spsNAL.length)")
            }

            //if let ppsNAL = findNAL(type: .PPS) {
            //    print("PPS NAL: \(ppsNAL.nalType) length \(ppsNAL.length)")
            //}
        }


        return nil
    }


    private func findNAL(data: Data, type: NALU.NALType) -> NALU? {

        var dataCopy = data

        repeat {
            let nal = NALU(from: dataCopy)

            if nal.nalType == type {
                return nal
            }

            dataCopy = dataCopy.advanced(by: nal.length)
        } while dataCopy.count > 3

        print("Didn't find")

        return nil
    }

}
