//  SendCompletedViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class SendCompletedViewController: UIViewController {
    
    var transactionHash: String?
    
    @IBOutlet private weak var labelTransactionHash: UILabel!
    @IBOutlet weak var vContent: UIView!
    
    var openDetails: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layer = view.layer
        
        layer.frame = vContent.frame
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 30
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width:0.0, height:40.0);
        labelTransactionHash.text = transactionHash
    }
    
    @IBAction func openAction(_ sender: UIButton) {
        dismiss(animated: false) { [weak self] in
            self?.openDetails?()
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
