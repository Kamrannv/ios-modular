//
//  FeedViewControllerTests.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//
import XCTest
import UIKit

final class FeedViewController: UIViewController{
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy){
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}
final class FeedViewControllerTests: XCTestCase {
    func testExample() throws {
        let loaderSpy = LoaderSpy()
        let sut = FeedViewController(loader: loaderSpy)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loaderSpy.loadCallCount,1)
    }
    
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
        
        func load() {
            loadCallCount += 1
        }
    }
}

