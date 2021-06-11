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
        sut.load(){ _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let (sut,client) = makeSUT(url: url)
        sut.load(){ _ in }
        sut.load(){ _ in }
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_load_deliversErrorOnClientError(){
        let (sut,client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with:clientError)
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnClientHTTPErrorNon200HTTPResponse(){
        let (sut,client) = makeSUT()
        var capturedErrors = [RemoteFeedLoader.Error]()
        let statusCodes = [199,201, 300, 400, 500]
        statusCodes.enumerated().forEach { (index,statusCode) in
            sut.load { capturedErrors.append($0) }
            client.complete(withStatusCode: statusCode, at: index)
        }
        XCTAssertEqual(capturedErrors, Array(repeating: RemoteFeedLoader.Error.invalidData, count: statusCodes.count))
    }
    
    // MARK:- Helpers
    
    private func makeSUT(url:URL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private class HTTPClientSpy:HTTPClient{
        var messages = [(url:URL, completion:(Error?,HTTPURLResponse?)->Void)]()
        var requestedURLs : [URL]{
            return messages.map { $0.url }
        }
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void){
            messages.append((url,completion))
        }
        func complete(with error:NSError, atIndex index: Int = 0){
            messages[index].completion(error, nil)
        }
        func complete(withStatusCode code: Int, at index: Int = 0){
            let httpUrlResponse = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil,httpUrlResponse)
        }
    }
    
}
