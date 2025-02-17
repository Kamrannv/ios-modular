//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 17.02.25.
//

import XCTest
import EssentialFeed

//MARK: Production code
class FeedStore {
    var deletedCachFeedCallCount = 0
    
    func deleteCachedFeed() {
        deletedCachFeedCallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

//MARK: TEST
final class CacheFeedUseCaseTests: XCTestCase {

    func test_doesNotDeleteCacheUponInitialization() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletedCachFeedCallCount, 0)
    }
    
    func test_saveRequestsDeletionOfCache() {
        let store = FeedStore()
        let sut: LocalFeedLoader = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)
        
        XCTAssertEqual(store.deletedCachFeedCallCount, 1)
    }
    
    //MARK: Helpers
    private func uniqueItem () -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURl())
    }

    private func anyURl()->URL {
        return URL(string: "http://url.com")!
    }
}
