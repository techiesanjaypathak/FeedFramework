//
//  RemoteFeedLoaderTests.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 03/06/21.
//

import XCTest

class RemoteFeedLoader{
    func load(){
        HTTPClient.shared.get(from: URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!)
    }
}

class HTTPClient{
    static var shared = HTTPClient()
    var requestedURL: URL?
    
    func get(from url: URL){}
}

class HTTPClientSpy:HTTPClient{
    override func get(from url: URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        sut.load()
        XCTAssertNotNil(client.requestedURL)
    }
    
}
