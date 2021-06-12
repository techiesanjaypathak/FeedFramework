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
                let jsonData = makeItemsJSONData([])
                client.complete(withStatusCode: statusCode, data: jsonData, at: index)
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
            let data = makeItemsJSONData([])
            client.complete(withStatusCode: 200, data: data, at: 0)
        }
    }
    
    func test_load_deliversItemsWith200HTTPResponse(){
        let (sut, client) = makeSUT()
        let item1 = getJsonObjectAndModel(
            with: UUID(),
            description: "Good Weather",
            location: "Bengaluru",
            url: URL(string: "http://some.com/image/url1.png")!
        )
        let item2 = getJsonObjectAndModel(
            with: UUID(),
            url: URL(string: "http://some.com/image/url2.png")!
        )
        expect(sut, result: .success([item1.model, item2.model])) {
            let itemsJSONData = makeItemsJSONData([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: itemsJSONData, at: 0)
        }
    }
    
    // MARK:- Helpers
    
    private func makeSUT(url:URL = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!) -> (RemoteFeedLoader, HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        checkIfDeallocated(client)
        checkIfDeallocated(sut)
        return (sut,client)
    }
    
    private func expect(_ sut:RemoteFeedLoader, result:RemoteFeedLoader.Result, file: StaticString = #filePath, line: UInt = #line, where action: ()-> Void){
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load { capturedResults.append($0) }
        action()
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    private func checkIfDeallocated(_ object:AnyObject, file: StaticString = #filePath, line: UInt = #line){
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Should deallocate. Potential memory leak.", file: file, line: line)
        }
    }
    
    private func makeItemsJSONData(_ jsonArray: [[String:Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: [ "items":  jsonArray], options: .withoutEscapingSlashes)
    }
    
    private func getJsonObjectAndModel(with id: UUID, description: String? = nil, location: String? = nil, url: URL) -> (model: FeedItem, json: [String:Any]){
        let itemModel = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: url
        )
        let itemJSON = [
            "id":itemModel.id.uuidString,
            "description":itemModel.description,
            "location":itemModel.location,
            "image":itemModel.imageURL.absoluteString
        ].reduce(into: [String:Any]()) { (accumelated, element) in
            if let value = element.value {
                accumelated[element.key] = value
            }
        }
        return (itemModel,itemJSON)
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
        func complete(withStatusCode code: Int, data: Data, at index: Int = 0){
            let httpUrlResponse = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, httpUrlResponse))
        }
    }
    
}
