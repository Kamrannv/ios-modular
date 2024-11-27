//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 27.11.24.
//

import XCTest

class RemoteFeedLoader {
    
    let client: HTTPClient
    let url: URL
    
    init(client: HTTPClient, url: URL = URL(string: "/url")!) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from:  url)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}


class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestFromURL() {
        let(_, client) = makeFactorySUT()
        XCTAssertNil(client.requestedURL)
    }

  
    func test_load_requestDataFromURL() {
        let url = URL(string: "/url")!

        let (sut, client) = makeFactorySUT()
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
    
    func makeFactorySUT(url: URL = URL(string: "/url")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return (sut, client)
    }
}
