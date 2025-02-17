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
    
    init(store: FeedStore) {
        self.store = store
    }
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
    
}

class FeedStore {
    typealias DeletionError = (Error?)->Void
    var deletedCachFeedCallCount = 0
    var insertCallCount = 0
    private var deletionCompletions = [DeletionError]()
    
    func deleteCachedFeed(completion: @escaping DeletionError) {
        deletedCachFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index:Int = 0) {
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0) {
        deletionCompletions[index](nil)
    }
    func insert(_ items: [FeedItem]) {
        insertCallCount+=1
    }
}



//MARK: TEST
final class CacheFeedUseCaseTests: XCTestCase {

    func test_doesNotDeleteCacheUponInitialization() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deletedCachFeedCallCount, 0)
    }
    
    func test_saveRequestsDeletionOfCache() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deletedCachFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    
    func test_save_requestsCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertCallCount, 1)
    }
    //MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut: LocalFeedLoader = LocalFeedLoader(store: store)
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
