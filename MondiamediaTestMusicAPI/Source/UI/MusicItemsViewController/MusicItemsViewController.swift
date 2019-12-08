//
//  MusicItemsViewController.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 07.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

class MusicItemsViewController: UIViewController {

    let searchController = UISearchController(searchResultsController: nil)
    let cellIdentifier = String(describing: MusicItemTableViewCell.self)
    
    @IBOutlet var tableView: UITableView!
    
    var items = [MusicItem]() {
        didSet {
            self.updateTableView()
        }
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var dataSource: TableDataSource<MusicItemTableViewCell, MusicItem>!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupTableView()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        MusicItem.itemsFromAPI(with: searchText.lowercased()) { [weak self] (items) in
            self?.items = items
            self?.updateTableView()
        }
    }
    
    //MARK: - Private
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search music"
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
    }
    
    private func updateTableView() {
        self.dataSource = TableDataSource(cellIdentifier: cellIdentifier, items: items, configureCell: { (cell, item) in
            cell.model = item
        })
        
        tableView.dataSource = self.dataSource
        tableView.reloadData()
    }
}

extension MusicItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = items[indexPath.row]
        let detailController = MusicItemViewController.instantiate()
        detailController.model = model
        navigationController?.pushViewController(detailController, animated: true)
    }
}
