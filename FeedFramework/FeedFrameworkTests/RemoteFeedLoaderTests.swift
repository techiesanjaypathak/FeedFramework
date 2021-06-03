//
//  RemoteFeedLoaderTests.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 03/06/21.
//

import XCTest

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.requestedURL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")
    }
}

class HTTPClient{
    static let shared = HTTPClient()
    var requestedURL: URL?
    
    private init (){}
}

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesnotRequestDataFromURL(){
        let client = HTTPClient.shared
        let _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }

}
