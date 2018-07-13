//  UITableView_Theme.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers. All rights reserved.

import UIKit

class UITableView_Theme: UITableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppDelegate.shared.theme.backgroundColor
        subscribeToThemeUpdates()
    }

    override func changeSkin() {
        super.changeSkin()
        reloadData()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
