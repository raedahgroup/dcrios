//  AccountsHeaderView.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class AccountsHeaderView: UIView {
    
    @IBOutlet private var labelTitle: UILabel!
    @IBOutlet private var labelTotalBalance: UILabel!
    @IBOutlet private var labelSpendableBalance: UILabel!
    @IBOutlet var expandOrCollapseDetailsButton: UIButton!
    @IBOutlet weak var arrowDirection: UIButton!
    
    var headerIndex: Int = 0
    var arrobool = false
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.labelTotalBalance.attributedText = getAttributedString(str: "\(newValue)", siz: 13.0)
            }
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {}
    
    var spendableBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async {
                self.labelSpendableBalance.text = "\(newValue)".appending("DCR")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var title: String? {
        get {
            return labelTitle.text
        }
        set {
            DispatchQueue.main.async {
                self.labelTitle.text = newValue
            }
        }
    }
}
