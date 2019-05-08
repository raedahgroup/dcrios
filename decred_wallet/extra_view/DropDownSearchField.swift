//
//  DropDownSearchField.swift
//  Decred Wallet
//
/// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class DropDownSearchField: UITextField, UITextFieldDelegate {
    var dropDownListPlaceholder: UIView?
    var wordsToFilter: [String] = []
    var maxDropDownResultsCount = 4
    
    private var dropDownTable: UITableView?
    private var dropDownTableDataSource: DropDownTableDataSource
    
    // callbacks for when user selects a word from dropdown or leaves input field without selecting a word
    var onTextChanged: (() -> Void)?
    var onWordSelected:((_ selectedWord: String) -> Void)? {
        get {
            return self.dropDownTableDataSource.onWordSelected
        }
        set {
            self.dropDownTableDataSource.onWordSelected = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        dropDownTableDataSource = DropDownTableDataSource()
        super.init(coder: aDecoder)
    }
    
    func setupDropdownTable(with wordsToFilter: [String], and placeHolderView: UIView) {
        self.wordsToFilter = wordsToFilter
        self.dropDownListPlaceholder = placeHolderView
        self.dropDownListPlaceholder!.isHidden = true
        
        let dropDownTableRect = CGRect(
            x: 0, y: 0,
            width: Int(self.dropDownListPlaceholder!.frame.size.width),
            height: Int(self.dropDownTableDataSource.tableHeight())
        )
        self.dropDownTable = UITableView(frame: dropDownTableRect, style: .plain)
        
        self.dropDownTable?.register(UITableViewCell.self, forCellReuseIdentifier: (self.dropDownTableDataSource.cellIdentifier))
        self.dropDownTable?.dataSource = self.dropDownTableDataSource
        self.dropDownTable?.delegate = self.dropDownTableDataSource
        
        // listen for text editing event and filter words
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // listen for when text editing ends and hide dropdown
        self.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        var filteredWords = self.wordsToFilter.filter({
            return (currentText.count >= 2 && $0.lowercased().hasPrefix(currentText.lowercased()))
        })
        if filteredWords.count > self.maxDropDownResultsCount {
            filteredWords = Array(filteredWords.dropLast(filteredWords.count - self.maxDropDownResultsCount))
        }
        self.dropDownTableDataSource.filteredWords = filteredWords
        
        if filteredWords.count == 0 {
            self.dropDownListPlaceholder?.isHidden = true
            return
        }
        
        let tableHeight = self.dropDownTableDataSource.tableHeight()
        let textFieldYPos = textField.superview?.convert(textField.frame.origin, to: nil).y ?? 0
        let dropDownHolderMaxHeight = self.dropDownListPlaceholder?.superview?.frame.height ?? 0
        
        var dropDownYPos = textFieldYPos + textField.frame.height
        if (dropDownYPos + tableHeight) > dropDownHolderMaxHeight {
            dropDownYPos = textFieldYPos - tableHeight
        }
        
        self.dropDownTable?.frame.size.height = tableHeight
        self.dropDownListPlaceholder?.frame.size.height = tableHeight
        self.dropDownListPlaceholder?.frame.origin.y = dropDownYPos
        
        self.dropDownTable?.reloadData()
        self.dropDownListPlaceholder?.isHidden = false
        
        if self.dropDownListPlaceholder?.subviews.count == 0 {
            self.dropDownListPlaceholder?.addSubview(self.dropDownTable!)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        self.dropDownListPlaceholder?.isHidden = true
        self.dropDownTable?.removeFromSuperview()
        self.onTextChanged?()
    }
}

class DropDownTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let cellIdentifier: String = "dropDownCell"
    let cellHeight: CGFloat = 40
    let footerHeight: CGFloat = 22
    
    var filteredWords: [String] = []
    var onWordSelected: ((_ selectedWord: String) -> Void)?
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredWords.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedWord = self.filteredWords[indexPath.row]
        self.onWordSelected?(selectedWord)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell.textLabel?.text = self.filteredWords[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerHintLabel = UILabel(frame: CGRect(x: 1, y: 1, width: tableView.frame.width, height: self.footerHeight))
        footerHintLabel.text = "Tap to select the word"
        footerHintLabel.backgroundColor = UIColor.init(hex: "#DDDDDD")
        return footerHintLabel
    }
    
    func tableHeight() -> CGFloat {
        return (CGFloat(self.filteredWords.count) * self.cellHeight) + self.footerHeight
    }
}
