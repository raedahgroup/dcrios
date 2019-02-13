//
//  TransactionHistoryTableViewCell.swift
//  Decred Wallet
//

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

struct TransactionTableViewCellData {
    
    var trans: Transaction
    
    init(data: Transaction) {
        self.trans = data
    }
}

class TransactionHistoryTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var trImage: UIImageView!
    @IBOutlet weak var txtAmount: UILabel!
    @IBOutlet weak var txtDate: UILabel!
    @IBOutlet weak var txtTrStatus: UILabel!
    
    override func awakeFromNib() {}
    
    override class func height() -> CGFloat {
        return 60
    }
    
    override func setData(_ data: Any?) {
        
        if let data = data as? TransactionTableViewCellData {
            
            let confirmation =  SingleInstance.shared.wallet?.getBestBlock()
            let confirm2 = (confirmation)! - Int32(data.trans.Height)
            
            if (confirm2 == -1) {
                self.txtTrStatus.textColor = UIColor(hex:"#3d659c")
                self.txtTrStatus.text = "Pending"
            } else {
                if(UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirm2 > 1) {
                    self.txtTrStatus.textColor = UIColor(hex:"#2DD8A3")
                    self.txtTrStatus.text = "Confirmed"
                } else {
                    self.txtTrStatus.textColor = UIColor(hex:"#3d659c")
                    self.txtTrStatus.text = "Pending"
                }
            }
            
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(data.trans.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd, yyyy h:mm:ss a"
            dateformater.amSymbol = "AM"
            dateformater.pmSymbol = "PM"
            dateformater.string(from: Date2 as Date)
            
            self.txtDate.text = dateformater.string(from: Date2 as Date)
            
            let tnt = Decimal(data.trans.Amount / 100000000.00) as NSDecimalNumber
            
            if (data.trans.Direction == 0) {
                self.txtAmount.attributedText = getAttributedString(str: "-".appending(tnt.round(8).description), siz: 12.0)
                self.trImage?.image = UIImage(named: "debit")
            } else if (data.trans.Direction == 1) {
                self.txtAmount.attributedText = getAttributedString(str: tnt.round(8).description, siz: 12.0)
                self.trImage?.image = UIImage(named: "credit")
            } else if (data.trans.Direction == 2) {
                self.txtAmount.attributedText = getAttributedString(str: tnt.round(8).description, siz: 12.0)
                self.trImage?.image = UIImage(named: "account")
            }
            
            if (data.trans.Type == "vote") {
                self.txtAmount.text = "Vote"
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
