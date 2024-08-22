//
//  UINavigationController+Extensions.swift
//  ChatApp
//
//  Created by Duc on 23/8/24.
//

import UIKit

extension UINavigationController {
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // hide back button text
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}
