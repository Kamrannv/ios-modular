//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kamran on 28.02.25.
//
import Foundation

public typealias RetrieveCachedFeedResult = Result<CachedFeed, Error>

public enum CachedFeed {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}
public protocol FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetreivalCompletion = (RetrieveCachedFeedResult) -> Void
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetreivalCompletion)
}

//public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)
//
//public protocol FeedStore {
//    func deleteCachedFeed() throws
//    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
//    func retrieve() throws -> CachedFeed?
//}

