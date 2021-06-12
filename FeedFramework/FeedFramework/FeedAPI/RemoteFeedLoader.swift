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
            case let .success(data, response):
                do {
                    let items = try FeedItemMapper.map(data, response: response)
                    completion(.success(items))
                }catch{
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
private class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
    }
    private struct Item: Decodable {
        let id:UUID
        let description:String?
        let location:String?
        let image:URL
        
        var feedItem: FeedItem {
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: image)
        }
    }
    static var HTTP200:Int { return 200 }
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == HTTP200 else { throw RemoteFeedLoader.Error.invalidData }
        return try JSONDecoder().decode(Root.self, from: data).items.map{$0.feedItem}
    }
}
