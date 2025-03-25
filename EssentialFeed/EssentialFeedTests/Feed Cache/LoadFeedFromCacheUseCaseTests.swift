//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeed
//
//  Created by Kamran on 28.02.25.
//

import EssentialFeed
import XCTest

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_doesNotMessageStoreUponInitialization() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_RequestsCacheRestreival() {
        let (sut, store) = makeSUT()
        sut.load { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetreivalError(){
        let (sut, store) = makeSUT()
        let retrevialErr = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrevialErr), when: {
            store.completeRetrieval(with: retrevialErr)
        })
        
    }
    
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
        
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(feed.models), when: {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        })
    }
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            expect(sut, toCompleteWith: .success([]), when: {
                store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
            })
        }
    func test_load_hasNoSideEffectsOnRetrievalError() {

        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve ])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
            let (sut, store) = makeSUT()

            sut.validateCache()
            store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletedCachedFeed])
        }
    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnSevenDaysOldCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve ])
        }
    func test_load_hasNoSideEffectsOnMoreThanSevenDaysOldCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
            let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

            sut.load { _ in }
            store.completeRetrieval(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve ])
        }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let store = FeedStoreSpy()
            var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

            var receivedResults = [LocalFeedLoader.LoadResult]()
            sut?.load { receivedResults.append($0) }

            sut = nil
            store.completeRetrievalWithEmptyCache()

            XCTAssertTrue(receivedResults.isEmpty)
        }
    //MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,  file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut: LocalFeedLoader = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader,
                        toCompleteWith expectedResult: LocalFeedLoader.LoadResult,
                        when action: ()->Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file:file, line: line)
            case let (.failure(receivedErr as NSError), .failure(expectedErr as NSError)):
                XCTAssertEqual(receivedErr, expectedErr,  file:file, line: line)
            default:
                XCTFail("Expected result got \(expectedResult), for real result got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1)
    }
    
}

 
