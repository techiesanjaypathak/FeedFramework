//
//  HTTPClient.swift
//  FeedFramework
//
//  Created by SanjayPathak on 12/06/21.
//

import Foundation

public enum RFResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (RFResult) -> Void)
}
