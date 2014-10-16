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
var conflicts:Int!
    
    init(n:Int, maxSteps:Int) {
        self.n = n
        self.maxSteps = maxSteps

        columns = [Int(arc4random_uniform(UInt32(n)))]
        for var index = 1; index < n; ++index {
            let random = Int(arc4random_uniform(UInt32(n)))
            columns.append(random)
        }
self.conflicts = initialConflictCounter()
    }
    
    func minConflicts()-> Bool{
        println("Current Random Assignment" + columns.description)
        
         println("Current Conflicts" + self.conflicts.description)
     
        for var index = 0; index < self.maxSteps; ++index {
            //First check if current assignment is solution
            if solution(){
                return true
            }
            
            let column =  Int(arc4random_uniform(UInt32(n)))
            
            self.columns[column] = conflicts(column)
            
            
        }
        
        return false
    }
    
    
    func conflicts(variable:Int)-> Int{

        
        return 4
        
    }
    
    
    
    func solution()-> Bool{
              if self.conflicts == 0 {
            return true

                    }
        
        return false
        
    }

func initialConflictCounter()-> Int{
            var totalConflicts = 0
 for var index = 0; index < self.columns.count; ++index {
    
    
           for var nextIndex = index+1; nextIndex < self.columns.count; ++nextIndex {

            
            if  self.columns[index] == self.columns[nextIndex] {
                totalConflicts++
            }
            if self.columns[nextIndex] ==  (self.columns[index] + (nextIndex-index)){
                totalConflicts++
            }
            if self.columns[nextIndex] ==  (self.columns[index] - (nextIndex-index)){
                totalConflicts++
            }
    }
}
    
 
        return totalConflicts
    }
    
    
}
//


//and accumulate positions



//Check diagnlos

//What about dynamic programming

//Multi Threading go in each direction and diagnal