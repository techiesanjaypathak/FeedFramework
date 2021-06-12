//
//  FeedItem.swift
//  FeedFramework
//
//  Created by SanjayPathak on 03/06/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id:UUID
    let description:String?
    let location:String?
    let imageURL:URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
