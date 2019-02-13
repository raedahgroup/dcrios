//
//  DataTableViewCell.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit

struct DataTableViewCellData {
    
    var trans: Transaction
    
    init(trans: Transaction) {
        self.trans = trans
    }
}

class DataTableViewCell : BaseTableViewCell {
    
    @IBOutlet weak var dataImage: UIImageView!
    @IBOutlet weak var dataText: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var dateT: UILabel!
    
    var count = 0
    
    override func awakeFromNib() {}
    
    override class func height() -> CGFloat {
        return 60
    }
    
    override func setData(_ data: Any?) {
        
        if let data = data as? DataTableViewCellData {
            var confirmations: Int32 = 0
            if (data.trans.Height != -1) {
                confirmations = (SingleInstance.shared.wallet?.getBestBlock())! - Int32(data.trans.Height)
                confirmations += 1
            }else if (data.trans.Height == -1) {
                self.status.textColor = UIColor(hex:"#3d659c")
                self.status.text = "Pending"
            } else {
                if (UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") || confirmations > 1) {
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.text = "Confirmed"
                } else {
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = "Pending"
                }
            }
            
            let Date2 = NSDate.init(timeIntervalSince1970: TimeInterval(data.trans.Timestamp) )
            let dateformater = DateFormatter()
            dateformater.locale = Locale(identifier: "en_US_POSIX")
            dateformater.dateFormat = "MMM dd, yyyy h:mm:ss a"
            dateformater.amSymbol = "AM"
            dateformater.pmSymbol = "PM"
            dateformater.string(from: Date2 as Date)
            
            self.dateT.text = dateformater.string(from: Date2 as Date)
            let tnt = Decimal(data.trans.Amount / 100000000.00) as NSDecimalNumber
            
            if (data.trans.Direction == 0) {
                self.dataText.attributedText = getAttributedString(str: "-".appending(tnt.round(8).description), siz: 12.0)
                self.dataImage?.image = UIImage(named: "debit")
            } else if(data.trans.Direction == 1) {
                self.dataText.attributedText = getAttributedString(str: tnt.round(8).description, siz: 12.0)
                self.dataImage?.image = UIImage(named: "credit")
            } else if(data.trans.Direction == 2) {
                self.dataText.attributedText = getAttributedString(str: tnt.round(8).description, siz: 12.0)
                self.dataImage?.image = UIImage(named: "account")
            }
            
            if(data.trans.Type == "vote"){
                self.dataText.text = "Vote"
            }
        }
    }
}
