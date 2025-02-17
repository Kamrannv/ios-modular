//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 17.02.25.
//

import XCTest

class FeedStore {
    var deletedCachFeedCallCount = 0
}

class LocalFeedLoader {
    init(store: FeedStore) {
        
    }
}
final class CacheFeedUseCaseTests: XCTestCase {

    func test_doesNotDeleteCacheUponInitialization() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deletedCachFeedCallCount, 0)
    }

}
