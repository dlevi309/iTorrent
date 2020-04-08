//
//  TorrentListController+DataSource.swift
//  iTorrent
//
//  Created by Daniil Vinogradov on 06.04.2020.
//  Copyright © 2020  XITRIX. All rights reserved.
//

import UIKit

extension TorrentListController {
    func initializeTableView() {
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.register(TableHeaderView.nib, forHeaderFooterViewReuseIdentifier: TableHeaderView.id)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 82
        tableView.rowHeight = 82
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension TorrentListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        torrentSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        torrentSections[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TorrentCell
        cell.setModel(torrentSections[indexPath.section].value[indexPath.row].value)
        return cell
    }
}

extension TorrentListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateEditStatus()
        } else {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? TorrentDetailsController {
                viewController.managerHash = torrentSections[indexPath.section].value[indexPath.row].value.hash
                
                if !splitViewController!.isCollapsed {
                    let navController = storyboard?.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
                    navController.viewControllers.append(viewController)
                    navController.isToolbarHidden = false
                    navController.navigationBar.tintColor = navigationController?.navigationBar.tintColor
                    navController.toolbar.tintColor = navigationController?.navigationBar.tintColor
                    splitViewController?.showDetailViewController(navController, sender: self)
                } else {
                    splitViewController?.showDetailViewController(viewController, sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateEditStatus()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        torrentSections[section].value.isEmpty || torrentSections[section].title.isEmpty ? CGFloat.leastNonzeroMagnitude : 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableHeaderView.id) as? TableHeaderView {
            cell.title.text = Localize.get(torrentSections[section].title)
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let hashes = [torrentSections[indexPath.section].value[indexPath.row].value.hash]
        Core.shared.removeTorrentsUI(hashes: hashes, sender: tableView.cellForRow(at: indexPath)!, direction: .left) {
            self.update()
            
            // if detail view opens with deleted hash, close it
            if let splitViewController = self.splitViewController,
                !splitViewController.isCollapsed,
                let nav = splitViewController.viewControllers[1] as? UINavigationController,
                let detailView = nav.viewControllers.first as? TorrentDetailsController {
                if hashes.contains(where: { $0 == detailView.managerHash }) {
                    splitViewController.showDetailViewController(Utils.createEmptyViewController(), sender: self)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        setEditing(true, animated: true)
    }
}
