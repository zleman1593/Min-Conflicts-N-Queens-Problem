//
//  algorithms.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery Leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

//TODO When ties are broken randomly, the probability that the next best lower row will be choosen is cut in half. We dont want this. Shoudl have equal chance of being picked

import Foundation

class MinConflicts {
    //Number of rows and Columns
    var n : Int? = nil
    //Number of steps to find solution
    var maxSteps  : Int?  = nil
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
            //picks a column with conflicts at random
            let columnsWithConflicts = allConflicts.keys.array
            var column = columnsWithConflicts[Int.random(columnsWithConflicts.count)]
            
            switch algorithm {
            case Algorithm.Vanilla:
                
                
                //only choose from set of conflicted currentSelectedColumns
                
                
                
                //set queen in the random column to row that minimizes conflicts
                self.columns[column] = self.findLeastConflictedRowForQueenToMoveToFrom(column, updateRunnningConflicts: true).bestRow
            case Algorithm.Random:
                //choose a random column
                if Int.random(3) != 0 {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.findLeastConflictedRowForQueenToMoveToFrom(column, updateRunnningConflicts: true).bestRow
                } else {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.randomPlacement(column)
                }
                
            case Algorithm.Greedy:
                var bestQueen = 0
                var bestConflicts = Int.max
                var moveQueenTo = 0
                for index in self.columns{
                    let result = self.findLeastConflictedRowForQueenToMoveToFrom(index, updateRunnningConflicts: false)
                    
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
                //Removes all old conflicts involving the old position
                //removeOldConflicts()
            }
        }
        
