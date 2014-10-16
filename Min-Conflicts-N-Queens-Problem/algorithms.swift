//
//  algorithms.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery Leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation

class minConflicts {
    //Number of rows and Columns
    let n : Int!
    //Number of steps to find solution
    let maxSteps  : Int!
    //Number of current conflicts
    var conflicts : Int!
    //Array of columns, where an element holds the row the queen in that column occupies
    var columns   : [Int] = []
    //Step where solution was found
    var solutionStep : Int?
    
    init(n : Int, maxSteps : Int) {
        self.n = n
        self.maxSteps = maxSteps
        
        //initialize n columns with random values
        for index in 1...n {
            let rand = Int.random(n)
            columns.append(rand)
        }
        
        //count initial number of conflicts
        self.conflicts = initialConflictCounter()
    }
    
    //minConflicts board configuration.
    //Output: true if solution found within maxSteps, else false
    func minConflicts()-> Bool {
        println("Current Random Assignment " + columns.description)
        println("Current Conflicts " + self.conflicts.description)
        
        for index in 1...self.maxSteps {
            //check if current assignment is solution
            if self.isSolution() {
                self.solutionStep = index
                return true
            }
            
            //choose a random column
            let column = Int.random(self.n)
            
            //set queen in the random column to row that minimizes conflicts
            self.columns[column] = self.conflicts(column)
        }
        
        //return that it had to give up
        return false
    }
    
    
    //TODO MultiThread this?

    //The Bug is in this method.
    //Input: Column; Output: Least-conflicted row for queen in column
    func conflicts(variable : Int) -> Int {

        var bestMove = 0
        var currentPositionConflicts = 0
        var minConflicts = Int.max
        
        //loop through rows & columns
        for row in 0..<self.columns.count {
            var currentMoveConflicts = 0
            for column in 0..<self.columns.count {
                //skip conflict with self
                if column != variable{
                    //Looks across row
                    if self.columns[column] == row {
                        currentMoveConflicts++
                    }
                    //Looks at up and down diagnals
                    if self.columns[column] ==  (row + (variable-column)) {
                        currentMoveConflicts++
                    }
                    if self.columns[column] ==  (row - (variable-column)) {
                        currentMoveConflicts++
                    }
                
                }
                
            }
            /* If row being looked at is the row that the queen in the current column currently occupies,
             * set currentPositionConflicts to the number of conflicts this queen is curently involved in.
             */
            if row == self.columns[variable] {
                currentPositionConflicts = currentMoveConflicts
                
            }
            /* Else if the row being looked at does not have the queen from the current column,
             * update the best move if the move would result in fewer conflicts
             */
            else if minConflicts >= currentMoveConflicts {
                minConflicts = currentMoveConflicts
                bestMove = row
            }
            
        }
        
        //Keeps the number of conflicts updated after a move is made
        if bestMove != self.columns[variable] {
            self.conflicts = self.conflicts + (minConflicts - currentPositionConflicts)
        }
        
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        return bestMove
    }
    
    //Are we at a solution?
    //Output: true if no more conflicts, else false
    func isSolution() -> Bool {
        return self.conflicts == 0
    }
    
    //TODO MultiThread this?
    /* Counts the number of conflicts created from the initial random assigmnet
     * so that the number of conflicts can quickly updated during runtime
     * Output: num conflicts in current board
     */
    func initialConflictCounter() -> Int {
        var totalConflicts = 0
        for index in 0..<self.columns.count {
            for nextIndex in index+1..<self.columns.count {
                //Looks across row
                if self.columns[index] == self.columns[nextIndex] {
                    totalConflicts++
                }
                //Looks at up and down diagnals
                if self.columns[nextIndex] ==  (self.columns[index] + (nextIndex-index)) {
                    totalConflicts++
                }
                if self.columns[nextIndex] ==  (self.columns[index] - (nextIndex-index)) {
                    totalConflicts++
                }
            }
        }
        
        return totalConflicts
    }
}

//extensions for the Int class
extension Int {
    //generates a random number from 0 to n exclusive; wrapper for arc4random_uniform to aid readability
    static func random(n : Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
}
