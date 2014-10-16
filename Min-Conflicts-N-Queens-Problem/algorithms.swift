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
            //selects a random column
            let column =  Int(arc4random_uniform(UInt32(n)))
            //sets the queen in the selected column to the row that creates the fewest conflicts
            self.columns[column] = conflicts(column)
            
        }
        
        //return that it had to give up
        return false
    }
    
    
    //TODO MultiThread this?
    // The Bug is in this method.
    func conflicts(variable:Int)-> Int{
        
        var bestMove = 0
        var currentPositionConflicts = 0
        var minConflicts = Int.max
        
        
        for var row = 0; row < self.columns.count; ++columnAndRows {
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
            /*If the row being looked at is the row that the queen in the current column  currently occupies
            then set currentPositionConflicts to the number of conflicts this queen is curently involved in.
            */
            if row == self.columns[variable]{
                currentPositionConflicts = currentMoveConflicts
                
            }/*Else if the row being looked at does not have the queen from the current column,
            *update the best move if the move would result in fewer conflicts*/
            else if minConflicts >= currentMoveConflicts{
                minConflicts = currentMoveConflicts
                bestMove = columnAndRows
            }
            
        }
        
        //Keeps the number of conflicts updated after a move is made
        if bestMove != self.columns[variable]{
            self.conflicts = self.conflicts + (minConflicts - currentPositionConflicts)
        }
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        return bestMove
    }
    
    
    
    func solution()-> Bool{
        if self.conflicts == 0 {
            return true
        }
        return false
    }
    
    //TODO MultiThread this?
    /*Counts the number of conflicts created from the initial random assigmnet
   *so that the number of conflicts can quickly updated during runtime*/
    func initialConflictCounter()-> Int{
        var totalConflicts = 0
        for var index = 0; index < self.columns.count; ++index {
            for var nextIndex = index+1; nextIndex < self.columns.count; ++nextIndex {
                //Looks across row
                if  self.columns[index] == self.columns[nextIndex] {
                    totalConflicts++
                }
                //Looks at up and down diagnals
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
