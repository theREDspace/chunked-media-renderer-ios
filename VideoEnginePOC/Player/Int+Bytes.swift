//
//  Int+Bytes.swift
//  VideoEnginePOC
//
//  Created by Chris Baltzer on 2020-08-27.
//  Copyright © 2020 Redspace. All rights reserved.
//

import Foundation


extension UInt32 {

    init?(bigEndian bytes: [UInt8]) {
        if bytes.count != 4 {
            return nil
        }

        let tryInt = bytes.withUnsafeBytes {
            $0.load(as: UInt32.self).bigEndian
        }

        self.init(tryInt)
    }


    init?(bigEndian data: Data) {
        let bytes = data[0..<4].map{ UInt8($0) }
        self.init(bigEndian: bytes)
    }

}


extension UInt64 {

    init?(bigEndian bytes: [UInt8]) {
        if bytes.count != 8 {
            return nil
        }

        let tryInt = bytes.withUnsafeBytes {
            $0.load(as: UInt64.self).bigEndian
        }

        self.init(tryInt)
    }


    init?(bigEndian data: Data) {
        let bytes = data[0..<8].map{ UInt8($0) }
        self.init(bigEndian: bytes)
    }

}
