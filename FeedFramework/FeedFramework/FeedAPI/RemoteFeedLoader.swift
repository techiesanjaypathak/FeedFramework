//
//  RemoteFeedLoader.swift
//  FeedFramework
//
//  Created by SanjayPathak on 09/06/21.
//

import Foundation

public enum RFResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (RFResult) -> Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client : HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void){
        client.get(from: url){ result in
            switch result {
            case let .success(data,_):
                if let _ = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
