//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//
import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController{
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader){
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}
final class FeedViewControllerTests: XCTestCase {
    func testExample() throws {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCallCount,1)
    }
    
    class LoaderSpy: FeedLoader {
      
        private(set) var loadCallCount: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
        
    }
}

