//
//  URLSessionHTTPClientTest.swift
//  FeedFrameworkTests
//
//  Created by SanjayPathak on 12/06/21.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    func get(from requestedURL:URL){
        session.dataTask(with: requestedURL) { (_, _, _) in
            
        }
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_createDataTahsWithURL(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let urlSession = URLSessionSyp()
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from:url)
        XCTAssertEqual(urlSession.receivedURLs, [url])
    }
    
    // MARK:- Helpers
    
    private class URLSessionSyp: URLSession {
        var receivedURLs = [URL]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionConfiguration:URLSessionConfiguration{}
    
    private class FakeURLSessionDataTask:URLSessionDataTask {
        
    }
}
