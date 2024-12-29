//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Kamran on 02.12.24.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error)->Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
   public init(client: HTTPClient, url: URL = URL(string: "/url")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in }) {
        client.get(from:  url){ err in
            completion(.connectivity)
        }
    }
}


