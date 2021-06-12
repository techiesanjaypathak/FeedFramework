//
//  FeedLoader.swift
//  FeedFramework
//
//  Created by SanjayPathak on 03/06/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

//extension LoadFeedResult: Equatable where Error: Equatable { }

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
