//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kamran on 28.02.25.
//
import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (LocalFeedLoader.SaveResult)->Void
    typealias InsertionCompletion = (LocalFeedLoader.SaveResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocaleFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocaleFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
