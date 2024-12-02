//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Kamran on 02.12.24.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
   public init(client: HTTPClient, url: URL = URL(string: "/url")!) {
        self.client = client
        self.url = url
    }
    
   public func load() {
        client.get(from:  url)
    }
}


