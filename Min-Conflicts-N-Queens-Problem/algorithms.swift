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
    
    
    //TODO MultiThread this?
    // The Bug is in this method.
    func conflicts(variable:Int)-> Int{
        
        var bestMove = 0
        var currentPositionConflicts = 0
        var minConflicts = Int.max
        
        
        for var columnAndRows = 0; columnAndRows < self.columns.count; ++columnAndRows {
            var  currentMoveConflicts = 0
            for var index = 0; index < self.columns.count; ++index {
                
                //skip conflict with self
                if index != variable{
                    
                    for var index = 0; index < self.columns.count; ++index {
                        if  self.columns[index] == self.columns[variable] {
                            currentMoveConflicts++
                        }
                        if self.columns[index] ==  (self.columns[variable] + (variable-index)){
                            currentMoveConflicts++
                        }
                        if self.columns[index] ==  (self.columns[variable] - (variable-index)){
                            currentMoveConflicts++
                        }
                    }
                    
                }
                
            }
            if columnAndRows == self.columns[variable]{
                currentPositionConflicts = currentMoveConflicts
                
            }else if minConflicts >= currentMoveConflicts{
                minConflicts = currentMoveConflicts
                bestMove = columnAndRows
            }
            
        }
        
        //Keeps the number of conflicts updated
        if bestMove != self.columns[variable]{
            self.conflicts = self.conflicts + (minConflicts - currentPositionConflicts)
        }
        
        return bestMove
        
    }
    
    
    
    func solution()-> Bool{
        if self.conflicts == 0 {
            return true
            
        }
        
        return false
        
    }
    //TODO MultiThread this?
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
