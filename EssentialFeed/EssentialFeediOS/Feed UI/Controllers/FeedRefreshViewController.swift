//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
 
    @IBOutlet private var view: UIRefreshControl?
    private let delegate: FeedRefreshViewControllerDelegate
    
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @IBAction func refresh() {
        delegate.didRequestFeedRefresh()
    }
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
