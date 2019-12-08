//
//  AccessToken.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 08.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import Foundation

struct AccessToken: Model {
    let accessToken: String
    let tokenType: String
    let expiresIn: String
}
