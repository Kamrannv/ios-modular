//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 17.02.25.
//

import XCTest
import EssentialFeed

//MARK: Production code
class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    init(store: FeedStore, currentDate: @escaping () -> Date = Date.init) {
        self.store = store
        self.currentDate = currentDate
    }
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
    
}

class FeedStore {
    typealias DeletionCompletion = (Error?)->Void
    typealias InsertionCompletion = (Error?) -> Void
    
    enum ReceivedMessage: Equatable {
        case deletedCachedFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    
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
    func insert(_ items: [FeedItem], timeStamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timeStamp))
    }
    func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompletions[index](error)
        }
    func completeInsertionSuccessfully(at index: Int = 0) {
            insertionCompletions[index](nil)
        }
}



//MARK: TEST
final class CacheFeedUseCaseTests: XCTestCase {

    func test_doesNotMessageStoreUponInitialization() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_saveRequestsDeletionOfCache() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed])
    }
    

    
    func test_save_requestsCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed, .insert(items, timeStamp)])
    }
    
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        let exp = expectation(description: "Wait for completion")
        var receivedError: Error?
        sut.save(items) { err in
            receivedError = err
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed])
    }
    
    func test_save_failsOnInsertionError() {
            let items = [uniqueItem(), uniqueItem()]
            let (sut, store) = makeSUT()
            let insertionError = anyNSError()
            let exp = expectation(description: "Wait for save completion")

            var receivedError: Error?
            sut.save(items) { error in
                receivedError = error
                exp.fulfill()
            }

            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
            wait(for: [exp], timeout: 1.0)

            XCTAssertEqual(receivedError as NSError?, insertionError)
        }
    func test_save_succeedsOnSuccessfulCacheInsertion() {
            let items = [uniqueItem(), uniqueItem()]
            let (sut, store) = makeSUT()
            let exp = expectation(description: "Wait for save completion")

            var receivedError: Error?
            sut.save(items) { error in
                receivedError = error
                exp.fulfill()
            }

            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
            wait(for: [exp], timeout: 1.0)

            XCTAssertNil(receivedError)
        }
    
    //MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut: LocalFeedLoader = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem () -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURl())
    }

    private func anyURl()->URL {
        return URL(string: "http://url.com")!
    }
    private func anyNSError()->NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
}
