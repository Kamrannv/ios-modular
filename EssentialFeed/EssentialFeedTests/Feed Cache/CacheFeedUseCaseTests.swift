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
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timeStamp: self.currentDate())
            }
        }
    }
    
}

class FeedStore {
    typealias DeletionError = (Error?)->Void
   
    
    enum ReceivedMessage: Equatable {
        case deletedCachedFeed
        case insert([FeedItem], Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionError]()
    
    func deleteCachedFeed(completion: @escaping DeletionError) {
       
        deletionCompletions.append(completion)
        receivedMessages.append(.deletedCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index:Int = 0) {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](nil)
    }
    func insert(_ items: [FeedItem], timeStamp: Date) {
       
        receivedMessages.append(.insert(items, timeStamp))
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
        sut.save(items)
        
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed])
    }
    

    
    func test_save_requestsCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deletedCachedFeed, .insert(items, timeStamp)])
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
