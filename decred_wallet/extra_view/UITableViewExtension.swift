//
//  UITableViewExtension.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import Foundation
import UIKit

public extension UITableView {
    
    func registerCellClass(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        self.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func registerCellNib(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewClass(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        self.register(viewClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterViewNib(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    /// Hides extra rows created by UIKit with no data to display.
    @discardableResult func hideEmptyAndExtraRows() -> UITableView {
        tableFooterView = UIView()
        return self
    }
    
    @discardableResult func autoResizeCell(estimatedHeight _estimatedHeight: CGFloat = 100.0) -> UITableView {
        rowHeight = UITableView.automaticDimension
        estimatedRowHeight = _estimatedHeight
        return self
    }
}

// MARK: - Properties
public extension Bool {
    
    /// SwifterSwift: Return 1 if true, or 0 if false.
    var int: Int {
        return self ? 1 : 0
    }
    
    /// SwifterSwift: Return "true" if true, or "false" if false.
    var string: String {
        return description
    }
    
    /// SwifterSwift: Return inversed value of bool.
    var toggled: Bool {
        return !self
    }
}


// MARK: - Methods
public extension Bool {
    
    /// SwifterSwift: Toggle value for bool.
    ///
    /// - Returns: inversed value of bool.
    @discardableResult mutating func toggles() -> Bool {
        self = !self
        return self
    }
}
