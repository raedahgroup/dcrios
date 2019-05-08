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
            
            let bestBlock =  SingleInstance.shared.wallet?.getBestBlock()
            var confirmations = 0
            if(data.trans.Height != -1){
                confirmations = Int(bestBlock!) - data.trans.Height
                confirmations += 1
            }
            
            let spendUnconfirmedFunds = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch")
            
            if (confirmations == -1) {
                self.status.textColor = UIColor(hex:"#3d659c")
                self.status.text = "Pending"
            } else {
                if (spendUnconfirmedFunds || confirmations > 1) {
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
            dateformater.dateFormat = "MMM dd, yyyy hh:mma"
            dateformater.amSymbol = "am"
            dateformater.pmSymbol = "pm"
            dateformater.string(from: Date2 as Date)
            
            self.dateT.text = dateformater.string(from: Date2 as Date)
            let amount = Decimal(data.trans.Amount / 100000000.00) as NSDecimalNumber
            let requireConfirmation = spendUnconfirmedFunds ? 0 : 2
            
            if (data.trans.Type.lowercased() == "regular") {
                if (data.trans.Direction == 0) {
                    let attributedString = NSMutableAttributedString(string: "-")
                    attributedString.append(getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "debit")
                } else if(data.trans.Direction == 1) {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "credit")
                } else if(data.trans.Direction == 2) {
                    let attributedString = NSMutableAttributedString(string: " ")
                    attributedString.append(getAttributedString(str: amount.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount))
                    self.dataText.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "account")
                }
            } else if(data.trans.Type.lowercased() == "vote") {
                self.dataText.text = " Vote"
                self.dataImage?.image = UIImage(named: "vote")
            } else if (data.trans.Type.lowercased() == "ticket_purchase") {
                self.dataText.text = " Ticket"
                self.dataImage?.image = UIImage(named: "immature")
                let ticketMaturity = Int(infoForKey("TicketMaturity")!)!
                if (confirmations < requireConfirmation){
                    self.status.textColor = UIColor(hex:"#3d659c")
                    self.status.text = "Pending"
                } else if (confirmations > ticketMaturity) {
                    let statusText = "Confirmed / Live"
                    let range = (statusText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                    self.status.textColor = UIColor(hex:"#2DD8A3")
                    self.status.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "live")
                } else {
                    let statusText = "Confirmed / Immature"
                    let range = (statusText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)

                    self.status.textColor = UIColor.orange
                    self.status.attributedText = attributedString
                    self.dataImage?.image = UIImage(named: "immature")
                }
            }
        }
    }
}
