//
//  RecoveryWalletSeedWordsCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class RecoveryWalletSeedWordsCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var lbWordNum: UILabel!
    @IBOutlet weak var tfSeedWord: DropDownSearchField!
    
    var seed:[String]?
    var wordNum:Int = 0
    
    var onTextChanged:(()->Void)?{
        set{
            tfSeedWord.onTextChanged = newValue
        }
        get{
            return tfSeedWord.onTextChanged
        }
    }
    
    var onPickUpSeed:((Int, String)->Void)?{
        set{
            tfSeedWord.onSelect = newValue
        }
        get{
            return tfSeedWord.onSelect
        }
    }
    
    func setup(wordNum:Int, word: String?, seed:[String], placeholder: UIView){
        self.seed = seed
        self.wordNum = wordNum
        
        lbWordNum.text = "Word #\(wordNum + 1)"
        
        tfSeedWord.dropDownListPlaceholder = placeholder
        tfSeedWord.text = word ?? ""
        tfSeedWord.autocorrectionType = .no
        tfSeedWord.itemsToSearch = seed
        tfSeedWord.vertPosition = self.frame.origin.y
        tfSeedWord.setupDropdownTable()
        tfSeedWord.onTextChanged = onTextChanged
    }
    
    func hideDropDown(){
        tfSeedWord.hideDropDown()
        tfSeedWord.clean()
    }
    
    func updatePlaceholder(vertPosition: Int){
        tfSeedWord.updatePlaceholder(position:vertPosition)
    }
}
