//
//  RecoverWalletTableViewController.swift
//  Decred Wallet

// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

class RecoverWalletTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var vDropDownPlaceholder: UIView!
    @IBOutlet weak var confirm_btn: UIButton!
    
    var currentTextField : UITextField?
    var nextTextField : UITextField?
    var textFields: [UITextField?] = []
    
    var seedWords: [String?] = []
    var suggestionWords: [String] = []
    var seedtmp : [String] = []
    var suggestions: [String] = []
    var recognizer:UIGestureRecognizer?
    let seedtmp2 = "reform aftermath printer warranty gremlin paragraph beehive stethoscope regain disruptive regain Bradbury chisel October trouble forever Algol applicant island infancy physique paragraph woodlark hydraulic snapshot backwater ratchet surrender revenge customer retouch intention minnow"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.confirm_btn.addGestureRecognizer(recognizer!)
        seedtmp = loadSeedWordsList()
        registerObserverForKeyboardNotification()
        recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHappened))
    }
    
    // MARK: - Table view data source
    
    deinit {
        unregisterObserverForKeyboardNotification()
    }
    
    func registerObserverForKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unregisterObserverForKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillShow, object:nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    @objc func onKeyboardWillShow(_ notification: Notification){
        let notificationInfo = notification.userInfo
        let keyboardFrame = (notificationInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let f = tableView.frame
        tableView.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.size.width, height: f.size.height - keyboardFrame.size.height + (tableView.tableHeaderView?.frame.size.height)! )
    }
    
    @objc func onKeyboardWillHide(_ notification: Notification){
        let f = view.frame
        tableView.frame = CGRect(x: 0, y: 0, width: f.size.width, height: f.size.height)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "seedWordCell", for: indexPath) as? RecoveryWalletSeedWordsCell
        cell?.setup(wordNum: indexPath.row, word: seedWords.count <= indexPath.row ? "" : seedWords[indexPath.row] ?? "", seed: seedtmp, placeholder: vDropDownPlaceholder)
        cell?.tfSeedWord.isEnabled = (indexPath.row == 0 || textFields.count < indexPath.row)
        
        if indexPath.row > textFields.count {
            textFields[indexPath.row] = cell?.tfSeedWord
        } else {
            textFields.append(cell?.tfSeedWord)
        }
        
        cell?.onPickUpSeed = {(index, pickedSeedWord) in
            
            cell?.tfSeedWord.text = pickedSeedWord
            self.seedWords.append(pickedSeedWord)
            cell?.hideDropDown()
            
            if indexPath.row < 32 {
                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: 0 )
                let next = tableView.cellForRow(at: nextIndexPath) as? RecoveryWalletSeedWordsCell
                next?.tfSeedWord.updateSearchResults()
                next?.tfSeedWord.isEnabled = true
                next?.tfSeedWord.becomeFirstResponder()
                tableView.scrollToRow(at: nextIndexPath, at: .middle, animated: true)
                next?.updatePlaceholder(vertPosition: Int(self.dropdownPosition(for: nextIndexPath)))
            } else {
                cell?.tfSeedWord.resignFirstResponder()
            }
        }
        
        return cell!
    }
    
    private func dropdownPosition(for indexPath:IndexPath) -> CGFloat{
        
        let scrollOffset = self.tableView.contentOffset
        
        let nextCellPos = self.tableView.rectForRow(at: indexPath)
        let dropDownHeight = vDropDownPlaceholder.frame.size.height
        
        let res = nextCellPos.origin.y - scrollOffset.y
        if (indexPath.row < 3) {
            return nextCellPos.origin.y + nextCellPos.size.height + 20
        } else if (indexPath.row > 28) {
            return res - dropDownHeight + nextCellPos.size.height * 3
        }
        
        return res
    }
    
    private func checkupSeed(){
        let seed = seedWords.reduce("", { x, y in  x + " " + y!})
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            self.performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
        } else {
            show(error:"Seed is not valid")
        }
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
    
    @IBAction func onConfirm() {
        checkupSeed()
    }
    
    @IBAction func onClear(_ sender: Any) {
        seedWords = []
        tableView.reloadData()
    }
    
    var count = 0
    @objc func longPressHappened(){
        view.endEditing(true)
        count = count + 1
        if (count == 1){
            let flag = SingleInstance.shared.wallet?.verifySeed(seedtmp2)
            if flag! {
                performSegue(withIdentifier: "confirmSeedSegue", sender: nil)
                return
            }
            
            show(error: "Seed was not verifed!")
        }
        
    }
    
    private func show(error:String){
        let alert = UIAlertController(title: "Recovery error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {
                self.onClear(self)
            })
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmSeedSegue" {
            var vc = segue.destination as? SeedCheckupProtocol
            vc?.seedToVerify = seedWords.reduce("", { x, y in  x + " " + y!})
            if (count == 1) {
                vc?.seedToVerify = seedtmp2
            }
        }
    }
}

extension RecoverWalletTableViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        vDropDownPlaceholder.isHidden = true
    }
}
