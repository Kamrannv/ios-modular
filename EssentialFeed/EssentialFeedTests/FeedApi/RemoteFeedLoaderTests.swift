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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    }
    
    func test_load_deliversErrorOnNon200Error() {
        let (sut, client) = makeFactorySUT()
        let statusCodes = [199, 201, 300, 400, 500]
        statusCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let jsonData = makeItemJson([])
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }
    
    func test_loadDataWith200WithInvalidJson() {
        let (sut, client) = makeFactorySUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
       
    }
    
    func test_load_deliversNoItemsWith200HTTPResponse() {
        let  (sut, client) = makeFactorySUT()
        expect(sut, toCompleteWith: .success([])) {
            let emptyListJson = Data("{\"items\": []}".utf8)
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsWith200HTTPResponse() {
        let (sut, client) = makeFactorySUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://a-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "desc",
            location: "location",
            imageURL: URL(string: "http://another-url.com")!

        )
        
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemJson([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_doesNotDeliverAfterSutInstanceHasBeenDellocated() {
        let url = URL(string: "url")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load {
            capturedResults.append($0)
        }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
        
    }
    
    // MARK:  - Helpers
    private func makeFactorySUT(url: URL = URL(string: "/url")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(sut, file:file, line:line)
        trackForMemoryLeaks(client, file:file, line:line)
        return (sut, client)
    }
 
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: ()->Void, file: StaticString = #filePath, line: UInt = #line){
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult){
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file:file, line:line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file:file, line:line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead")
            }
            exp.fulfill()
            
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL)->(model: FeedItem, json: [String: Any]) {
        
        let items = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value}
        }
        return (items, json)
    }
    
    private func makeItemJson(_ items: [[String: Any]]) ->Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
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
        
        func complete(withStatusCode code:Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedUrls[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil)!
            
            messages[index].completion(.success(data, response))
        }
    }
    
}
