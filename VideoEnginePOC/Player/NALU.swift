//
//  NALU.swift
//  VideoEnginePOC
//
//  Created by Chris Baltzer on 2020-08-06.
//  Copyright © 2020 Redspace. All rights reserved.
//

import Foundation


// Annex B
class NALU {

    enum NALType: Int, RawRepresentable {
        case PFrame = 1
        case IFrame = 5
        case SPS = 7
        case PPS = 8
        case unsupported = -1
    }


    let nalType: NALType
    let length: Int

    init(from data: Data) {

        var nalStart = 0
        var nalEnd = data.count // read to end of file if no second NAL start is found

        // Look for a 4 byte start code
        var nalFound = false

        //var nalData = Data(data) // Start with a full copy of the data
        print("[NALU] Starting NAL search..")
        for i in 0...data.count-4 {
            if data[i] == 0x00 && data[i+1] == 0x00 && data[i+2] == 0x00 && data[i+3] == 0x01 {

                if !nalFound {
                    print("\t - [NALU] Found NAL start code at \(i)")
                    nalStart = i
                    nalFound = true
                } else {
                    print("\t - [NALU] Found second NAL start code at \(i), marking NAL end")
                    nalEnd = i - 1
                    break
                }
            }
        }


        let nalRange = Range(uncheckedBounds: (lower: nalStart, upper: nalEnd))
        let nalData = data.subdata(in: nalRange)

        print("[NALU] Found NAL at \(nalStart) - \(nalEnd)")
        print("[NALU] Raw NAL data: \n---\n\t\(nalData as NSData)\n---")

        length = nalData.count
        if length < 5 {
            nalType = .unsupported
            print("[NALU] NAL too short, marking as unsupported and skipping")
            return
        }

        let typeValue = nalData[4] & 0x1F
        print("[NALU] Attempting to translate raw value to NAL type: \(typeValue)")
        nalType = NALType(rawValue: Int(typeValue)) ?? .unsupported
        print("[NALU] Found NAL type code: \(nalType)")

    }

}
