//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 27.11.24.
//

import XCTest
import EssentialFeed


final class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestFromURL() {
        let(_, client) = makeFactorySUT()
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "/url")!
        let (sut, client) = makeFactorySUT()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "/url")!
        let (sut, client) = makeFactorySUT()
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeFactorySUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    // MARK:  - Helpers
    private func makeFactorySUT(url: URL = URL(string: "/url")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private  class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        func get(from url: URL, completion: @escaping (Error)->Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
    
}
