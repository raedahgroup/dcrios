//  TransactiontInputDetails.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class TransactiontInputDetails: UITableViewCell {
    
    @IBOutlet weak var viewCotainer: UIView!
    @IBOutlet weak var debitsStack: UIStackView!
    @IBOutlet weak var alcDebitStackHeight: NSLayoutConstraint!
    
    var expandOrCollapse: (() -> Void)?
    var index = 0
    
    func setup(with debits:[Debit]){
        
        alcDebitStackHeight.constant = CGFloat(45 * min(debits.count,3))
        
        for debit in debits {
            self.addSubrow(with: debit, indexs: index)
            if(index == 2){
                return
            }
            index += 1
        }
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewCotainer.isHidden = false
    }
    
    var addressLabel : UIButton?
    private func addSubrow(with debit: Debit , indexs : Int) {
        
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width:self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        self.addressLabel = UIButton(frame: CGRect(x:5.0, y:23.0, width:self.frame.size.width, height: 22.0))
        
        addressLabel!.setTitleColor(#colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1), for: .normal)
        addressLabel!.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        addressLabel?.set(fontSize: 15)
        amountLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        addressLabel?.contentHorizontalAlignment = .left
        subrow.addSubview(amountLabel)
        subrow.addSubview(addressLabel!)
        amountLabel.font = amountLabel.font.withSize(15)
        let combine = NSMutableAttributedString()
        combine.append(getAttributedString(str: "\(debit.dcrAmount)", siz: 12))
        combine.append(NSMutableAttributedString(string: " (\(debit.AccountName ))"))
        amountLabel.attributedText = combine
        
        debitsStack.insertArrangedSubview(subrow, at: indexs)
        debitsStack.addArrangedSubview(subrow)
    }
    
    @objc func buttonClicked(sender : UIButton){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = sender.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: "address copied", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        }
    }
}
