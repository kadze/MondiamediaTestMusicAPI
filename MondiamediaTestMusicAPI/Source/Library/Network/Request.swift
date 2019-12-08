//
//  Request.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 07.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import Foundation

protocol Requestable {
    func urlRequest() -> URLRequest
}

struct Request: Requestable {
    let path: String
    let method: HTTPMethod
    let headers: [String : String]
    init(path: String,
         method: HTTPMethod = .get,
         headers: [String : String] = [String : String]())
    {
        self.path = path
        self.method = method
        self.headers = headers
    }
    
    func urlRequest() -> URLRequest {
        guard let url = URL(string: NetworkConstants.baseURL) else {
            return URLRequest(url: URL(fileURLWithPath: ""))
        }
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        
        headers.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}

extension URLRequest: Requestable {
    func urlRequest() -> URLRequest { return self }
}
