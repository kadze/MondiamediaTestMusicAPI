//
//  MusicItemTableViewCell.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 08.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

class MusicItemTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var artistLabel : UILabel!
    @IBOutlet var typeLabel : UILabel!
    @IBOutlet var itemImageView : UIImageView!
    
    var model : MusicItem? {
        didSet {
            self.fillWith(model: model)
        }
    }
    
    override func prepareForReuse() {
        typeLabel.isHidden = false
        itemImageView?.image = nil
    }
    
    func fillWith(model: MusicItem?) {
        titleLabel.text = model?.title
        artistLabel.text = model?.artist
        typeLabel.isHidden = model?.type == MusicItemType.song
        
        if let image = model?.tinyImage {
            itemImageView.image = image
        } else {
            model?.tinyImageSetHandler = {[ weak self ] image in
                self?.itemImageView?.image = image
            }
            
            model?.loadTinyImage()
        }
    }
}
