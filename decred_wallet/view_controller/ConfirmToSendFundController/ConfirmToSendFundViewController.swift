//  ConfirmToSendFundViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class ConfirmToSendFundViewController: UIViewController {
    
    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet weak var lbMinorDigits: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var vContent: UIView!
    
    var amount: Double = 0.0 {
        willSet (newValue) {
            labelTitle?.text = major(amount: newValue)
            lbMinorDigits?.text = minor(amount: newValue)
        }
    }
    
    var confirm: ((String)->Void)?
    var cancel: (()->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitle?.text = major(amount: amount)
        lbMinorDigits.text = minor(amount: amount)
        let layer = view.layer
        layer.frame = vContent.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func major(amount:Double) -> String {
        let major = String(format: "%.2f", amount)
        return major
    }
    
    private func minor(amount:Double) -> String{
        let sAmount = "\(amount)"
        let majorCount = major(amount: amount).count
        if (sAmount.count <= majorCount) {
            return "000000"
        }else{
            return sAmount.substring(majorCount)
        }
    }
    
    @IBAction private func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        self.cancel?()
    }
    
    @IBAction private func confirmAction(_ sender: UIButton) {
        self.confirm?(tfPassword.text ?? "")
        dismiss(animated: true, completion: nil)
    }
}
