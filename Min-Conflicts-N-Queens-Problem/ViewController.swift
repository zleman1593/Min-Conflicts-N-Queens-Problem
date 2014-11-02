//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BoardDelegate {
    let MAX_STEPS = 500
    var maxRuns = 1
    var randomness = 0.2
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
        //create a prompt
        var queensPrompt = UIAlertController(title: "MinConflicts", message: "Specify the number of queens to place on the board and select the population method. Alternatively, choose Test Mode to run in the console.", preferredStyle: UIAlertControllerStyle.Alert)
        
        //adds textfield for number of queens input
        queensPrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.placeholder = "Number of Queens"
        }
        
        //option to populate board optimally
        var setQueensOptimally = UIAlertAction(title: "Populate Optimally", style: UIAlertActionStyle.Default) { (action) -> Void in
            //Read from textfield
            var field = queensPrompt.textFields!.first as UITextField
            var numQueens = field.text.toInt()
            
            //populate board if valid input
            if let n = numQueens {
                self.populateBoardOfSize(n, optimally: true)
            } else {
                self.promptForBoardSize()
            }
        }
        
        //option to populate board randomly
        var setQueensRandomly = UIAlertAction(title: "Populate Randomly", style: UIAlertActionStyle.Default) { (action) -> Void in
            //Read from textfield
            var field = queensPrompt.textFields!.first as UITextField
            var numQueens = field.text.toInt()
            
            //populate board if valid input
            if let n = numQueens {
                self.populateBoardOfSize(n, optimally: false)
            } else {
                self.promptForBoardSize()
            }
        }
        
        //add options and display prompt
        queensPrompt.addAction(setQueensOptimally)
        queensPrompt.addAction(setQueensRandomly)
        self.presentViewController(queensPrompt, animated: true, completion: nil)
    }
    
    @IBAction func algoNeedsPrompt(sender: UISegmentedControl) {
        //Ask user for the number of Runs
        if self.algorithmSelector.selectedSegmentIndex ==  3 {
            var runsPrompt = UIAlertController(title: "Runs", message: "Specify the number of runs you would like.", preferredStyle: UIAlertControllerStyle.Alert)
            
            runsPrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.placeholder = "Number of Runs"
            }
            
            var runs = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default) { (action) -> Void in
                var field = runsPrompt.textFields!.first as UITextField
                
                self.maxRuns = field.text.toInt()!
            }
            runsPrompt.addAction(runs)
            self.presentViewController(runsPrompt, animated: true, completion: nil)
            
        } else if self.algorithmSelector.selectedSegmentIndex ==  1 {
            var runsPrompt = UIAlertController(title: "Randomness", message: "Specify the randomness you would like.", preferredStyle: UIAlertControllerStyle.Alert)
            
            runsPrompt.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.placeholder = "Randomness"
            }
            
            var runs = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default) { (action) -> Void in
                var field = runsPrompt.textFields!.first as UITextField
                
                
                self.randomness = Double((field.text as NSString).doubleValue)
            }
            runsPrompt.addAction(runs)
            self.presentViewController(runsPrompt, animated: true, completion: nil)
        }
    }
    
    //create a minconflicts object and populate its board
    func populateBoardOfSize(n: Int, optimally: Bool) {
        self.solver = MinConflicts()
        self.solver.populateBoardOfSize(n, optimally: optimally)
        
        //Update Board with starting size
        if self.solver.columns.count <= 250 {
            self.board.setBoardSize(n)
            self.board.setNeedsDisplay()
        }
        
        //Creates a tap location detector
        let tap = UITapGestureRecognizer(target: self.board, action: "tap:")
        
        //Assigns detector to the view
        self.board.addGestureRecognizer(tap)
    }
    
    //reset state of view
    func reset() {
        //Allow user Input
        self.maxSteps.enabled = true
        
        //reset button on board
        self.resetSolveButton()
        
        //ask if new # of queens
        self.promptForBoardSize()
    }
    
    //begin solving with minconflicts
    @IBAction func start() {
        self.disableSolveButton()
        
        //Allow user Input
        self.maxSteps.enabled = false
        
        //See if user typed in parameters
        self.checkInput()
        
        //In background thread
        dispatch_async(dispatch_queue_create("Solving queue", nil)) {
            var alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            var pickFirstBetter = false
            if  self.selectedAlgorithm() == Algorithm.VanillaChooseFirstBest {
                pickFirstBetter = true
            }
            
            //prepare for solving minconflicts (initialize settings)
            self.solver.prepareForRunWith(self.selectedAlgorithm(), maxRuns: self.maxRuns, maxSteps: self.maxSteps.text.toInt()!, randomness: 0.2, pickFirstBetter: pickFirstBetter)
            let start = NSDate() //Start Time
            if self.solver.run() {
                let end = NSDate()   //End Time
                let timeInterval = end.timeIntervalSinceDate(start)
                
                //in main thread, update view with success message
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSolveButton()
                    //Shows final board positions
                    if  self.solver.columns.count <= 250 {
                        self.board.setNeedsDisplay()
                    }
                    alert.title = "Solved!"
                    alert.message = "A solution was found at Step \(self.solver.stepsUsed) in \(round(1000 * timeInterval) / 1000) seconds! Would you like to play again?"
                }
            } else { //game not solved
                
                //in main thread, update view with failure message
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSolveButton()
                    if  self.solver.columns.count <= 250 {
                        //Shows final board positions
                        self.board.setNeedsDisplay()
                    }
                    
                    alert.title = "Unsolved"
                    alert.message = "A solution was not found in \(self.solver.maxSteps!) steps! Would you like to play again?"
                }
            }
            
            //options to play a new game or exit
            var continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (alert) -> Void in
                self.reset()
            })
            
            //add options and display prompt
            alert.addAction(continueAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //disables solve during run
    func disableSolveButton() {
        self.solveButton.enabled = false
        self.solveButton.backgroundColor = UIColor.lightGrayColor()
        self.solveButton.setTitle("Solving...", forState: UIControlState.Normal)
    }
    
    //enables solve once run is over
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
        if self.maxSteps.text == "" {
            self.maxSteps.text = "\(MAX_STEPS)"
        }
    }
    
    /*Allows user to indicate where initial queens should be placed*/
    func updateColumn(column : Int, row : Int ){
        self.solver.updateColumn(column,row: row)
        self.board.setNeedsDisplay()
    }
    
    //which algorithm is chosen
    func selectedAlgorithm() -> Algorithm {
        switch self.algorithmSelector.selectedSegmentIndex {
        case 0:  return Algorithm.Vanilla
        case 1:  return Algorithm.Random
        case 2:  return Algorithm.Greedy
        case 3:  return Algorithm.Vanilla
        case 4:  return Algorithm.VanillaChooseFirstBest
        default: return Algorithm.Vanilla
        }
    }
}

