//
//  MusicItemViewController.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 08.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

class MusicItemViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var artistLabel: UILabel?
    @IBOutlet var coverImageView: UIImageView?
    
    var model: MusicItem? {
        didSet {
            if let model = model {
                self.fillWith(model: model)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let model = model {
            self.fillWith(model: model)
        }
    }

    func fillWith(model: MusicItem) {
        titleLabel?.text = model.title
        artistLabel?.text = model.artist
        
        if let image = model.largeImage {
            coverImageView?.image = image
        } else {
            model.largeImageSetHandler = {[ weak self ] image in
                self?.coverImageView?.image = image
            }
            
            model.loadLargeImage()
        }
    }
}
