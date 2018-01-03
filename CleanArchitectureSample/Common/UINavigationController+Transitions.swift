//
//  UINavigationController+Transitions.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 1/1/18.
//  Copyright © 2018 Tyler Casselman. All rights reserved.
//

import UIKit

extension UINavigationController {
    func push(viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        pushViewController(viewController, animated: animated)
        handle(completion: completion, animated: animated)
    }
    
    func pop(animated: Bool, completion: (() -> ())?) {
        popViewController(animated: animated)
        handle(completion: completion, animated: animated)
    }
    
    private func handle(completion: (() -> ())?, animated: Bool) {
        guard animated, let coordinator = transitionCoordinator else {
            completion?()
            return
        }
        coordinator.animate(alongsideTransition: nil) { _ in
            completion?()
        }
    }
}
