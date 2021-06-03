//
//  FeedLoader.swift
//  FeedFramework
//
//  Created by SanjayPathak on 03/06/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
