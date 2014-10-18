//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BoardDelegate {
    let NUMBER_OF_QUEENS : Int = 20
    let MAX_STEPS : Int = 5000
    var solver : minConflicts!
    @IBOutlet var board : Board!
    @IBOutlet weak var maxSteps: UITextField!
    @IBOutlet weak var numberOfQueens: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets self as the view's delegate
        self.board.delegate = self
        //Initial default board to display on load
        self.board.setBoardSize(NUMBER_OF_QUEENS)
        solver = minConflicts(n: NUMBER_OF_QUEENS , maxSteps:MAX_STEPS)
        //Update Board with starting Positions
        self.board.setNeedsDisplay()
        
        
        //Creates a tap location detector
        let tap = UITapGestureRecognizer(target: self.board, action: "tap:")
        
        //Assigns detector to the view
        self.board.addGestureRecognizer(tap)
        //
    }
    
    func reset() {
        self.numberOfQueens.enabled = true
        self.maxSteps.enabled = true
        //See if user typed in parameters
        checkInput()
        //generate new board based on input parameters or the default values
        solver = minConflicts(n: self.numberOfQueens.text.toInt()!, maxSteps:self.maxSteps.text.toInt()!)
        self.board.setBoardSize(self.numberOfQueens.text.toInt()!)
        //reset button on board
        self.board.reset()
        //Update Board with starting Positions
        self.board.setNeedsDisplay()
    }
    
    func start() {
        self.numberOfQueens.enabled = false
         self.maxSteps.enabled = false
         //See if user typed in parameters
        checkInput()
         //solver = minConflicts(n: self.numberOfQueens.text.toInt()!, maxSteps:self.maxSteps.text.toInt()!)
                self.board.setBoardSize(self.numberOfQueens.text.toInt()!)
        //Update Board with starting Positions
        //self.board.setNeedsDisplay()
        self.board.startSolving()
        //in background thread
        dispatch_async(dispatch_queue_create("Solving queue", nil)) {
            var alert = UIAlertController()
            //Passing 1 for vanilla algorithm, 2 for randomness, 3 for greediness
            if self.solver.minConflicts(3) { //game solved!
                println("Solved!")
                println("Final Solution: \(self.solver.columns.description)")
                println("Found at Step \(self.solver.stepsUsed)")
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.board.doneSolving(true)

                    //Shows final board positions
                    self.board.setNeedsDisplay()
                    
                    alert.title = "Solved!"
                    alert.message = "A solution was found at Step \(self.solver.stepsUsed)! Would you like to play again?"
                }
            } else { //game now solved
                println("Could no be solved in less than \(self.MAX_STEPS) steps :(")
                println("Final Unsolved State " + self.solver.columns.description)
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.board.doneSolving(false)
                    //Shows final board positions
                    self.board.setNeedsDisplay()
                    
                    alert.title = "Unsolved"
                    alert.message = "A solution was not found in \(self.solver.maxSteps) steps! Would you like to play again?"
                }
            }
            
            //options to play a new game or exit
            var restartAction = UIAlertAction(title: "Play Again", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                self.reset()
            })
            
            var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            alert.addAction(restartAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Takes a Col and Row and returns whether there is a queen at that position or not
    func getContentAtRow(row : Int, col: Int) -> String {
        if self.solver == nil {
            return "0"
        }
        if self.solver.columns[col] == row {
            return "Q"
        }
        return "0"
    }
    
    
    func checkInput(){
        
        if self.maxSteps.text == ""{
            self.maxSteps.text = "\(MAX_STEPS)"
        }
        if self.numberOfQueens.text == ""{
            self.numberOfQueens.text = "\(NUMBER_OF_QUEENS)"
        }
    }
    
    
    func updateColumn(column : Int, row : Int ){
    self.solver.updateColumn(column,row: row)
         self.board.setNeedsDisplay()
    }
}

