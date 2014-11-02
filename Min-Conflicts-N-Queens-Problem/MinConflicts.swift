//
//  algorithms.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery Leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation

class MinConflicts {
    /* Parameters */
    //number of queens on board
    var n : Int? = nil
    //which algorithm to use
    var algorithm : Algorithm? = nil
    //picks first move better, or best move?
    var pickFirstBetter : Bool? = nil
    //% randomness in random algorithm
    var randomness : Float? = nil
    //number of runs allotted; must be 1 at minimum to run at all
    var maxRuns : Int? = nil
    //Number of steps to find solution
    var maxSteps : Int? = nil
    //Are we populating the board optimally?
    var optimally : Bool? = nil
    //Print Debug Messages to Console
    var debug = false
    
    /* Runtime Info */
    //number of runs used so far
    var runsUsed = 0
    //Number of steps actually used to find solution
    var stepsUsed : Int   = 0
    //Array of columns, where an element holds the row the queen in that column occupies
    var columns   : [Int] = []
    //Stores all conflicts in board
    var allConflicts = [Int : NSMutableArray]()
    //Tracks all the columns that still have conflicts, but shouldn't be looked at as there are no moves left for that column currently
    var columnsWithConflictsButNoBetterMovesAvalible = [Int : Int]()

    //sets queens on board to start
    //Input: n, the number of queens on the board; optimally, whether or not to place queens "optimally"
    func populateBoardOfSize(n : Int, optimally: Bool) {
        self.n = n
        self.optimally = optimally
        
        //initialize n columns with random values
        for index in 0..<n {
            let row = Int.random(n)
            columns.append(row)
            
            //find optimal position for queen at this column
            if optimally {
                let move = findLeastConflictedMoveForQueen(index, updateRunnningConflicts: false).bestRow
                columns[index] = move
                //resets conflict counters before starting
                columnsWithConflictsButNoBetterMovesAvalible.removeAll(keepCapacity: false)
                allConflicts.removeAll(keepCapacity: false)
            }
        }
        if debug {
            println("Finished board Setup and any Preprocessing.")
        }
    }
    
    //resets all algorithm data structures
    func resetBoard() {
        columns = []
        allConflicts.removeAll(keepCapacity: false)
        columnsWithConflictsButNoBetterMovesAvalible.removeAll(keepCapacity: false)
        populateBoardOfSize(n!, optimally: optimally!)
    }
    
    //sets algorithm parameters
    func prepareForRunWith(algorithm: Algorithm, maxRuns : Int, maxSteps : Int, randomness : Float, pickFirstBetter : Bool) {
        //set stage for algorithm on first run
        self.maxRuns = maxRuns
        self.maxSteps = maxSteps
        self.algorithm = algorithm
        self.randomness = randomness
        self.pickFirstBetter = pickFirstBetter
    }
    
