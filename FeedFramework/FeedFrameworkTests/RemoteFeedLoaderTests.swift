//
//  RemoteFeedLoaderTests.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 03/06/21.
//

import XCTest

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL(){
        let (_,client) = makeSUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let (sut,client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0, userInfo: nil)
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {
            capturedErrors.append($0)
        }
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    // MARK:- Helpers
    
    private func makeSUT(url:URL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{
        var requestedURLs = [URL]()
        var error : NSError?
        func get(from url: URL, completion: @escaping (Error) -> Void){
            if let error  = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
    
}