        //Return that it had to give up
        return false
    }
    
    //Input: Column; Output: Least-conflicted row for queen in column
    func findLeastConflictedRowForQueenToMoveToFrom(currentSelectedColumn : Int, updateRunnningConflicts: Bool) -> (bestRow:Int,conflicts:Int) {
        //This holds all the possible conflicts for each possible move to a new row
        var conflictStore : [Array<Int>] = []
        //Keeps track of the best moves so far
        var bestMove : [Int] = []
        //The number of conflicts the current row position is involved in
        var currentPositionConflicts = 0
        // keeps track of the minimum number of conflicts for the best new move so far
        var minConflicts = Int.max
        
        //loop through rows & columns
        for row in 0..<self.columns.count {
            var currentMoveConflicts = 0
            //Array to hold the conflicts for this row choice. Last element will be the column number (Added later)
            var currentPossibleConflicts : Array<Int> = []
            for column in 0..<self.columns.count {
                //skip conflict with self
                if column != currentSelectedColumn {
                    //Looks across row
                    if self.columns[column] == row {
                        currentMoveConflicts++
                        
                        currentPossibleConflicts.append(column)
                    }
                        //Looks at up and down diagnals
                    else if self.columns[column] == (row + (currentSelectedColumn-column)) {
                        currentMoveConflicts++
                        currentPossibleConflicts.append(column)
                    }
                    else if self.columns[column] == (row - (currentSelectedColumn-column)) {
                        currentMoveConflicts++
                        currentPossibleConflicts.append(column)
                    }
                    
                }
            }
            
            //Makes the last element in the array the Initial column number. Important for later.
            if currentPossibleConflicts.count != 0 {
                currentPossibleConflicts.append(currentSelectedColumn)
            }
            
            //Adds array holding conflict information for potential moves
            conflictStore.append(currentPossibleConflicts)
            
            /* If row being looked at is the row that the queen in the current column currently occupies,
            * set currentPositionConflicts to the number of conflicts this queen is curently involved in.
            */
            if row == self.columns[currentSelectedColumn] {
                currentPositionConflicts = currentMoveConflicts
            }
            /* If the row being looked at does not have the queen from the current column,
            * update the best move if the move would result in fewer conflicts
            */
            /*This needs to be an if to allow queen to state in the current optimal state. Make an else if you want to force it to move. But that would reduce performance drastically.*/
            if minConflicts > currentMoveConflicts {
                
                
                minConflicts = currentMoveConflicts
                bestMove = [row]
                
                // Replace the array with a new array filled with the data from this move
                
            }
            else if minConflicts == currentMoveConflicts {
                //Add to the current array
                bestMove.append(row)
                
            }
        }
        
        //Breaks ties randomly from the best options
        let bestMoveFromSelection = Int.random(bestMove.count)
        
        
        if bestMoveFromSelection != self.columns[currentSelectedColumn] && updateRunnningConflicts {
            //Keeps the number of conflicts updated after a move is made
            self.conflicts += (minConflicts - currentPositionConflicts)
            //Removes all old conflicts involving the old position
            removeOldConflicts(currentSelectedColumn)
            //Adds all the new conflicts if there are any
            if minConflicts != 0 {
                addConflictFromNewMove(conflictStore[bestMoveFromSelection])
            }
        }
        
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        //Returns the number of conflicts that will be reduced upon making this move
        return (bestMoveFromSelection,minConflicts - currentPositionConflicts)
    }
    
    //Input: Column; Output: A random row for queen in column
    func randomPlacement(currentSelectedColumn : Int) -> Int {
        var minConflicts = 0
        //This holds all the possible conflicts for each possible move to a new row
        var conflictStore : [Array<Int>] = []
        let nextRow = Int.random(self.n!) //or +1 ?
        var currentPositionConflicts = 0
        var nextMoveConflicts = 0
        //Array to hold the conflicts for this row choice. Last element will be the column number (Added later)
        var currentPossibleConflicts : Array<Int> = []
        //loop through columns
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != currentSelectedColumn{
                //Looks across row
                if self.columns[column] == nextRow {
                    nextMoveConflicts++
                    currentPossibleConflicts.append(column)
                }
                //Looks at up and down diagnals
                if self.columns[column] == (nextRow + (currentSelectedColumn-column)) {
                    nextMoveConflicts++
                    currentPossibleConflicts.append(column)
                }
                if self.columns[column] == (nextRow - (currentSelectedColumn-column)) {
                    nextMoveConflicts++
                    currentPossibleConflicts.append(column)
                }
            }
        }
        //Makes the last element in the array the Initial column number. Important for later.
        if currentPossibleConflicts.count != 0 {
            currentPossibleConflicts.append(currentSelectedColumn)
        }
        //Adds array holding conflict information for potential moves
        conflictStore.append(currentPossibleConflicts)
        
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != currentSelectedColumn{
                //Looks across row
                if self.columns[column] == self.columns[currentSelectedColumn] {
                    currentPositionConflicts++
                }
                //Looks at up and down diagnals
                if self.columns[column] ==  (self.columns[currentSelectedColumn] + (currentSelectedColumn-column)) {
                    currentPositionConflicts++
                }
                if self.columns[column] ==  (self.columns[currentSelectedColumn] - (currentSelectedColumn-column)) {
                    currentPositionConflicts++
                }
            }
        }
        
        //Makes the last element in the array the Initial column number. Important for later.
        if currentPossibleConflicts.count != 0 {
            currentPossibleConflicts.append(currentSelectedColumn)
        }
        
        //Adds array holding conflict information for potential moves
        conflictStore.append(currentPossibleConflicts)
        
        
        //Keeps the number of conflicts updated after a move is made
        if nextRow != self.columns[currentSelectedColumn] {
            self.conflicts = self.conflicts + (nextMoveConflicts - currentPositionConflicts)
            //Removes all old conflicts involving the old position
            removeOldConflicts(currentSelectedColumn)
            //Adds all the new conflicts if there are any
            /*  if minConflicts != 0 {
            addConflictFromNewMove(conflictStore[bestMove])
            }*/
            
        }
        
        //Returns new row for queen to occupy
        return nextRow
    }
    
    //Are we at a solution?
    //Output: true if no more conflicts, else false
    func isSolution() -> Bool {
        return self.conflicts == 0
    }
    
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
                    addConflicts(index, columnB: nextIndex)
                }
                    //Looks at up and down diagnals
                else if self.columns[nextIndex] == (self.columns[index] + (nextIndex-index)) {
                    totalConflicts++
                    addConflicts(index, columnB: nextIndex)
                }
                else if self.columns[nextIndex] == (self.columns[index] - (nextIndex-index)) {
                    totalConflicts++
                    addConflicts(index, columnB: nextIndex)
                }
            }
        }
        
        return totalConflicts
    }
    
    /*Adds the conflicts to the global conflict store*/
    func addConflicts(columnA : Int, columnB : Int) {
        
        if allConflicts[columnA]? != nil {
            allConflicts[columnA]!.addObject(columnB)
        } else {
            allConflicts[columnA] = NSMutableArray(array: [columnB])
        }
        
        if allConflicts[columnB]? != nil {
            allConflicts[columnB]!.addObject(columnA)
        } else {
            allConflicts[columnB] = NSMutableArray(array: [columnA])
        }
    }
    
    /*Adds the conflicts that where generated by the move*/
    func addConflictFromNewMove(conflicts : [Int]) {
        var conflicts2 = conflicts
        //Gets the main column from the last element
        let mainColumn = conflicts2.removeLast()
        if conflicts2.count != 1 {
            for columns in conflicts2 {
                //why is this saftey line needed?
                self.addConflicts(mainColumn,columnB: conflicts2[columns])
            }
        } else {
            self.addConflicts(mainColumn,columnB: conflicts2[0])
        }
    }
    
    func removeOldConflicts(column : Int) {
        //Run through all the conflicts and go to those columns and remove this column from these other columns
        if allConflicts[column]? != nil {
            for columnB in 0..<allConflicts[column]!.count {
                allConflicts[columnB]?.removeObject(column)
            }
        }
        
        //Then remove conflicts for column
        allConflicts.removeValueForKey(column)
    }
}