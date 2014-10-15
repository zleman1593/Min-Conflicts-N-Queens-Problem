//
//  algorithms.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation

class minConflicts {
    var columns:Array<Int>!
    let n:Int!
    let maxSteps:Int!
    
    init(n:Int, maxSteps:Int) {
        self.n = n
        self.maxSteps = maxSteps
        
        columns = [Int(arc4random_uniform(UInt32(n)))]
        for var index = 1; index < n; ++index {
            let random = UInt(arc4random_uniform(UInt32(n)))
            columns.append(Int(random))
        }
    }
    
    func minConflicts()-> Bool{
        println(columns.description)
        
        
     for var index = 0; index < self.maxSteps; ++index {
    
    }
        
         return false
    }
    
    
    func conflicts(variable:Int)-> Int{
        
        
        return 1
        
    }
    
    
    
}