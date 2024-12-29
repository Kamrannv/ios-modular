//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Kamran on 02.12.24.
//

import Foundation


public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?)->Void)
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
   public init(client: HTTPClient, url: URL = URL(string: "/url")!) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void) {
        client.get(from:  url){ err, response in
            if  response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
           
        }
    }
}


