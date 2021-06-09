//
//  RemoteFeedLoaderTests.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 03/06/21.
//

import XCTest

class HTTPClientSpy:HTTPClient{
    var requestedURL: URL?
    func get(from url: URL){
        requestedURL = url
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL(){
        let (_,client) = makeSUT()
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK:- Helpers
    
    private func makeSUT(url:URL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
}
