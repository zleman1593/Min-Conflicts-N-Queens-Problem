//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BoardDelegate {
    let MAX_STEPS : Int = 500
    var solver : MinConflicts!
    @IBOutlet var board : Board!
    @IBOutlet var solveButton: UIButton!
    @IBOutlet weak var maxSteps: UITextField!
    @IBOutlet weak var algorithmSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets self as the view's delegate
        self.board.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.promptForBoardSize()
    }
    
    func promptForBoardSize() {
        var queensPrompt = UIAlertController(title: "N-Queens", message: "How many queens would you like on the board?", preferredStyle: UIAlertControllerStyle.Alert)
        
        queensPrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.placeholder = "Number of Queens"
        }
        
        //populates board optimally
        var setQueensOptimally = UIAlertAction(title: "Populate Optimally", style: UIAlertActionStyle.Default) { (action) -> Void in
            //Initial default board to display on load
            var field = queensPrompt.textFields!.first as UITextField
            var numQueens = field.text.toInt()
            
            if let n = numQueens {
                self.populateBoardOfSize(n, optimally: true)
            } else {
                self.promptForBoardSize()
            }
        }
        
        //populates board randomly
        var setQueensRandomly = UIAlertAction(title: "Populate Randomly", style: UIAlertActionStyle.Default) { (action) -> Void in
            //Initial default board to display on load
            var field = queensPrompt.textFields!.first as UITextField
            var numQueens = field.text.toInt()
            
            if let n = numQueens {
                self.populateBoardOfSize(n, optimally: false)
            } else {
                self.promptForBoardSize()
            }
        }
        
        queensPrompt.addAction(setQueensOptimally)
        queensPrompt.addAction(setQueensRandomly)
        self.presentViewController(queensPrompt, animated: true, completion: nil)
    }
    
    func populateBoardOfSize(n: Int, optimally: Bool) {
        self.solver = MinConflicts()
        self.solver.populateBoardOfSize(n, optimally: optimally)
        
        //Update Board with starting size
        self.board.setBoardSize(n)
        self.board.setNeedsDisplay()
        
        //Creates a tap location detector
        let tap = UITapGestureRecognizer(target: self.board, action: "tap:")
        
        //Assigns detector to the view
        self.board.addGestureRecognizer(tap)
    }
    
    func reset() {
        //Allow user Input
        self.maxSteps.enabled = true

        //reset button on board
        self.resetSolveButton()
        
        //ask if new # of queens
        self.promptForBoardSize()
    }
    
    @IBAction func start() {
        self.disableSolveButton()
        
        //Allow user Input
        self.maxSteps.enabled = false
        
        //See if user typed in parameters
        self.checkInput()
        
        //set max steps
        solver.maxSteps = self.maxSteps.text.toInt()!
        
        //In background thread
        dispatch_async(dispatch_queue_create("Solving queue", nil)) {
            var alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            if self.solver.run(self.selectedAlgorithm()) {
                println("Solved!")
                println("Final Solution: \(self.solver.columns.description)")
                println("Found at Step \(self.solver.stepsUsed)")
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSolveButton()
                    //Shows final board positions
                    self.board.setNeedsDisplay()
                    alert.title = "Solved!"
                    alert.message = "A solution was found at Step \(self.solver.stepsUsed)! Would you like to play again?"
                }
            } else { //game not solved
                println("Could no be solved in less than \(self.MAX_STEPS) steps :(")
                println("Final Unsolved State " + self.solver.columns.description)
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSolveButton()
                    //Shows final board positions
                    self.board.setNeedsDisplay()
                    alert.title = "Unsolved"
                    alert.message = "A solution was not found in \(self.solver.maxSteps!) steps! Would you like to play again?"
                }
            }
            
            //options to play a new game or exit
            var continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                self.reset()
            })
            
            alert.addAction(continueAction)

            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func disableSolveButton() {
        self.solveButton.enabled = false
        self.solveButton.backgroundColor = UIColor.lightGrayColor()
        self.solveButton.setTitle("Solving...", forState: UIControlState.Normal)
    }
    
    func resetSolveButton() {
        self.solveButton.enabled = true
        self.solveButton.backgroundColor = UIColor(red: 0, green: 128/255, blue: 255, alpha: 1)
        self.solveButton.setTitle("Solve", forState: UIControlState.Normal)
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
    
    /*Checks to see if user added parameters*/
    func checkInput(){
        if self.maxSteps.text == ""{
            self.maxSteps.text = "\(MAX_STEPS)"
        }
    }
    
    /*Allows user to indicate where initial queens should be placed*/
    func updateColumn(column : Int, row : Int ){
        self.solver.updateColumn(column,row: row)
        self.board.setNeedsDisplay()
    }
    
    func selectedAlgorithm() -> Algorithm {
        switch self.algorithmSelector.selectedSegmentIndex {
        case 0:  return Algorithm.Vanilla
        case 1:  return Algorithm.Random
        case 2:  return Algorithm.Greedy
        default: return Algorithm.Vanilla
        }
    }
}

