//
//  FeedItemMapper.swift
//  FeedFramework
//
//  Created by SanjayPathak on 12/06/21.
//

import Foundation
internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feedItems:[FeedItem] {
            items.map{ $0.feedItem }
        }
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
    private static var HTTP200:Int { return 200 }
    public static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == HTTP200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feedItems)
    }
}
