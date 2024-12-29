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
        XCTAssertTrue(client.requestedUrls.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "/url")!
        let (sut, client) = makeFactorySUT()
        sut.load { _ in }
        XCTAssertEqual(client.requestedUrls, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "/url")!
        let (sut, client) = makeFactorySUT()
        sut.load { _ in }
        sut.load { _ in }
        XCTAssertEqual(client.requestedUrls, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeFactorySUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        let clientError = NSError(domain: "Test", code: 0)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200Error() {
        let (sut, client) = makeFactorySUT()
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { index, code in
            var capturedErrors =
            [RemoteFeedLoader.Error]()
            
            sut.load { capturedErrors.append($0) }
            
            client.complete(withStatusCode: code, at: index)
            
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    // MARK:  - Helpers
    private func makeFactorySUT(url: URL = URL(string: "/url")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
    
    private  class HTTPClientSpy: HTTPClient {

        private var messages = [(url: URL, completion: (HTTPClientResult)->Void)]()
        var requestedUrls: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult)->Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index:Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code:Int, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedUrls[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(response))
        }
    }
    
}
