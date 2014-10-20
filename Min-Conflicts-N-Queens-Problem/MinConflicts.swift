//
//  algorithms.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery Leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation

class MinConflicts {
    //Number of rows and Columns
    var n : Int? = nil
    //Number of steps to find solution
    var maxSteps  : Int? = nil
    //Number of steps actually used to find solution
    var stepsUsed : Int   = 0
    //Number of current conflicts
    var conflicts : Int   = 0
    //Array of columns, where an element holds the row the queen in that column occupies
    var columns   : [Int] = []
    //stores all conflicts in board
    var allConflicts = [Int : NSMutableArray]()
    
    func randomlyPopulateBoardOfSize(n : Int) {
        self.n = n
        
        //initialize n columns with random values
        for index in 1...n {
            let rand = Int.random(n)
            columns.append(rand)
        }
    }
    
    /*So user can select where queens should start*/
    func updateColumn(column : Int, row : Int) {
        self.columns[column] = row
    }
    
    //minConflicts board configuration.
    //Output: true if solution found within maxSteps, else false
    func minConflicts(algorithm: Algorithm) -> Bool {
        //count initial number of conflicts
        self.conflicts = initialConflictCounter()
        println("Current Random Assignment " + columns.description)
        println("Current Conflicts " + self.conflicts.description)
        
        for index in 1...self.maxSteps! {
            //check if current assignment is solution
            if self.isSolution() {
                self.stepsUsed = index
                return true
            }
            
            switch algorithm {
            case Algorithm.Vanilla:
                //choose a random column
                let column = Int.random(self.n!)
                //set queen in the random column to row that minimizes conflicts
                self.columns[column] = self.conflicts(column, updateRunnningConflicts: true).bestRow
            case Algorithm.Random:
                //choose a random column
                let column = Int.random(self.n!)
                if Int.random(3) != 0 {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.conflicts(column, updateRunnningConflicts: true).bestRow
                } else {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.randomPlacement(column)
                }
                
            case Algorithm.Greedy:
                var bestQueen = 0
                var bestConflicts = Int.max
                var moveQueenTo = 0
                for index in self.columns{
                    let result = self.conflicts(index, updateRunnningConflicts: false)
                    
                    if result.conflicts < bestConflicts {
                        bestConflicts = result.conflicts
                        bestQueen = index
                        moveQueenTo = result.bestRow
                    } else if result.conflicts == bestConflicts {
                        let randomNumber = Int.random(2)
                        if randomNumber == 1{
                            bestConflicts = result.conflicts
                            bestQueen = index
                            moveQueenTo = result.bestRow
                        }
                        
                    }
                }
                
                //set queen in the random column to row that minimizes conflicts
                self.columns[bestQueen] = moveQueenTo
                self.conflicts = self.conflicts + bestConflicts
            }
        }
        
        //return that it had to give up
        return false
    }
    
    //Input: Column; Output: Least-conflicted row for queen in column
    func conflicts(variable : Int, updateRunnningConflicts: Bool) -> (bestRow:Int,conflicts:Int) {
        var bestMove = 0
        var currentPositionConflicts = 0
        var minConflicts = Int.max
        
        //loop through rows & columns
        for row in 0..<self.columns.count {
            var currentMoveConflicts = 0
            for column in 0..<self.columns.count {
                //skip conflict with self
                if column != variable {
                    //Looks across row
                    if self.columns[column] == row {
                        currentMoveConflicts++
                    }
                        //Looks at up and down diagnals
                    else if self.columns[column] ==  (row + (variable-column)) {
                        currentMoveConflicts++
                    }
                    else if self.columns[column] ==  (row - (variable-column)) {
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
                /*  If the row being looked at does not have the queen from the current column,
                * update the best move if the move would result in fewer conflicts
                */
                /*This needs to be an if to allow queen to state in the current optimal state. Make an else if you want to force it to move. But that would reduce performance drastically.*/
            if minConflicts > currentMoveConflicts {
                minConflicts = currentMoveConflicts
                bestMove = row
            }//Breaks Ties randomly
            else if minConflicts == currentMoveConflicts {
                let randomNumber = Int.random(2)
                if randomNumber == 1 {
                    minConflicts = currentMoveConflicts
                    bestMove = row
                }
            }
            
            
        }
        
        //Keeps the number of conflicts updated after a move is made
        if bestMove != self.columns[variable] && updateRunnningConflicts {
            self.conflicts += (minConflicts - currentPositionConflicts)
        }
        
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        //Returns the number of conflicts that will be reduced upon making this move-----------------This is different then what doc specifies
        return (bestMove,minConflicts - currentPositionConflicts)
    }
    
    
    //Input: Column; Output: A random row for queen in column
    func randomPlacement(variable : Int) -> Int {
        let nextRow = Int.random(self.n!)//or +1 ?
        var currentPositionConflicts = 0
        var nextMoveConflicts = 0
        
        //loop through columns
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != variable{
                //Looks across row
                if self.columns[column] == nextRow {
                    nextMoveConflicts++
                }
                //Looks at up and down diagnals
                if self.columns[column] == (nextRow + (variable-column)) {
                    nextMoveConflicts++
                }
                if self.columns[column] == (nextRow - (variable-column)) {
                    nextMoveConflicts++
                }
            }
        }
        
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != variable{
                //Looks across row
                if self.columns[column] == self.columns[variable] {
                    currentPositionConflicts++
                }
                //Looks at up and down diagnals
                if self.columns[column] ==  (self.columns[variable] + (variable-column)) {
                    currentPositionConflicts++
                }
                if self.columns[column] ==  (self.columns[variable] - (variable-column)) {
                    currentPositionConflicts++
                }
            }
        }
        
        //Keeps the number of conflicts updated after a move is made
        if nextRow != self.columns[variable] {
            self.conflicts = self.conflicts + (nextMoveConflicts - currentPositionConflicts)
        }
        
        //Returns new row for queen to occupy
        return nextRow
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
                    addConflict(index, columnB: nextIndex)
                }
                //Looks at up and down diagnals
                else if self.columns[nextIndex] == (self.columns[index] + (nextIndex-index)) {
                    totalConflicts++
                    addConflict(index, columnB: nextIndex)
                }
                else if self.columns[nextIndex] == (self.columns[index] - (nextIndex-index)) {
                    totalConflicts++
                    addConflict(index, columnB: nextIndex)
                }
            }
        }
        
        return totalConflicts
    }
    
    func addConflict(columnA : Int, columnB : Int) {
        if (allConflicts[columnA]? != nil) {
            allConflicts[columnA]!.addObject(columnB)
        } else {
            allConflicts[columnA] = NSMutableArray(array: [columnB])
        }
    }
    
    func resolveConflict(columnA : Int, columnB : Int) {
        allConflicts[columnA]?.removeObject(columnB)
    }
}