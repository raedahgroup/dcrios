//
//  ButtonConfirmSeedViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.
import UIKit

protocol SeedCheckupProtocol {
    var seedToVerify: String?{get set}
}

class ButtonConfirmSeedViewController: UIViewController, SeedCheckupProtocol {
    
    var seedToVerify: String?
    var selectedSeedWords: [Int] = []
    var allWords: [String] = []
    var enteredWords: [String] = []
    
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet var vActiveCellView: SeedCheckActiveCellView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allWords = loadSeedWordsList()
        for _ in 0...32 {
            selectedSeedWords.append(-1)
            enteredWords.append("")
        }
    }
    
    @IBAction func onConfirm(_ sender: Any) {
        let seed = enteredWords.joined(separator: " ")
        let flag = SingleInstance.shared.wallet?.verifySeed(seed)
        if flag! {
            performSegue(withIdentifier: "createPasswordSegue", sender: nil)
        } else {
            showError(error: "Seed does not matches. Try again, please")
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPasswordSegue" {
            var securityvc = segue.destination as? SeedCheckupProtocol
            securityvc?.seedToVerify = enteredWords.joined(separator: " ")
        }
    }
    
    private func showError(error:String){
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: {self.navigationController?.popToRootViewController(animated: true)})
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion:nil)
    }
    
    private func loadSeedWordsList() -> [String]{
        let seedWordsPath = Bundle.main.path(forResource: "wordlist", ofType: "txt")
        let seedWords = try? String(contentsOfFile: seedWordsPath ?? "")
        return seedWords?.split{$0 == "\n"}.map(String.init) ?? []
    }
}

extension ButtonConfirmSeedViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ButtonConfirmSeedViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 33
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tripleSeedCell", for: indexPath) as? SeedConfirmTableViewCell
        cell?.setup(num: indexPath.row, seedWords: breakdownByThree(row: indexPath.row), selected:pickSelected(row: indexPath.row))
        
        cell?.onPick = {(index, seedWord) in
            self.selectedSeedWords[indexPath.row] = index
            self.enteredWords[indexPath.row] = seedWord
            if indexPath.row < 32{
                tableView.selectRow(at: IndexPath(row: indexPath.row + 1, section: 0), animated: true, scrollPosition: .middle)
            }
            self.btnConfirm.isEnabled = self.enteredWords.reduce(true, { (res, input) -> Bool in
                return res && input != ""
            })
        }
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    private func breakdownByThree(row:Int) -> [String]{
        let seed = seedToVerify?.split{$0 == " "}.map(String.init)
        
        var suggestionsWithFake: [String] = ["","",""]
        let trueSeedIndex = Int.random(in: 0...2)
        let trueSeed = seed?[row]
        suggestionsWithFake[trueSeedIndex] = trueSeed ?? "dummy"
        
        let fakeWordsSet = allWords.filter({
            return ($0.lowercased().hasPrefix((String(trueSeed!.first!)).lowercased()))
        })
        
        let fakes = [fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count) - 1)], fakeWordsSet[Int.random(in: 0...(fakeWordsSet.count)-1)]]
        var fakeIndex = 0
        for i in 0...2 {
            if i != trueSeedIndex {
                suggestionsWithFake[i] = fakes[fakeIndex]
                fakeIndex += 1
            }
        }
        
        return  suggestionsWithFake
    }
    
    private func pickSelected(row: Int) -> Int{
        if selectedSeedWords.count > row {
            return selectedSeedWords[row]
        } else {
            return -1
        }
    }
}
