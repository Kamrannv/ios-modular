//
//  UIButton+TestHelpers.swift
//  EssentialFeed
//
//  Created by Kamran on 30.03.25.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
