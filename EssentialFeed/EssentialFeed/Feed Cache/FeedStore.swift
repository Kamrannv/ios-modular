//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Kamran on 28.02.25.
//
import Foundation


public typealias CachedFeed  = (timestamp: Date, feed: [LocalFeedImage])
 
public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void
    
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    typealias RetreivalResult = Result<CachedFeed?, Error>
    typealias RetreivalCompletion = (RetreivalResult) -> Void
    
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

