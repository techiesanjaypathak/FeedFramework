//
//  RemoteFeedLoaderTests.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 03/06/21.
//

import XCTest

class RemoteFeedLoader{
    let client : HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    func load(){
        client.get(from: URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!)
    }
}

protocol HTTPClient{
    func get(from url: URL)
}

class HTTPClientSpy:HTTPClient{
    var requestedURL: URL?
    func get(from url: URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL(){
        let client = HTTPClientSpy()
        let _ = RemoteFeedLoader(client: client)
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
}
