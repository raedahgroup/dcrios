//  AccountsData.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

struct AccountsData {
    let color: UIColor?
    let spendableBalance: Double
    let title: String
    let totalBalance: Double
    var isExpanded: Bool = false
    
    init(entity: AccountsEntity, color: UIColor?) {
        self.color = color
        self.spendableBalance = Double((entity.Balance?.dcrSpendable)!)
        self.totalBalance = Double((entity.Balance?.dcrTotal)!)
        self.title = entity.Name
        self.isExpanded = false
    }
}

struct TransactionDetails {
    let title: String
    let value: NSAttributedString
    let textColor: UIColor?
}
