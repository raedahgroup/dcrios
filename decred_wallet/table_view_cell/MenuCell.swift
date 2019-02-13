//
//  BaseTableViewCell.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import Foundation
import UIKit

open class MenuCell : UITableViewCell {
    
    class var identifier: String { return String.className(self) }
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var backView: UIView!
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    open override func awakeFromNib() {}
    
    open func setup() {}
    
    open class func height() -> CGFloat {
        return 60
    }
    
    open func setData(_ data: Any?) {
        
        if let menuText = data as? String {
            self.lblMenu?.text = menuText
            if (menuText == "Overview") {
                self.menuImage?.image = UIImage(named: "overview")
            } else if (menuText == "Account") {
                self.menuImage?.image = UIImage(named: "account")
            } else if (menuText == "Send") {
                self.menuImage?.image = UIImage(named: "send")
            } else if (menuText == "Receive") {
                self.menuImage?.image = UIImage(named: "receive")
            } else if (menuText == "Settings") {
                self.menuImage?.image = UIImage(named: "settings")
            } else if (menuText == "Security") {
                self.imageView?.image = UIImage(named: "security")
            } else if (menuText == "History") {
                self.menuImage?.image = UIImage(named: "history")
            } else if (menuText == "Help") {
                self.menuImage?.image = UIImage(named: "help")
            }
        }
    }
    
    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor(hex: "#FFFFFF")
        } else {
            self.backgroundColor = UIColor(hex: "#F9FAFA")
        }
    }
    
    // ignore the default handling
    override open func setSelected(_ selected: Bool, animated: Bool) {}
}
