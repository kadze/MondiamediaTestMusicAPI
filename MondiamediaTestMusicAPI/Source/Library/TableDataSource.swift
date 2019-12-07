//
//  TableDataSource.swift
//  MagicCoin
//
//  Created by ASH on 8/1/17.
//  Copyright © 2017 Gamayun. All rights reserved.
//

import UIKit

class TableDataSource<CellType: UITableViewCell, Model>: NSObject, UITableViewDataSource {
    var cellIdentifier: String!
    var items: [Model]!
    var configureCell: (CellType, Model) -> ()
    
    init(cellIdentifier: String, items: [Model], configureCell: @escaping (CellType, Model) -> ()) {
        self.configureCell = configureCell
        super.init()
        self.cellIdentifier = cellIdentifier
        self.items = items
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CellType else {
            return UITableViewCell()
        }
        
        let model = items[indexPath.row]
        configureCell(cell, model)
        
        return cell
    }
}
