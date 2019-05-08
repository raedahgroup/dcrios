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
    
    var presentingController: TransactionFullDetailsViewController!
    
    func setup(with debits:[Debit], decodedInputs: [DecodedInput], presentingController: TransactionFullDetailsViewController){
        debitsStack.subviews.forEach({ $0.removeFromSuperview() }) // this stack view comes with previous items when this function is called again
        self.presentingController = presentingController
        
        var walletInputIndices = [Int]()
        
        for (_, debit) in debits.enumerated() {
            
            walletInputIndices.append(Int(debit.Index))
        
            let decodedInput = decodedInputs[Int(debit.Index)]
        
            var hash = decodedInput.PreviousTransactionHash
            if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
                hash = "Stakebase: 0000"
            }
            hash = "\(hash):\(decodedInput.PreviousTransactionIndex)"
            
            let amount = "\(debit.dcrAmount.round(8))"
            let title = " (\(debit.AccountName))"
            
            self.addSubrow(with: amount, title: title, subTitle: hash)
        }
        
        for (i, decodedInput) in decodedInputs.enumerated() {
            
            if walletInputIndices.contains(i) {
                continue
            }
            
            let amount = "\(decodedInput.dcrAmount.round(8))"
            let title = " (external)"
            
            var hash = decodedInput.PreviousTransactionHash
            if hash == "0000000000000000000000000000000000000000000000000000000000000000" {
                hash = "Stakebase: 0000"
            }
            hash = "\(hash):\(decodedInput.PreviousTransactionIndex)"
            
            self.addSubrow(with: amount, title: title, subTitle: hash)
        }
        
        // each debit row has an height of 45
        alcDebitStackHeight.constant = CGFloat(45 * debitsStack.arrangedSubviews.count)
    }
    
    @IBAction func hideOrExpandAction(_ sender: UIButton) {
        self.viewCotainer.isHidden = false
    }
    
    private func addSubrow(with amount: String, title: String, subTitle: String) {
        
        let subrow = UIView(frame: CGRect(x:0.0, y:0.0, width: self.frame.size.width, height:45.0))
        let amountLabel = UILabel(frame: CGRect(x:5.0, y:1.0, width: self.frame.size.width, height: 22.0))
        let subTitleLabel = UIButton(frame: CGRect(x: 5.0, y: 23, width: self.frame.size.width, height: 22.0))
        
        subTitleLabel.setTitleColor(#colorLiteral(red: 0.2470588235, green: 0.4941176471, blue: 0.8901960784, alpha: 1), for: .normal)
        subTitleLabel.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        subTitleLabel.set(fontSize: 15, name: "SourceSansPro-Regular")
        amountLabel.textColor = #colorLiteral(red: 0.03529411765, green: 0.07843137255, blue: 0.2509803922, alpha: 1)
        amountLabel.font = UIFont(name: "Inconsolata-Regular", size: 16)
        subTitleLabel.contentHorizontalAlignment = .left
        subrow.addSubview(amountLabel)
        subrow.addSubview(subTitleLabel)
        amountLabel.font = amountLabel.font.withSize(16)
        let combine = NSMutableAttributedString()
        combine.append(getAttributedString(str: amount, siz: 13, TexthexColor: GlobalConstants.Colors.TextAmount))
        combine.append(NSMutableAttributedString(string: title))
        amountLabel.attributedText = combine
        subTitleLabel.setTitle(subTitle, for: .normal)
        
        debitsStack.addArrangedSubview(subrow)
    }
    
    @objc func buttonClicked(sender : UIButton){
        DispatchQueue.main.async {
            //Copy a string to the pasteboard.
            UIPasteboard.general.string = sender.titleLabel?.text
            //Alert
            let alertController = UIAlertController(title: "", message: "Previous outpoint copied!", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.presentingController.present(alertController, animated: true, completion: nil)
        }
    }
}
