//
//  SeedConfirmTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.


import UIKit

class SeedConfirmTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbWordTitle: UILabel!
    @IBOutlet weak var btnSeed1: ContouredButton!
    @IBOutlet weak var btnSeed2: ContouredButton!
    @IBOutlet weak var btnSeed3: ContouredButton!
    
    var seedWordNumber:Int = 0
    var onPick:((Int, String)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(num:Int, seedWords:[String], selected: Int){
        btnSeed1.setTitle(seedWords[0], for: .normal)
        btnSeed2.setTitle(seedWords[1], for: .normal)
        btnSeed3.setTitle(seedWords[2], for: .normal)
        
        let buttons = [btnSeed1, btnSeed2, btnSeed3]
        let _ = buttons.map({$0?.isSelected = false})
        
        if (selected >= 0) {
            buttons[selected]?.isSelected = true
        }
        seedWordNumber = num
        lbWordTitle.text = "Word #\(num + 1)"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.btnSeed1.isEnabled = selected
        self.btnSeed2.isEnabled = selected
        self.btnSeed3.isEnabled = selected
    }
    
    private func disableAllButtons(){
        btnSeed1.isSelected = false
        btnSeed2.isSelected = false
        btnSeed3.isSelected = false
    }
    
    @IBAction func onSelectSeedWord(_ sender: UIButton) {
        disableAllButtons()
        sender.isSelected = true
        onPick?(sender.tag - 1, sender.titleLabel?.text ?? "")
    }
}
