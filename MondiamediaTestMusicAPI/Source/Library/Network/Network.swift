//
//  Network.swift
//  MondiamediaTestMusicAPI
//
//  Created by ASH on 07.12.2019.
//  Copyright © 2019 ASH. All rights reserved.
//

import Foundation

class Network {
    static let shared = Network()
    private let queue = DispatchQueue.global()
    let session: URLSession = URLSession(configuration: .default)
    
    enum NetworkError: Error {
        case noDataOrError
    }

    struct StatusCodeError: LocalizedError {
        let code: Int

        var errorDescription: String? {
            return "An error occurred communicating with the server. Please try again."
        }
    }
    
    func sendToRetreiveData(_ request: Requestable, completion: @escaping (Result<Data, Error>) -> Void) {
        queue.async {
            let urlRequest = request.urlRequest()
            
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<Data, Error>
                
                if let error = error {
                    result = .failure(error)
                } else if let error = self.error(from: response) {
                    result = .failure(error)
                } else if let data = data {
                    result = .success(data)
                } else {
                    result = .failure(NetworkError.noDataOrError)
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            task.resume()
        }
    }
    
    func send<T: Model>(_ request: Requestable, completion: @escaping (Result<T, Error>) -> Void) {
        queue.async {
            let urlRequest = request.urlRequest()
            
            let task = self.session.dataTask(with: urlRequest) { data, response, error in
                let result: Result<T, Error>
                
                if let error = error {
                    result = .failure(error)
                } else if let error = self.error(from: response) {
                    result = .failure(error)
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        result = .success(try decoder.decode(T.self, from: data))
                    } catch {
                        result = .failure(error)
                    }
                } else {
                    result = .failure(NetworkError.noDataOrError)
                }
                
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            
            task.resume()
        }
    }
    
    private func error(from response: URLResponse?) -> Error? {
        guard let response = response as? HTTPURLResponse else {
            return nil
        }
        
        let statusCode = response.statusCode
        
        if (200 ... 299).contains(statusCode) {
            return nil
        } else {
            return StatusCodeError(code: statusCode)
        }
    }
}
