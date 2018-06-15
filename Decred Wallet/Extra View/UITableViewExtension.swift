//
//  UITableViewExtension.swift
//  Decred Wallet
//  Copyright © 2018 The Decred developers.
//  see LICENSE for details.

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
    
    // Register a XIB file with UITableView. XIB file name is used as reuse identifier so keep in mind to use the file name as reuse identifier.
    ///
    /// - Parameter nibName: Name of the XIB file
    @discardableResult public func registerNib(_ nibName: String) -> UITableView {
        let cellNib = UINib(nibName: nibName, bundle: nil)
        register(cellNib, forCellReuseIdentifier: nibName)
        return self
    }

    /// Hides extra rows created by UIKit with no data to display.
    @discardableResult public func hideEmptyAndExtraRows() -> UITableView {
        tableFooterView = UIView()
        return self
    }
    
    @discardableResult public func autoResizeCell(estimatedHeight _estimatedHeight: CGFloat = 100.0) -> UITableView {
        rowHeight = UITableViewAutomaticDimension
        estimatedRowHeight = _estimatedHeight
        return self
    }
}
