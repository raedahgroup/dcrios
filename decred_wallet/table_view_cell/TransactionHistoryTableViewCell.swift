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
            dateformater.dateFormat = "MMM dd, yyyy hh:mma"
            dateformater.amSymbol = "am"
            dateformater.pmSymbol = "pm"
            dateformater.string(from: Date2 as Date)
            
            self.txtDate.text = dateformater.string(from: Date2 as Date)
            
            let tnt = Decimal(data.trans.Amount / 100000000.00) as NSDecimalNumber
            let requireConfirmation = UserDefaults.standard.bool(forKey: "pref_spend_fund_switch") ? 0 : 2
            if (data.trans.Type.lowercased() == "regular".lowercased()) {
                if (data.trans.Direction == 0) {
                    self.txtAmount.attributedText = getAttributedString(str:"-".appending(tnt.round(8).description), siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount)
                    self.trImage?.image = UIImage(named: "debit")
                }
                else if (data.trans.Direction == 1) {
                    self.txtAmount.attributedText = getAttributedString(str: tnt.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount)
                    self.trImage?.image = UIImage(named: "credit")
                    
                }
                else if (data.trans.Direction == 2) {
                    self.txtAmount.attributedText = getAttributedString(str: tnt.round(8).description, siz: 13.0, TexthexColor: GlobalConstants.Colors.TextAmount)
                    self.trImage?.image = UIImage(named: "account")
                }
            }
            else if(data.trans.Type.lowercased() == "vote".lowercased()){
                self.txtAmount.text = "Vote"
                self.trImage?.image = UIImage(named: "vote")
            }
            else if (data.trans.Type.lowercased() == "Ticket Purchase".lowercased()) {
                self.txtAmount.text = "Ticket"
                self.trImage?.image = UIImage(named: "immature")
                if (confirm2 < requireConfirmation){
                    self.txtTrStatus.textColor = UIColor(hex:"#3d659c")
                    self.txtTrStatus.text = "Pending"
                }
                else if (confirm2 > 16){
                    let stausText = "Confirmed / Live"
                    let range = (stausText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: stausText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                    self.txtTrStatus.textColor = UIColor(hex:"#2DD8A3")
                    self.txtTrStatus.attributedText = attributedString
                }
                else{
                    let stausText = "Confirmed / Immature"
                    let range = (stausText as NSString).range(of: "/")
                    let attributedString = NSMutableAttributedString(string: stausText)
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black , range: range)
                     self.trImage?.image = UIImage(named: "live")
                    self.txtTrStatus.textColor = UIColor.orange
                    self.txtTrStatus.attributedText = attributedString
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
