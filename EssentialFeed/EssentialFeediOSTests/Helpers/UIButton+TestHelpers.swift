//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
