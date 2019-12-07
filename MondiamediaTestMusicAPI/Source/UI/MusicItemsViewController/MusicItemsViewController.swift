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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        
    }
    
    //MARK: - Private
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search music"
        definesPresentationContext = true
    }

}
