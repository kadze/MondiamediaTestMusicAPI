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
        imageView?.image = nil
    }
    
    func fillWith(model: MusicItem?) {
        titleLabel.text = model?.title
        artistLabel.text = model?.artist
//        itemImageView.image = model?.image
        typeLabel.isHidden = model?.type == MusicItemType.song
        
        DispatchQueue.global().async { [weak self] in
            if let urlString = model?.tinyImageURLAddress,
                let url = URL(string: "\(NetworkConstants.scheme):\(urlString)")
            {
                let data = try? Data(contentsOf: url)
                if let imageData = data,
                    let image = UIImage(data: imageData)
                {
                    DispatchQueue.main.async {
                        self?.itemImageView.image = image
                    }
                }
            }
        }
    }

}
