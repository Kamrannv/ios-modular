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


