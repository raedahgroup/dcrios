//
//  SingleInstance.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit
import Dcrlibwallet
public class SingleInstance{
    var wallet: DcrlibwalletLibWallet?
    public class var shared: SingleInstance {
        struct Static {
            static let instance: SingleInstance = SingleInstance()
        }
        return Static.instance
    }
}
