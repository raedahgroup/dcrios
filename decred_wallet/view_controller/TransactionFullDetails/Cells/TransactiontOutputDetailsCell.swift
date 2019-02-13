//  TransactiontOutputDetailsTableViewCell.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class TransactiontOutputDetailsCell: UITableViewCell {
    
    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet weak var creditsStack: UIStackView!
    @IBOutlet weak var alcCreditStackHeight: NSLayoutConstraint!
    
    var index = 0
    
    var expandOrCollapse: (() -> Void)?
    
    func setup(with credits:[Credit]){
        
        alcCreditStackHeight.constant = CGFloat(45 * min(credits.count, 3))
        
        for credit in credits{
            self.addSubrow(with: credit, indexs: index)
            print(index)
            if(index == 2){
                return
            }
            index += 1
        }
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewContainer.isHidden = false
    }
    
    var addressLabel : UIButton?
    private func addSubrow(with credit: Credit, indexs: Int){
        
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let addressLabel = UIButton(frame: CGRect(x:5.0, y:23.0, width:self.frame.size.width, height: 22.0))
        let tmp = SingleInstance.shared.wallet
        let accName = tmp?.accountName(Int32(credit.Account))
        
        addressLabel.setTitleColor(#colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1), for: .normal)
        amountLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        addressLabel.set(fontSize: 15)
        addressLabel.contentHorizontalAlignment = .left
        subrow.addSubview(amountLabel)
        subrow.addSubview(addressLabel)
        amountLabel.font = amountLabel.font.withSize(15)
        
        let combine = NSMutableAttributedString()
        combine.append(getAttributedString(str: "\(credit.dcrAmount)", siz: 12))
        combine.append(NSMutableAttributedString(string: " (\(accName ?? "external"))"))
        
        amountLabel.attributedText = combine
        addressLabel.setTitle(credit.Address, for: .normal)
        self.creditsStack.insertArrangedSubview(subrow, at: indexs)
    }
    
    func buttonClicked(sender : UIButton){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = self.addressLabel!.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: "address copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        }
    }
}
