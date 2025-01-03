//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 03.01.25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) {_, _, _ in}
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURl_createDataTaskURl() {
        let url = URL(string: "http://url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient.init(session: session)
        sut.get(from: url)
        XCTAssertEqual(session.receivedURLs, [url])
        
    }
    
    private class URLSessionSpy: URLSession{
        var receivedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
