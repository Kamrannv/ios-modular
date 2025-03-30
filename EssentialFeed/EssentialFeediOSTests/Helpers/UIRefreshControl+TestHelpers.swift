//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