    //Output: true if solution found within maxSteps, else false
    func run() -> Bool {
        //Count initial number of conflicts
        self.findInitialConflicts()
        
        if debug {
            println("Current Random Assignment " + columns.description)
        }
        
        //On Each step
        for index in 1...self.maxSteps!/self.maxRuns! {
            //Check if current assignment is solution
            if self.isSolution() {
                self.stepsUsed += index
                return true
            }
                        
            switch self.algorithm! {
            case Algorithm.Vanilla:
                //Picks a column with conflicts at random
                let column = findColumnWithConflicts()
                
                //Set queen in the random column to row that minimizes conflicts
                self.columns[column] = self.findLeastConflictedMoveForQueen(column, updateRunnningConflicts: true).bestRow
                
            case Algorithm.VanillaRestart:
                //Switches to vanilla once the  boolean variables to implement this variant has been set.
                //Removes one step which was just used to switch algorithm.
                self.algorithm = Algorithm.Vanilla
                self.stepsUsed = -1
                
            case Algorithm.VanillaChooseFirstBest:
                //Switches to vanilla once the  boolean variables to implement this variant has been set.
                //Removes one step which was just used to switch algorithm.
                self.algorithm = Algorithm.Vanilla
                 self.stepsUsed = -1

            case Algorithm.Random:
                //Picks a column with conflicts at random
                let column = findColumnWithConflicts()
                
                //choose a random column
                if Float.random() >= self.randomness {
                    //set queen in the random column to row that minimizes conflicts
                    self.columns[column] = self.findLeastConflictedMoveForQueen(column, updateRunnningConflicts: true).bestRow
                } else {
                    //set queen in the random column to a random row 
                    self.columns[column] = self.randomPlacement(column)
                }
                
            case Algorithm.Greedy:
                var bestQueen : [(selectedQueen: Int, row: Int, conflictStore: [Int : [Int]])] = []
                var bestConflicts = Int.max
                
                //For all queens see which queen will result in the largest conflict reduction
                for index in self.columns {
                    if columnsWithConflictsButNoBetterMovesAvalible[index] == nil {
                        let nextMoveInfo = self.findLeastConflictedMoveForQueen(index, updateRunnningConflicts: false)
                        
                        if nextMoveInfo.conflicts < bestConflicts {
                            bestConflicts = nextMoveInfo.conflicts
                            bestQueen = [(selectedQueen: index, row: nextMoveInfo.bestRow, conflictStore: nextMoveInfo.conflictStore)]
                            
                        } else if nextMoveInfo.conflicts == bestConflicts {
                            bestQueen.append(selectedQueen: index, row: nextMoveInfo.bestRow,conflictStore: nextMoveInfo.conflictStore)
                            
                        }
                    }
                }
                
                //Breaks ties randomly from the best options
                let queenToChoose = bestQueen[Int.random(bestQueen.count)]
                
                //set queen  to row that minimizes conflicts
                self.columns[queenToChoose.selectedQueen] = queenToChoose.row
                
                //update conflicts for new move
                updateColumn(queenToChoose.selectedQueen, withConflicts: queenToChoose.conflictStore[queenToChoose.row])
            }
        }
        
        self.runsUsed++ //increment runs
        //check if we should run again
        if self.runsUsed < self.maxRuns! {
            self.resetBoard()
            if self.debug {
                println("Starting New Run: \(self.runsUsed + 1 )")
            }
            return self.run()
        }
        
        //Return that it had to give up
        return false
    }
    
    //Input: Currently Selected Column; Output: Least-conflicted row for queen in column
    func findLeastConflictedMoveForQueen(currentSelectedColumn : Int, updateRunnningConflicts: Bool) -> (bestRow : Int, conflicts : Int, conflictStore : [Int : [Int]]) {
        /*These two variables are declared and initialized in this method,
        *passed by reference to the subRoutine (where they are modified), and then accessed at the end of this method*/
        //This holds all the possible conflicts for each  of the best possible moves to a new row
        var conflictStore = [Int : [Int]]()
        //Keeps track of the best moves (of equivalent conflicts)
        var bestMoves : [Int] = []
        
        /*nextMoveInfo contains:
        * minConflictsForBestMoves: Number of conflicts that will be generated due to move to new row position
        * conflictsFromRowBeforeMove: Current conflicts due to current row position
        * bestMoves: Array of equivalently best moves
        * conflictStore: Stores the conflicts for each of the best possible moves
        */
        var nextMoveInfo = bestMovesForQueen(&conflictStore, bestMoves: &bestMoves, currentSelectedColumn: currentSelectedColumn)
        
        if self.algorithm != Algorithm.Greedy && bestMoves.count == 1 {
            //Indicates column cannot be updated until a conflict with it changes
            columnsWithConflictsButNoBetterMovesAvalible.updateValue(currentSelectedColumn, forKey: currentSelectedColumn)
        }
        
        //Breaks ties randomly from the best options
        let moveToMake = bestMoves[Int.random(bestMoves.count)]
        
        //If the new position is different from current position update conflict information
        if updateRunnningConflicts && moveToMake != self.columns[currentSelectedColumn] {
            updateColumn(currentSelectedColumn, withConflicts: conflictStore[moveToMake])
        }
        
        //Returns new row for queen to occupy that creates the fewest number of conflicts
        //Returns the number of conflicts that will be reduced upon making this move
        return (moveToMake, nextMoveInfo.minConflictsForBestMoves - nextMoveInfo.conflictsFromRowBeforeMove, conflictStore)
    }
    
