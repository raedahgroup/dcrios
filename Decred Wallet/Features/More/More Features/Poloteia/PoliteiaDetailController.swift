//
//  PoliteiaDetailController.swift
//  Decred Wallet
//
//  Created by JustinDo on 8/27/20.
//  Copyright © 2020 Decred. All rights reserved.
//

import Foundation
import UIKit

class PoliteiaDetailController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: PaddedLabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    @IBOutlet weak var countCommentLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var yesPercentLabel: UILabel!
    @IBOutlet weak var noPercentLabel: UILabel!
    @IBOutlet weak var percentView: PlainHorizontalProgressBar!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    var politeia: Politeia?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.displayData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.appColors.darkBlue
        
        let icon = self.navigationController?.modalPresentationStyle == .fullScreen ?  UIImage(named: "ic_close") : UIImage(named: "left-arrow")
        let closeButton = UIBarButtonItem(image: icon,
                                          style: .done,
                                          target: self,
                                          action: #selector(self.dismissView))
        
        let barButtonTitle = UIBarButtonItem(title: LocalizedStrings.politeiaDetail, style: .plain, target: self, action: nil)
        barButtonTitle.tintColor = UIColor.appColors.darkBlue
        
        self.navigationItem.leftBarButtonItems =  [closeButton, barButtonTitle]
    }
    
    func setup() {
        self.statusLabel.layer.cornerRadius = 5
        self.statusLabel.clipsToBounds = true
        let bottomHeight = (self.tabBarController?.tabBar.frame.height ?? 0) + 10
        self.contentTextView.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: bottomHeight, right: 16)
    }
    
    func displayData() {
        guard let politeia = self.politeia else {return}
        self.titleLabel.text = politeia.name
        self.nameLabel.text = politeia.username
        let publishAge = Int64(Date().timeIntervalSince1970) - politeia.timestamp
        let publishAgeAsTimeAgo = Utils.timeAgo(timeInterval: publishAge)
        self.sinceLabel.text = String(format: publishAgeAsTimeAgo)
        self.countCommentLabel.text = String(format: LocalizedStrings.commentCount, politeia.numcomments)
        self.versionLabel.text = String(format: LocalizedStrings.politeiaVersion, politeia.version)
        if let voteStatus = politeia.votestatus {
            self.statusLabel.text = voteStatus.status.description
            self.statusLabel.backgroundColor = Utils.politeiaColorBGStatus(voteStatus.status)
            self.percentView.setProgress(Float(voteStatus.yesPercent.round(decimals: 2)), animated: false)
            self.percentLabel.text = "\(voteStatus.yesPercent.round(decimals: 2))%"
            self.percentLabel.superview?.bringSubviewToFront(self.percentLabel)
            
            if let voteResult = voteStatus.optionsresult, voteResult.count > 0 {
                self.yesPercentLabel.text = "Yes: \(voteResult[1].votesreceived ?? 0) (\(voteStatus.yesPercent.round(decimals: 2))%)"
                self.noPercentLabel.text = "No: \(voteResult[0].votesreceived ?? 0) (\((100 - voteStatus.yesPercent).round(decimals: 2))%)"
            } else {
                self.yesPercentLabel.text = "Yes: 0 (0%)"
                self.noPercentLabel.text = "No: 0 (0%)"
            }
        }
        if let files = self.politeia?.files, files.count > 0 {
            if let file = files.first(where: {$0.name == "index.md"}) {
                let dataContent = Data(base64Encoded: file.payload)!
                let content = String(data: dataContent, encoding: .utf8)
                self.contentTextView.text = content
            }
        }
    }
}
