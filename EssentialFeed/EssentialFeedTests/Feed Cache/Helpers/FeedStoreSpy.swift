//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Kamran on 28.02.25.
//
import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage: Equatable {
        case deletedCachedFeed
        case insert([LocaleFeedImage], Date)
        case retrieve
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retreivalCompletions = [RetreivalCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
        deletionCompletions.append(completion)
        receivedMessages.append(.deletedCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index:Int = 0) {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](nil)
    }
    func insert(_ items: [LocaleFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
    func retrieve(completion: @escaping RetreivalCompletion) {
        retreivalCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    func completeRetrival(with error: Error, at index: Int = 0) {
        retreivalCompletions[index](error)
    }
    func completeRetrivalwithEmptyCache(at index: Int = 0) {
        retreivalCompletions[index](nil)
    }
}