    /*Note: First two parameters are passed by reference so that they do not need to be copied
    */
    func bestMovesForQueen(inout conflictStore: [Int : [Int]], inout bestMoves : [Int], currentSelectedColumn : Int) -> (minConflictsForBestMoves : Int, conflictsFromRowBeforeMove : Int) {
        //The number of conflicts the current row position is involved in
        var conflictsFromRowBeforeMove = 0
        // keeps track of the minimum number of conflicts for the best new moves so far
        var minConflictsForBestMoves = Int.max
        
        //Used For pickBestFirst
        var  current : [Int] = []
        if self.pickFirstBetter != nil {
            current = findConflictsForColumn(currentSelectedColumn, atRow: self.columns[currentSelectedColumn])
        }
        
        //Loop through all the columns for each row choice and get conflicts
        for row in 0..<n! {
            let possibleConflicts = findConflictsForColumn(currentSelectedColumn, atRow: row)
            let conflictCounter   = possibleConflicts.count
            
            /* If row being looked at is the row that the queen in the current column currently occupies,
            * set conflictsFromRowBeforeMove to the number of conflicts this queen is currently involved in*/
            if row == self.columns[currentSelectedColumn] {
                conflictsFromRowBeforeMove = conflictCounter
            }
            
            /* If the row being looked at does not have the queen from the current column,
            * update the best move if the move in nextMoveInfo would result in fewer conflicts
            */
            if minConflictsForBestMoves > conflictCounter {
                minConflictsForBestMoves = conflictCounter
                // Replace the array with this new move since it is better than the moves currently in the array
                bestMoves = [row]
                //Resets Array
                conflictStore = [row: possibleConflicts]
                
                //if pick first better is enabled, and this conflict count is better than that of current queen position
                if pickFirstBetter! && current.count > conflictCounter {
                    return (minConflictsForBestMoves, current.count )
                }
            }
            else if minConflictsForBestMoves == conflictCounter {
                //Add to the current array because the move has the same number of conflicts
                bestMoves.append(row)
                //Adds array holding conflict information for potential moves
                conflictStore.updateValue(possibleConflicts, forKey: row)
            }
        }
        
        return (minConflictsForBestMoves, conflictsFromRowBeforeMove)
    }
    
    //Input: Column; Output: A random row for queen in column
    func randomPlacement(currentSelectedColumn : Int) -> Int {
        var minConflictsForBestMoves = 0
        //This holds all the possible conflicts for each possible move to a new row
        var conflictStore : [[Int]] = []
        var nextRow = Int.random(self.n!)
        var conflictsFromRowBeforeMove = 0
        var nextMoveConflicts = 0
        while nextRow != self.columns[currentSelectedColumn] {
            nextRow = Int.random(self.n!)
        }
        
        //Array to hold the conflicts for this row choice.
        var possibleConflicts : [Int] = []
        
        possibleConflicts = findConflictsForColumn(currentSelectedColumn, atRow: nextRow)
        nextMoveConflicts = possibleConflicts.count
        
        //Adds array holding conflict information for potential moves
        conflictStore.append(possibleConflicts)
        
        possibleConflicts = findConflictsForColumn(currentSelectedColumn, atRow: self.columns[currentSelectedColumn])
        conflictsFromRowBeforeMove = possibleConflicts.count
        
        //Adds array holding conflict information for current position
        conflictStore.append(possibleConflicts)
        
        //update conflicts for new move
        updateColumn(currentSelectedColumn, withConflicts: conflictStore[0])
        
        //Returns new row for queen to occupy
        return nextRow
    }
    
    /* Counts the number of conflicts created from the initial random assignment
    * so that the number of conflicts can quickly updated during runtime
    * Output: num conflicts in current board
    */
    func findInitialConflicts() {
        for index in 0..<self.columns.count {
            for nextIndex in index+1..<self.columns.count {
                if  self.columns[nextIndex] == self.columns[index] || //looks across row
                    self.columns[nextIndex] == self.columns[index] + (nextIndex-index) || //looks up diagonal
                    self.columns[nextIndex] == self.columns[index] - (nextIndex-index) {  //looks down diagonal
                        addConflictsBetweenTwoColumns(index, columnB: nextIndex)
                }
            }
        }
    }
    
