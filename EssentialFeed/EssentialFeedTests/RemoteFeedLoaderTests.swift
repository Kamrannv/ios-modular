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
        let url = URL(string: "/url")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client, url: url)
        XCTAssertNil(client.requestedURL)
    }

  
    func test_load_requestDataFromURL() {
        let url = URL(string: "/url")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        sut.load()
        XCTAssertEqual(client.requestedURL, url)
    }
}
