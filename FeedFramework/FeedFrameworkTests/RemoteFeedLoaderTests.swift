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
        expect(sut, result: .failure(.connectivity), file: #filePath, line: #line) {
            let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
            client.complete(with:clientError)
        }
    }
    
    func test_load_deliversErrorOnClientHTTPErrorNon200HTTPResponse(){
        let (sut,client) = makeSUT()
        let statusCodes = [199,201, 300, 400, 500]
        statusCodes.enumerated().forEach { (index,statusCode) in
            expect(sut, result: .failure(.invalidData), file: #filePath, line: #line) {
                client.complete(withStatusCode: statusCode, at: index)
            }
        }
    }
    
    func test_load_deleversErrorOn200ResponseWithInvalidJSON(){
        let (sut,client) = makeSUT()
        expect(sut,result: .failure(.invalidData), file: #filePath, line: #line) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON,  at: 0)
        }
    }
    
    func test_load_deliversSuccessWithEmptyArray(){
        let (sut, client) = makeSUT()
        expect(sut, result: .success([]), file: #filePath, line: #line) {
            let data = Data("{\"items\":[]}".utf8)
            client.complete(withStatusCode: 200, data: data, at: 0)
        }
    }
    
    func test_load_deliversItemsWith200HTTPResponse(){
        let (sut, client) = makeSUT()
        let item1 = FeedItem(
            id: UUID(),
            description: "Good Weather",
            location: "Bengaluru",
            imageURL: URL(string: "http://some.com/image/url1.png")!
        )
        let item2 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "http://some.com/image/url2.png")!
        )
        let item1JSON = [
            "id":item1.id.uuidString,
            "description":item1.description,
            "location":item1.location,
            "image":item1.imageURL.absoluteString
        ]
        let item2JSON = [
            "id":item2.id.uuidString,
            "image":item2.imageURL.absoluteString
        ]
        let itemsJSON = [
            "items": [item1JSON,item2JSON]
        ]
        expect(sut, result: .success([item1, item2])) {
            let data = try! JSONSerialization.data(withJSONObject: itemsJSON, options: .withoutEscapingSlashes)
            client.complete(withStatusCode: 200, data: data, at: 0)
        }
    }
    
    // MARK:- Helpers
    
    private func makeSUT(url:URL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    private func expect(_ sut:RemoteFeedLoader, result:RemoteFeedLoader.Result, file: StaticString = #filePath, line: UInt = #line, where action: ()-> Void){
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private class HTTPClientSpy:HTTPClient{
        var messages = [(url:URL, completion:(RFResult)->Void)]()
        var requestedURLs : [URL]{
            return messages.map { $0.url }
        }
        func get(from url: URL, completion: @escaping (RFResult) -> Void){
            messages.append((url,completion))
        }
        func complete(with error:NSError, atIndex index: Int = 0){
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0){
            let httpUrlResponse = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, httpUrlResponse))
        }
    }
    
}