    //extracted logic for retrieving a random column with conflicts
    func findColumnWithConflicts() -> Int {
        //Picks a column with conflicts at random
        var columnsWithConflicts = allConflicts.keys.array
        var columnsWithConflictsButNoBetterMovesAvalibleArray = columnsWithConflictsButNoBetterMovesAvalible.keys.array
        var column : Int?
        
        //sort arrays for comparison in next step
        columnsWithConflicts.sort { $0 < $1 }
        columnsWithConflictsButNoBetterMovesAvalibleArray.sort { $0 < $1 }

        //if there exist columns with conflicts with better moves avalible...
        if columnsWithConflicts != columnsWithConflictsButNoBetterMovesAvalibleArray {
            do { //While you have not selected a column that will result in a row change
                column = columnsWithConflicts[Int.random(columnsWithConflicts.count)]
            } while columnsWithConflictsButNoBetterMovesAvalible[column!] != nil
        } else {
            //We're at a local max with no way easy way out, return nil to restart
            self.resetBoard()
            self.findInitialConflicts()
            return findColumnWithConflicts()
        }
        
        return column!
    }
    
    //extracted logic for finding conflicts for a given queen's move to a given row
    func findConflictsForColumn(column: Int, atRow row: Int) -> [Int] {
        //Array to hold the conflicts for this row choice.
        var currentPossibleConflicts : [Int] = []
        
        for columnB in 0..<self.columns.count {
            //skip conflict with self
            if columnB != column {
                if  self.columns[columnB] == row || //looks across row
                    self.columns[columnB] == row + (column-columnB) || //looks up diagonal
                    self.columns[columnB] == row - (column-columnB) {  //looks down diagonal
                        currentPossibleConflicts.append(columnB)
                }
            }
        }
        
        return currentPossibleConflicts
    }
    
    //updates column with new conflicts, removes old ones
    func updateColumn(column: Int, withConflicts conflicts: [Int]?) {
        //First, Remove conflicts involving the old position
        
        //Free up the column to be looked at in the future
        columnsWithConflictsButNoBetterMovesAvalible.removeValueForKey(column)
        
        //Remove this column from other column conflicts
        if let columnConflicts = allConflicts[column] {
            for columnB in columnConflicts {
                //remove old conflicts
                allConflicts[(columnB as Int)]?.removeObject(column)
                
                //if now empty, remove it entirely
                if allConflicts[(columnB as Int)]?.count == 0 {
                    allConflicts.removeValueForKey(columnB as Int)
                }
                
                //column now has better moves
                columnsWithConflictsButNoBetterMovesAvalible.removeValueForKey((columnB as Int))
            }
        }
        
        //Remove conflicts for column
        allConflicts.removeValueForKey(column)
        
        //Then, add all the new conflicts generated by move, if there are any
        if let conflictsForMove = conflicts {
            for columnB in conflictsForMove {
                self.addConflictsBetweenTwoColumns(column, columnB: columnB)
            }
        }
    }
    
    /*Adds the conflicts between the two columns to the global conflict store*/
    func addConflictsBetweenTwoColumns(columnA : Int, columnB : Int) {
        //Frees up the column to be looked at in the future
        columnsWithConflictsButNoBetterMovesAvalible.removeValueForKey(columnA)
        
        columnsWithConflictsButNoBetterMovesAvalible.removeValueForKey(columnB)
        
        //initialize with conflict or add conflict, just not duplicates
        if allConflicts[columnA]? != nil && !allConflicts[columnA]!.containsObject(columnB) {
            allConflicts[columnA]!.addObject(columnB)
        } else {
            allConflicts[columnA] = NSMutableArray(array: [columnB])
        }
        
        if allConflicts[columnB]? != nil && !allConflicts[columnB]!.containsObject(columnA) {
            allConflicts[columnB]!.addObject(columnA)
        } else {
            allConflicts[columnB] = NSMutableArray(array: [columnA])
        }
    }
    
    
    //Are we at a solution?
    //Output: true if no more conflicts, else false
    func isSolution() -> Bool {
        return self.allConflicts.count == 0
    }
    
    /*So user can select where queens should start*/
    func moveQueen(column : Int, toPosition row: Int) {
        self.columns[column] = row
    }
}

