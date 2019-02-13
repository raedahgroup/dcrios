//
//  SeedCheckActiveCellView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class SeedCheckActiveCellView: UIView {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var btnSeed1: ContouredButton!
    @IBOutlet weak var btnSeed2: ContouredButton!
    @IBOutlet weak var btnSeed3: ContouredButton!
    
    var onSeedPick:((Int, String)->Void)?
    
    func setup(seedWords:[String], onSeedPick:@escaping ((Int, String)->Void)){
        self.onSeedPick = onSeedPick
    }
}
