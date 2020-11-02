//
//  MP4.swift
//  VideoEnginePOC
//
//  Created by Chris Baltzer on 2020-08-26.
//  Copyright © 2020 Redspace. All rights reserved.
//

import Foundation


class MP4 {



}

class Box {

    enum BoxType: String {
        case ftyp
        case moov
        case moof
        case mdat
        case unknown
    }


    let size: Int
    let fullBox: Bool
    let type: BoxType

    let raw: Data

    var data: Data {
        let startIndex = fullBox ? 8 : 16
        return raw[startIndex..<size]
    }

    init(from data: Data) {

        // Find the box size
        var largeBox = false
        let smallSize = UInt32(bigEndian: data[0...3]) ?? 0
        switch smallSize {
        case 0:
            self.size = data.count
        case 1:
            let largeSize = UInt64(bigEndian: data[8...15]) ?? 0
            largeBox = true
            self.size = Int(largeSize)
        default:
            self.size = Int(smallSize)
        }

        self.fullBox = largeBox

        if let typeString = String(data: data[4...7], encoding: .ascii) {
            if let type = BoxType(rawValue: typeString) {
                self.type = type
            } else {
                print("[Box] Found unknown type string: \(typeString)")
                self.type = .unknown
            }
        } else {
            print("[Box] Could not read type string")
            self.type = .unknown
        }

        self.raw = data[0..<size]
    }
}


extension Box: CustomDebugStringConvertible {
    var debugDescription: String {
        return "[Box] \n |- [\(type)] \n |- [\(size) bytes] \n |- [\(data) data]"
    }
}
