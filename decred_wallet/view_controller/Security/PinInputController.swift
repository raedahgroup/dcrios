//
//  PinInputController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation

class PinInputController {
    
    var buffer: String = ""
    var max: Int = Int(LONG_LONG_MAX)
    
    init(max:Int){
        self.max = max
    }
    
    func input(digit: Int) -> String {
        if (buffer.count < max) {
            buffer = "\(buffer)\(digit)"
        }
        
        return buffer
    }
    
    func backspace() -> String {
        buffer = String(buffer.dropLast())
        return buffer
    }
    
    func clear() -> String{
        buffer = ""
        return buffer
    }
}
