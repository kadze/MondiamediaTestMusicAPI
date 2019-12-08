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

//MARK: - Network

extension MusicItem {
    
    static func itemsFromAPI(with completion:((AccessToken) -> ())?) {
        let tokenRequestHeaders = ["Content-Type" : "application/x-www-form-urlencoded",
                                   "Accept" : "application/json",
                                   "X-MM-GATEWAY-KEY" : "Ge6c853cf-5593-a196-efdb-e3fd7b881eca"]
        let request = Request(path: NetworkConstants.accessTokenPath, method: .post, headers: tokenRequestHeaders)
        Network.shared.send(request) { (result: Result<AccessToken, Error>) in
            switch result {
              case .success(let token):
                print(token.accessToken)//!!here to continue
              case .failure(let error):
                print(error)
            }
        }
    }
}
