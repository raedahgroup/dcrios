//
//  NetworkModeTableViewController.swift
//  Decred Wallet
//
// Copyright (c) 2018-2019 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

import UIKit

class NetworkModeTableViewController: UITableViewController {
    
    @IBOutlet weak var spv_cell: UITableViewCell!
    @IBOutlet weak var local_node: UITableViewCell!
    @IBOutlet weak var remote_cell: UITableViewCell!
    
    let network_value = UserDefaults.standard.integer(forKey: "network_mode") 
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (network_value == 0) {
            spv_cell.accessoryType = .checkmark
            spv_cell.setSelected(true, animated: true)
            local_node.accessoryType = .none
            remote_cell.accessoryType = .none
        } else if(network_value == 1) {
            spv_cell.accessoryType = .none
            local_node.accessoryType = .checkmark
            local_node.setSelected(true, animated: true)
            remote_cell.accessoryType = .none
        } else if(network_value == 2) {
            spv_cell.accessoryType = .none
            local_node.accessoryType = .none
            remote_cell.accessoryType = .checkmark
            remote_cell.setSelected(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        spv_cell.accessoryType = .none
        local_node.accessoryType = .none
        remote_cell.accessoryType = .none
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        UserDefaults.standard.set(indexPath.row, forKey: "network_mode")
        UserDefaults.standard.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
}
