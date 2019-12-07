//
//  PostRequest.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 07.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import Foundation

struct PostRequest<Model: Encodable>: Requestable {
    let path: String
    let model: Model

    func urlRequest() -> URLRequest {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            return URLRequest(url: URL(fileURLWithPath: ""))
        }
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = HTTPMethod.post.rawValue
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(model)
            request.httpBody = data
            request.setValue("application/json",
                                forHTTPHeaderField: "Content-Type")
        } catch let error {
            let _ = error //here handle the error
        }
        
        return request
    }
}
