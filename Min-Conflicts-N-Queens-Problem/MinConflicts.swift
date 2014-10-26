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
    var maxSteps  : Int?  = nil
    //Number of steps actually used to find solution
    var stepsUsed : Int   = 0
    //Number of current conflicts
    var conflicts : Int   = 0
    //Array of columns, where an element holds the row the queen in that column occupies
    var columns   : [Int] = []
    //Stores all conflicts in board
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
        
        //Count initial number of conflicts
        self.conflicts = initialConflictCounter()
        println("Current Random Assignment " + columns.description)
        println("Current Conflicts " + self.conflicts.description)
        
        //On Each step
        for index in 1...self.maxSteps! {
            
            //Check if current assignment is solution
            if self.isSolution() {
                self.stepsUsed = index
                return true
            }
            
            if  self.conflicts <= 0 {
                println("Fail")
            }
            
           
            switch algorithm {
            case Algorithm.Vanilla:
                //Picks a column with conflicts at random
                let columnsWithConflicts = allConflicts.keys.array
                //Picks a column with conflicts at random
                 var column = columnsWithConflicts[Int.random(columnsWithConflicts.count)]

                //Set queen in the random column to row that minimizes conflicts
                self.columns[column] = self.findLeastConflictedRowForQueenToMoveToFrom(column, updateRunnningConflicts: true).bestRow
                
            case Algorithm.Random:
                //Picks a column with conflicts at random
                let columnsWithConflicts = allConflicts.keys.array
                 var column = columnsWithConflicts[Int.random(columnsWithConflicts.count)]
                //choose a random column
                if Int.random(3) != 0 {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.findLeastConflictedRowForQueenToMoveToFrom(column, updateRunnningConflicts: true).bestRow
                } else {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.randomPlacement(column)
                }
                
            case Algorithm.Greedy:
                var bestQueen : [(selectedQueen: Int, row: Int, conflictStore: [Int : Array<Int>])] = []
                var bestConflicts = Int.max
                
                //For all queens see which queen will result in the largest conflict reduction
                for index in self.columns{

                    let nextMoveInfo = self.findLeastConflictedRowForQueenToMoveToFrom(index, updateRunnningConflicts: false)
                    
                    if nextMoveInfo.conflicts < bestConflicts {
                        bestConflicts = nextMoveInfo.conflicts
                        bestQueen = [(selectedQueen: index, row: nextMoveInfo.bestRow, conflictStore: nextMoveInfo.conflictStore)]
                        
                    } else if nextMoveInfo.conflicts == bestConflicts {
                        bestQueen.append(selectedQueen: index, row: nextMoveInfo.bestRow,conflictStore: nextMoveInfo.conflictStore)

                    }
                    
                }
                
                //Breaks ties randomly from the best options
                let queenToChoose = bestQueen[Int.random(bestQueen.count)]

                //set queen  to row that minimizes conflicts
                self.columns[queenToChoose.selectedQueen] = queenToChoose.row
                
                self.conflicts = self.conflicts + bestConflicts
                
                //Removes all old conflicts involving the old position
                removeOldConflicts(queenToChoose.selectedQueen)
                
                //Adds all the new conflicts if there are any
                if bestConflicts != 0 {
                    addConflictFromNewMove(queenToChoose.conflictStore[queenToChoose.row]!,mainColumn: queenToChoose.selectedQueen)
                }
            }
        }
        
        //Return that it had to give up
        return false
    }
    
    //Input: Currently Selected Column; Output: Least-conflicted row for queen in column
    func findLeastConflictedRowForQueenToMoveToFrom(currentSelectedColumn : Int, updateRunnningConflicts: Bool) -> (bestRow:Int,conflicts:Int,conflictStore : [Int : Array<Int>]) {
        
        
        //This holds all the possible conflicts for each  of the best possible moves to a new row
        var conflictStore = [Int : Array<Int>]()
        //Keeps track of the best moves (of equivalent conflicts)
        var bestMoves : [Int] = []
        
        /*nextMoveInfo contains:
        * minConflictsForBestMoves: Number of conflicts that will be generated due to move to new row position
        * conflictsFromRowBeforeMove: Current conflicts due to current row position
        * bestMoves: Array of equivalently best moves
        * conflictStore: Stores the conflicts for each of the best possible moves
        */
        let nextMoveInfo = leastConflictedSubRoutine(&conflictStore, bestMoves: &bestMoves, currentSelectedColumn: currentSelectedColumn)
        
        //Breaks ties randomly from the best options
        let moveToMake = bestMoves[Int.random(bestMoves.count)]
        
        //If the new position is different from current position update conflict information
        if moveToMake != self.columns[currentSelectedColumn] && updateRunnningConflicts {
            
            //Keeps the number of conflicts updated after a move is made
            self.conflicts += (nextMoveInfo.minConflictsForBestMoves - nextMoveInfo.conflictsFromRowBeforeMove)
            //Removes all old conflicts involving the old position
            removeOldConflicts(currentSelectedColumn)
            //Adds all the new conflicts if there are any
            if nextMoveInfo.minConflictsForBestMoves != 0 {
                addConflictFromNewMove(conflictStore[moveToMake]!,mainColumn: currentSelectedColumn)
            }
        }
        
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        //Returns the number of conflicts that will be reduced upon making this move
        return (moveToMake, nextMoveInfo.minConflictsForBestMoves - nextMoveInfo.conflictsFromRowBeforeMove,conflictStore)
    }
    
    /*Does the heavy lifiting for row conflict Identification
    *Note: First two parameters are passed by reference so that they do not need to be copied
    */
    func leastConflictedSubRoutine(inout conflictStore: [Int : Array<Int>], inout bestMoves : [Int] , currentSelectedColumn : Int)->(minConflictsForBestMoves: Int, conflictsFromRowBeforeMove : Int){
        
        //The number of conflicts the current row position is involved in
        var conflictsFromRowBeforeMove = 0
        // keeps track of the minimum number of conflicts for the best new moves so far
        var minConflictsForBestMoves = Int.max
        
        //Loop through all the columns for each row choice and get conflicts
        for row in 0..<self.columns.count {
            
            //Tracks the number of conflicts associated with this potential row change
            var currentPossibleConflicts = 0
            //Array to hold the conflicts for this row choice. Last element will be the column number (Added later)
            var enumeratedCurrentPossibleConflicts : Array<Int> = []
            
            for column in 0..<self.columns.count {
                
                //skip conflict with self
                if column != currentSelectedColumn {
                    
                    //Looks across row
                    if self.columns[column] == row {
                        currentPossibleConflicts++
                        enumeratedCurrentPossibleConflicts.append(column)
                    }
                        //Looks at up and down diagnals
                    else if self.columns[column] == (row + (currentSelectedColumn-column)) {
                        currentPossibleConflicts++
                        enumeratedCurrentPossibleConflicts.append(column)
                    }
                    else if self.columns[column] == (row - (currentSelectedColumn-column)) {
                        currentPossibleConflicts++
                        enumeratedCurrentPossibleConflicts.append(column)
                    }
                    
                }
            }
            
            
            /* If row being looked at is the row that the queen in the current column currently occupies,
            * set conflictsFromRowBeforeMove to the number of conflicts this queen is curently involved in*/
            if row == self.columns[currentSelectedColumn] {
                conflictsFromRowBeforeMove = currentPossibleConflicts
            }
            
            /* If the row being looked at does not have the queen from the current column,
            * update the best move if the move would nextMoveInfo in fewer conflicts
            */
            
            if minConflictsForBestMoves > currentPossibleConflicts {
                minConflictsForBestMoves = currentPossibleConflicts
                // Replace the array with this new move since it is better than the moves currently in the array
                bestMoves = [row]
                //Resets Array
                conflictStore = [row: enumeratedCurrentPossibleConflicts]
                
            }
            else if minConflictsForBestMoves == currentPossibleConflicts {
                //Add to the current array because the move has the same number of conflicts
                bestMoves.append(row)
                //Adds array holding conflict information for potential moves
                conflictStore.updateValue(enumeratedCurrentPossibleConflicts, forKey: row)
            }
            
        }
        return (minConflictsForBestMoves, conflictsFromRowBeforeMove)
    }
    
    
    //Input: Column; Output: A random row for queen in column
    func randomPlacement(currentSelectedColumn : Int) -> Int {
        var minConflictsForBestMoves = 0
        //This holds all the possible conflicts for each possible move to a new row
        var conflictStore : [Array<Int>] = []
        let nextRow = Int.random(self.n!) //or +1 ?
        var conflictsFromRowBeforeMove = 0
        var nextMoveConflicts = 0
        //Array to hold the conflicts for this row choice. Last element will be the column number (Added later)
        var enumeratedCurrentPossibleConflicts : Array<Int> = []
        //loop through columns
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != currentSelectedColumn{
                //Looks across row
                if self.columns[column] == nextRow {
                    nextMoveConflicts++
                    enumeratedCurrentPossibleConflicts.append(column)
                }
                //Looks at up and down diagnals
                if self.columns[column] == (nextRow + (currentSelectedColumn-column)) {
                    nextMoveConflicts++
                    enumeratedCurrentPossibleConflicts.append(column)
                }
                if self.columns[column] == (nextRow - (currentSelectedColumn-column)) {
                    nextMoveConflicts++
                    enumeratedCurrentPossibleConflicts.append(column)
                }
            }
        }
        //Makes the last element in the array the Initial column number. Important for later.
        if enumeratedCurrentPossibleConflicts.count != 0 {
            enumeratedCurrentPossibleConflicts.append(currentSelectedColumn)
        }
        //Adds array holding conflict information for potential moves
        conflictStore.append(enumeratedCurrentPossibleConflicts)
        
        for column in 0..<self.columns.count {
            //skip conflict with self
            if column != currentSelectedColumn{
                //Looks across row
                if self.columns[column] == self.columns[currentSelectedColumn] {
                    conflictsFromRowBeforeMove++
                }
                //Looks at up and down diagnals
                if self.columns[column] ==  (self.columns[currentSelectedColumn] + (currentSelectedColumn-column)) {
                    conflictsFromRowBeforeMove++
                }
                if self.columns[column] ==  (self.columns[currentSelectedColumn] - (currentSelectedColumn-column)) {
                    conflictsFromRowBeforeMove++
                }
            }
        }
        
        //Makes the last element in the array the Initial column number. Important for later.
        if enumeratedCurrentPossibleConflicts.count != 0 {
            enumeratedCurrentPossibleConflicts.append(currentSelectedColumn)
        }
        
        //Adds array holding conflict information for potential moves
        conflictStore.append(enumeratedCurrentPossibleConflicts)
        
        //Keeps the number of conflicts updated after a move is made
        if nextRow != self.columns[currentSelectedColumn] {
            self.conflicts = self.conflicts + (nextMoveConflicts - conflictsFromRowBeforeMove)
            //Removes all old conflicts involving the old position
            removeOldConflicts(currentSelectedColumn)
            //Adds all the new conflicts if there are any
            /*  if minConflictsForBestMoves != 0 {
            addConflictFromNewMove(conflictStore[bestMoves])
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
                    addConflictsBetweenTwoColumns(index, columnB: nextIndex)
                }
                    //Looks at up and down diagnals
                else if self.columns[nextIndex] == (self.columns[index] + (nextIndex-index)) {
                    totalConflicts++
                    addConflictsBetweenTwoColumns(index, columnB: nextIndex)
                }
                else if self.columns[nextIndex] == (self.columns[index] - (nextIndex-index)) {
                    totalConflicts++
                    addConflictsBetweenTwoColumns(index, columnB: nextIndex)
                }
            }
        }
        
        return totalConflicts
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
    
    
    /*Adds the conflicts that were generated by the move*/
    func addConflictFromNewMove(var conflicts : [Int], mainColumn : Int) {
        if conflicts.count != 1 {//Prevents bug in Swift Language
            for columns in conflicts {
                self.addConflictsBetweenTwoColumns(mainColumn,columnB: conflicts[columns])
            }
        } else {
            self.addConflictsBetweenTwoColumns(mainColumn,columnB: conflicts[0])
        }
    }
    
    /*Adds the conflicts between the two columns to the global conflict store*/
    func addConflictsBetweenTwoColumns(columnA : Int, columnB : Int) {
        
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
    
    
}