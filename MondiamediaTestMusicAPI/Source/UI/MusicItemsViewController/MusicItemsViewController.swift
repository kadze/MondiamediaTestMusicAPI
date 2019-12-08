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
    
    var dataSource: TableDataSource<MusicItemTableViewCell, MusicItem>!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupTableView()
        
        items = [MusicItem(title: "1", artist: "11", type: .song, image: #imageLiteral(resourceName: "Logo")),
        MusicItem(title: "2", artist: "22", type: .album, image: #imageLiteral(resourceName: "Logo"))]
        updateTableView()
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
        //no register sell because in storyboard
    }
    
    private func updateTableView() {
        self.dataSource = TableDataSource(cellIdentifier: cellIdentifier, items: items, configureCell: { (cell, item) in
            cell.model = item
        })
        
        tableView.dataSource = self.dataSource
        tableView.reloadData()
    }

}
