//
//  MusicItem.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 08.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import UIKit

enum MusicItemType: String {
    case song
    case album
}

struct MusicItem {
    let title: String
    let artist: String
    let type: MusicItemType
    let image: UIImage
}
