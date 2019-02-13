//
//  ConfirmSeedViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class ConfirmSeedViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var lbWordNum: UILabel!
    @IBOutlet weak var tfSeedWord: UITextField!
    
    var seed:[String]?
    var wordNum:Int = 0
    
    var onNext:((Int)->Void)?
    var onEditingText:((Int, UITextField)->Void)?
    var onFoundSeedWord:(([String])->Void)?
    
    func setup(wordNum:Int, word: String?, seed:[String]){
        self.seed = seed
        self.wordNum = wordNum
        
        lbWordNum.text = "Word #\(wordNum + 1)"
        
        tfSeedWord.delegate = self
        tfSeedWord.text = word ?? ""
        tfSeedWord.autocorrectionType = .no
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onEditingText?(wordNum, textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let suggestions = seed?.filter({
            return ($0.lowercased().hasPrefix((textField.text! + string).lowercased()) && (textField.text?.count)! >= 1)
        })
        onFoundSeedWord?(suggestions!)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isMatchesAnyWordInList(entereText: textField.text) {
            onNext?(wordNum)
        }
        return true
    }
    
    private func isMatchesAnyWordInList(entereText:String?) -> Bool{
        return seed?.filter({
            return ($0.lowercased().hasPrefix(entereText!.lowercased()) && (entereText?.count)! >= 1)
        }).count ?? 0 > 0
    }
}
