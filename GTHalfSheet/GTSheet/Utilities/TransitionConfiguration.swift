//
//  TransitionConfiguration.swift
//  GTSheet
//
//  Created by Matt Banach on 12/6/17.
//  Copyright © 2017 Gametime. All rights reserved.
//

import Foundation

struct TransitionConfiguration {

    struct Presentation {
        static var duration: TimeInterval = 0.25
    }

    struct Dismissal {
        static var duration: TimeInterval = 0.25
        static var dismissBreakpoint: CGFloat = 100.0
    }
}
