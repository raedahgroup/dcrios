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
    @IBOutlet weak var accountImg: UIImageView!
    @IBOutlet weak var background1: UIView!
    @IBOutlet weak var background2: UIView!
    
    @IBOutlet weak var syncIndicate: UIImageView!
    var headerIndex: Int = 0
    var arrobool = false
    var spendableColor = UIColor(hex: "#2DD8A3")
    var totalColor = UIColor(hex: "#C4CBD2")
    
    
    var totalBalance: Double = 0.0 {
        willSet {
            DispatchQueue.main.async { [weak self] in
                self?.labelTotalBalance.attributedText = getAttributedString(str: "\(newValue)", siz: 13.0, TexthexColor: self!.totalColor)
            }
        }
    }
    
    @IBAction func expnandOrCollapseAction(_ sender: UIButton) {}
    var spendableBalance: NSDecimalNumber = 0.0 {
        willSet {
            DispatchQueue.main.async {[weak self] in
                if(UserDefaults.standard.bool(forKey: "synced")){
                    let spendableTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "#8997A5")]
                    let spendableTextattr =  NSMutableAttributedString(string: "Spendable ", attributes: spendableTextAttributes)
                    let amount = getAttributedString(str: "\(newValue)", siz: 9.0, TexthexColor: self!.spendableColor)
                    let combination = NSMutableAttributedString()
                    combination.append(spendableTextattr)
                    combination.append(amount)
                self?.labelSpendableBalance.attributedText = combination
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func syncing(status: Bool){
        if(status){
            syncIndicate.loadGif(name: "progress bar-1s-200px")
            let spendableTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "#8997A5")]
            let spendableTextattr =  NSMutableAttributedString(string: "Spendable ", attributes: spendableTextAttributes)
            let AmountText = "-"
            let amountTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: "#2DD8A3")]
            let amountTextattr =  NSMutableAttributedString(string: AmountText, attributes: amountTextAttributes)
            let combination = NSMutableAttributedString()
            combination.append(spendableTextattr)
            combination.append(amountTextattr)
            labelSpendableBalance.attributedText = combination
        }
        else{
            syncIndicate.image = nil
            syncIndicate.isHidden = true
            labelTotalBalance.isHidden = false
        }
    }
    
    func sethidden(status: Bool){
        if (status){
            self.labelTotalBalance.textColor = UIColor(hex: "#C4CBD2")
            self.labelSpendableBalance.textColor = UIColor(hex: "#C4CBD2")
            self.accountImg.alpha = 0.2
            self.arrowDirection.alpha = 0.2
            self.labelTitle.textColor = UIColor(hex: "#C4CBD2")
            self.spendableColor = UIColor(hex: "#C4CBD2")
            totalColor = UIColor(hex: "#C4CBD2")
            self.background2.backgroundColor = UIColor(hex: "#F3F5F6")
            self.background1.backgroundColor = UIColor(hex: "#F3F5F6")
        }
        else{
            self.accountImg.alpha = 1
            self.arrowDirection.alpha = 1
            self.labelSpendableBalance.textColor = UIColor(hex: "#2DD8A3")
            self.labelTitle.textColor = UIColor(hex: "#091440")
            self.spendableColor = UIColor(hex: "#2DD8A3")
            totalColor = UIColor(hex: "#091440")
            self.background1.backgroundColor = UIColor(hex: "#FFFFFF")
            self.background2.backgroundColor = UIColor(hex: "#FFFFFF")
        }
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
