//
//  Algorithm.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Ruben on 10/19/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation

enum Algorithm {
    case Vanilla, Random, Greedy
}

//extensions for the Int class
extension Int {
    //generates a random number from 0 to n exclusive; wrapper for arc4random_uniform to aid readability
    static func random(n : Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
}

extension Float {
    //generates a random float from 0 to 1; wrapper for arc4random_uniform to aid readability
    static func random() -> Float {
        return Float(arc4random()) / Float(UINT32_MAX)
    }
}