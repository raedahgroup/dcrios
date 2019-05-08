//
//  DropMenuButton.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

typealias CallBack = ((Int, String) -> Void) // callback function
typealias TapListener = ()->()

class DropMenuButton: UIButton, UITableViewDelegate, UITableViewDataSource
{
    var items = [String]()
    var table = UITableView()
    var act: CallBack?
    var listener: TapListener?
    
    var superSuperView = UIView()
    var containerView = UIView()
    
    @objc func showItems()
    {
        listener?()
        fixLayout()
        
        if (containerView.alpha) == 0
        {
            self.alpha = 0
            layer.zPosition = 1
            containerView.alpha = 1
        }
        else
        {
            self.alpha = 1
            containerView.alpha = 0
            layer.zPosition = 0
        }
    }
    
    func initMenu(_ items: [String], actions: CallBack?)
    {
        self.items = items
        act = actions
        
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
        }
        // backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        if let vc = resp as? UIViewController
        {
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell
        {
            superSuperView = vc
        }
        
        table = UITableView()
        
        table.rowHeight = frame.height
        table.delegate = self
        table.dataSource = self
        table.isUserInteractionEnabled = true
        table.bounces = false
        containerView.alpha = 0
        table.separatorColor = UIColor.clear
        
        containerView.addSubview(table)
        superSuperView.addSubview(containerView)
        
        containerView.clipsToBounds = false
        containerView.layer.shadowOffset = CGSize(width: -2, height: 5)
        containerView.layer.shadowRadius = 6
        containerView.layer.shadowOpacity = 0.8
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        
        addTarget(self, action: #selector(DropMenuButton.showItems), for: .touchUpInside)
    }
    
    func initMenu(_ items: [String])
    {
        self.items = items
        
        var resp = self as UIResponder
        
        while !(resp.isKind(of: UIViewController.self) || (resp.isKind(of: UITableViewCell.self))) && resp.next != nil
        {
            resp = resp.next!
        }
        
        if let vc = resp as? UIViewController
        {
            superSuperView = vc.view
        }
        else if let vc = resp as? UITableViewCell
        {
            superSuperView = vc
        }
        
        table = UITableView()
        table.rowHeight = frame.height
        table.delegate = self
        table.dataSource = self
        table.isUserInteractionEnabled = true
        containerView.alpha = 0
        table.separatorColor = UIColor.clear
        containerView.addSubview(table)
        superSuperView.addSubview(containerView)
        
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.lightGray.cgColor
        containerView.backgroundColor = UIColor.red
        containerView.clipsToBounds = false
        containerView.layer.shadowOffset = CGSize(width: -5, height: 5)
        containerView.layer.shadowRadius = 1
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        
        addTarget(self, action: #selector(DropMenuButton.showItems), for: .touchUpInside)
    }
    
    func fixLayout()
    {
        let auxPoint2 = superSuperView.convert(frame.origin, from: superview)
        
        var tableFrameHeight = CGFloat()
        
        tableFrameHeight = frame.height * CGFloat(items.count)
        
        containerView.frame = CGRect(x: auxPoint2.x, y: auxPoint2.y, width: 300, height: tableFrameHeight)
        table.frame = CGRect(x: 0, y: 0, width: frame.width, height: tableFrameHeight)
        table.rowHeight = frame.height
        table.separatorColor = UIColor.clear
        
        table.reloadData()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        setNeedsDisplay()
        fixLayout()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        setTitle(items[(indexPath as NSIndexPath).row], for: UIControl.State())
        setTitle(items[(indexPath as NSIndexPath).row], for: UIControl.State.highlighted)
        setTitle(items[(indexPath as NSIndexPath).row], for: UIControl.State.selected)
        
        act?(indexPath.row, items[indexPath.row])
        
       // let temp = items.remove(at: indexPath.row)
        //items.insert(temp, at: 0)
        
        showItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let itemLabel = UILabel(frame: CGRect(x: 10, y: 0, width: frame.width - 10, height: frame.height))
        itemLabel.textAlignment = NSTextAlignment.left
        itemLabel.text = items[(indexPath as NSIndexPath).row]
        itemLabel.font = UIFont(name: "SourceSansPro-Regular", size: 16)
        itemLabel.textColor = UIColor.black
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.lightGray
        
        let cell = UITableViewCell(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        cell.backgroundColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        cell.separatorInset = UIEdgeInsets(top: 0, left: frame.width, bottom: 0, right: frame.width)
        cell.addSubview(itemLabel)
        
        return cell
    }
    
    func setTapListener(tapListener: @escaping TapListener){
        self.listener = tapListener
    }
}
