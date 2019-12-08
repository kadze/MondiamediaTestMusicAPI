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
    let urlComponents: URLComponents?
    
    
    init(path: String,
         method: HTTPMethod = .get,
         headers: [String : String] = [String : String]())
    {
        self.path = path
        self.method = method
        self.headers = headers
        self.urlComponents = nil
    }
    
    init(urlComponents: URLComponents,
         method: HTTPMethod = .get,
         headers: [String : String] = [String : String]())
    {
        self.path = ""
        self.method = method
        self.headers = headers
        self.urlComponents = urlComponents
    }
    
    func urlRequest() -> URLRequest {
        var url: URL
        if let components = urlComponents, let urlFromComponents = components.url {
            url = urlFromComponents
        } else {
            guard let baseURL = URL(string: NetworkConstants.baseURL) else {
                return URLRequest(url: URL(fileURLWithPath: ""))
            }
            
            url = baseURL.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
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
