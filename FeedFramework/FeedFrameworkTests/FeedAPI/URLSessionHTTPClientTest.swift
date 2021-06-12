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
        session.dataTask(with: requestedURL) { (_, _, _) in }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string: "https://github.com/techiesanjaypathak/FeedFramework")!
        let urlSession = URLSessionSyp()
        let task = URLSessionDataTaskSpy()
        urlSession.stub(url:url, task:task)
        
        let sut = URLSessionHTTPClient(session: urlSession)
        sut.get(from:url)
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK:- Helpers
    
    private class URLSessionSyp: URLSession {
        var stubs = [URL:URLSessionDataTask]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        func stub(url: URL, task:URLSessionDataTask){
            stubs[url] = task
        }
    }
    
    private class FakeURLSessionDataTask:URLSessionDataTask {
        override func resume() {
            
        }
    }
    private class URLSessionDataTaskSpy:URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
