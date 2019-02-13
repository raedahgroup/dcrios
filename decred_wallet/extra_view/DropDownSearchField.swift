//
//  DropDownSearchField.swift
//  Decred Wallet
//
/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

protocol DropDownResultsListProtocol : UITableViewDataSource, UITableViewDelegate {
    var items: [String]?{get set}
    var cellIdentifier: String{get set}
    var onSelect:((Int, String)->Void)? {get set}
}

protocol SearchDataSourceProtocol: class {
    var itemsToSearch:[String]?{get set}
    var dropDownListPlaceholder: UIView? {get set}
    var onTextChanged:(()->Void)? {get set}
    func clean()
}

class DropDownListDataSource: NSObject,  DropDownResultsListProtocol {
    
    var onSelect: ((Int, String) -> Void)?
    var items: [String]?
    var cellIdentifier: String = ""
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let item = items?[index] ?? ""
        onSelect?(index, item)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        setup(cell: cell, index: indexPath.row)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    private func setup(cell:UITableViewCell, index: Int){
        cell.textLabel?.text = items?[index]
    }
    
    @objc func onPickSeedWord(sender: UIButton?){
        let index = sender!.tag
        let item = items?[index] ?? ""
        onSelect?(index, item)
    }
}

class DropDownSearchField: UITextField, UITextFieldDelegate, SearchDataSourceProtocol {
    
    var onTextChanged: (() -> Void)?
    var dropDownListPlaceholder: UIView?
    var itemsToSearch: [String]?
    private var dropDownTable: UITableView?
    var searchResult: DropDownResultsListProtocol?
    var vertPosition: CGFloat = 0.0
    
    var onSelect:((Int, String)->Void)?{
        get{
            return searchResult?.onSelect
        }
        set{
            searchResult?.onSelect = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        searchResult = DropDownListDataSource()
        searchResult?.cellIdentifier = "dropDownCell"
        searchResult?.onSelect = self.onSelect
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        setupDropdownTable()
    }
    
    func setupDropdownTable() {
        let count = Int(searchResult?.items?.count ?? 0)
        dropDownTable = UITableView(frame: CGRect(x: 0, y: 0, width: Int((dropDownListPlaceholder?.frame.size.width) ?? 0), height: 44 * count), style: .plain)
        dropDownTable?.register(UITableViewCell.self, forCellReuseIdentifier: (searchResult?.cellIdentifier)!)
        dropDownTable?.dataSource = searchResult
        dropDownTable?.delegate = searchResult
        dropDownTable?.allowsSelection = true
        dropDownTable?.isUserInteractionEnabled = true
    }
    
    func clean() {
        searchResult?.items = []
    }
    
    func hideDropDown(){
        dropDownListPlaceholder?.isHidden = true
        clean()
    }
    
    func showDropDown(){
        dropDownListPlaceholder?.isHidden = false
    }
    
    func updatePlaceholder(position:Int){
        vertPosition = CGFloat(position)
        dropDownTable?.frame.size.height = CGFloat((searchResult?.items?.count) ?? 0) * CGFloat(44.0);
        dropDownListPlaceholder?.frame = CGRect(x: Int((dropDownListPlaceholder?.frame.origin.x)!), y: position, width: 200, height: Int(CGFloat((searchResult?.items?.count) ?? 0) * CGFloat(44.0)))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        dropDownListPlaceholder?.isHidden = true
        dropDownTable?.removeFromSuperview()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        dropDownListPlaceholder?.isHidden = false
        dropDownListPlaceholder?.addSubview(dropDownTable!)
        onTextChanged?()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        updateSearchResult(with: textField.text ?? "")
        dropDownTable?.frame.size.height = CGFloat(((searchResult?.items?.count) ?? 0 >= 4 ? 4 : searchResult?.items?.count ?? 0)) * CGFloat(44.0);
        dropDownListPlaceholder?.frame.size.height = CGFloat((searchResult?.items?.count) ?? 0) * CGFloat(44.0);
        if (searchResult?.items?.count)! == 0 {
            hideDropDown()
        } else {
            showDropDown()
        }
        dropDownTable?.reloadData()
        
    }
    
    private func updateSearchResult(with text: String){
        searchResult?.items = itemsToSearch?.filter({ return ($0.lowercased().hasPrefix(text.lowercased()) && text.count > 2) })
    }
    
    func updateSearchResults(){
        let text = self.text ?? ""
        updateSearchResult(with: text)
    }
}
