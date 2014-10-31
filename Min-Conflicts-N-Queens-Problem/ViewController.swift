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
    var maxRuns : Int = 1
    var randomness : Double = 0.2
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
        var queensPrompt = UIAlertController(title: "MinConflicts", message: "Specify the number of queens to place on the board and select the population method. Alternatively, choose Test Mode to run in the console.", preferredStyle: UIAlertControllerStyle.Alert)
        
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
        
        var testMode = UIAlertAction(title: "Test Mode", style: UIAlertActionStyle.Default) { (action) -> Void in
            // self.runAllTests(10, queens: 250, steps: 500)
            self.runAllTestsWithNQueens()
        }
        
        queensPrompt.addAction(setQueensOptimally)
        queensPrompt.addAction(setQueensRandomly)
        queensPrompt.addAction(testMode)
        self.presentViewController(queensPrompt, animated: true, completion: nil)
    }
    
    @IBAction func algoNeedsPrompt(sender: UISegmentedControl) {
        //Ask user for the number of Runs
        if self.algorithmSelector.selectedSegmentIndex ==  3{
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
            
        } else if self.algorithmSelector.selectedSegmentIndex ==  1{
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
    func populateBoardOfSize(n: Int, optimally: Bool) {
        self.solver = MinConflicts()
        self.solver.populateBoardOfSize(n, optimally: optimally)
        
        //Update Board with starting size
        if   self.solver.columns.count <= 250 {
            self.board.setBoardSize(n)
            
            self.board.setNeedsDisplay()
        }
        
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
        
        
        //In background thread
        dispatch_async(dispatch_queue_create("Solving queue", nil)) {
            var alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            var pickFirstBetter = false
            if  self.selectedAlgorithm() == Algorithm.VanillaChooseFirstBest {
                
                pickFirstBetter = true
            }
            self.solver.prepareForRunWith(self.selectedAlgorithm(), maxRuns: self.maxRuns, maxSteps: self.maxSteps.text.toInt()!, randomness: 0.2, pickFirstBetter: pickFirstBetter)
            let start = NSDate() //Start Time
            if self.solver.run() {
                let end = NSDate()   //End Time
                let timeInterval: Double = end.timeIntervalSinceDate(start)
                
                println("Solved!")
                println("Final Solution: \(self.solver.columns.description)")
                println("Found at Step \(self.solver.stepsUsed)")
                println("Solution Took \(timeInterval) seconds.")
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.resetSolveButton()
                    //Shows final board positions
                    if  self.solver.columns.count <= 250 {
                        self.board.setNeedsDisplay()
                    }
                    alert.title = "Solved!"
                    alert.message = "A solution was found at Step \(self.solver.stepsUsed) using \(timeInterval)  seconds! Would you like to play again?"
                }
            } else { //game not solved
                println("Could no be solved in less than \(self.MAX_STEPS) steps :(")
                println("Final Unsolved State " + self.solver.columns.description)
                
                //in main thread, update view
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
        if self.maxSteps.text == "" {
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
        case 3:  return Algorithm.Vanilla
        case 4:  return Algorithm.VanillaChooseFirstBest
        default: return Algorithm.Vanilla
        }
    }
    
    
    
    //When this is multi-Threaded the tests should be arranged so that each thread will finish roughly at the same time
    //, so each thread does as much works as possible without lagging behind all the others
    func runAllTestsWithNQueens() {
        //this needs to run on main thread
        var beginPrompt = UIAlertController(title: "MinConflicts", message: "Beginning all tests. Please see console for details.", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.presentViewController(beginPrompt, animated: true, completion: nil)
        //run tests in new thread
        dispatch_async(dispatch_queue_create("Solving Queue", nil)) {
            
            //Three main Algorithms
            //Runs more trials when there are fewer queens
            self.runTestForTwoBasicAlgorithms(10000, queens: 10, steps: 5000)
            
            self.runTestForTwoBasicAlgorithms(100, queens: 50, steps: 5000)
            
            self.runTestForTwoBasicAlgorithms(50, queens: 100, steps: 5000)
 
            self.runTestForTwoBasicAlgorithms(10, queens: 250, steps: 5000)
            
            self.runTestForTwoBasicAlgorithms(10, queens: 500, steps: 5000)
            
            self.runTestForTwoBasicAlgorithms(10, queens: 1000, steps: 5000)
            
            
            
            //Modifications of Vanilla
            //Runs more trials when there are fewer queens
            self.runThreeTestOnBestAlgorithm(10000, queens: 10, steps: 5000)
            
            self.runThreeTestOnBestAlgorithm(100, queens: 50, steps: 5000)
            
            self.runThreeTestOnBestAlgorithm(50, queens: 100, steps: 5000)
            
            self.runThreeTestOnBestAlgorithm(10, queens: 250, steps: 5000)
            
            self.runThreeTestOnBestAlgorithm(10, queens: 500, steps: 5000)
            
            self.runThreeTestOnBestAlgorithm(10, queens: 1000, steps: 5000)
            
            
            
            //Runs greedy last because it takes a while
            println()
            println("Greedy Algorithm")
            self.testMinConflicts(10, n: 10, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 20, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 50, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 100, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 200, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 250, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            self.testMinConflicts(10, n: 500, optimally: false, algorithm: Algorithm.Greedy,    maxRuns: 1, maxSteps: 5000, randomness: 0.2, pickFirstBetter: false)
            
            
            
            
            println("End All Testing")
            
            //go back to main thread
            dispatch_async(dispatch_get_main_queue()) {
                beginPrompt.dismissViewControllerAnimated(true, completion: { () -> Void in
                    var completePrompt = UIAlertController(title: "MinConflicts", message: "All tests have completed. Please see console for details.", preferredStyle: UIAlertControllerStyle.Alert)
                    var continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                        self.promptForBoardSize()
                    })
                    completePrompt.addAction(continueAction)
                    self.presentViewController(completePrompt, animated: true, completion: nil)
                })
            }
        }
    }
    
    
    func runTestForTwoBasicAlgorithms(trials : Int, queens : Int, steps : Int) {
        println()
        println("Begin Testing: \(trials) trials, \(queens) queens, \(steps) steps")
        //Different Algorithms, all else default
        println()
        println("Vanilla Algorithm")
        self.testMinConflicts(trials, n: queens, optimally: false, algorithm: Algorithm.Vanilla, maxRuns: 1, maxSteps: steps, randomness: 0.2, pickFirstBetter: false)
        
        println()
        println("Random Algorithm")
        self.testMinConflicts(trials, n: queens, optimally: false, algorithm: Algorithm.Random, maxRuns: 1, maxSteps: steps, randomness: 0.2, pickFirstBetter: false)
        
    }
    
    func runThreeTestOnBestAlgorithm(trials : Int, queens : Int, steps : Int) {
        println()
        println("Begin Testing Modifications for Vanilla: \(trials) trials, \(queens) queens, \(steps) steps")
        
        //Optimal Placement, all else default
        println()
        println("Optimal Placement")
        self.testMinConflicts(trials, n: queens, optimally: true, algorithm: Algorithm.Vanilla, maxRuns: 1, maxSteps: steps, randomness: 0.2, pickFirstBetter: false)
        
        //Increased Runs, all else default
        println()
        println("5 Runs")
        self.testMinConflicts(trials, n: queens, optimally: false, algorithm: Algorithm.Vanilla, maxRuns: 5, maxSteps: steps, randomness: 0.2, pickFirstBetter: false)
        
        //Pick First Better Move, all else default
        println()
        println("Pick First Better Move")
        self.testMinConflicts(trials, n: queens, optimally: false, algorithm: Algorithm.Vanilla, maxRuns: 5, maxSteps: steps, randomness: 0.2, pickFirstBetter: true)
    }
    
    func testMinConflicts(trials : Int, n : Int, optimally : Bool, algorithm : Algorithm, maxRuns : Int, maxSteps : Int, randomness : Float, pickFirstBetter : Bool) {
        var averageTotalTime = 0.0 //tracks average solve time per run
        var averageTime  = 0.0 //tracks average solve time per run
        var averageTimePreprocess = 0.0 //tracks average preprocessing time per run
        var averageSteps = 0.0 //tracks average steps when solved
        var successRate  = 0.0 //Tracks number of problems solved under the step limit
        //run MinConflicts with parameters for trials times
        for i in 1...trials {
            var solver = MinConflicts()
            let startPreprocess = NSDate() //Start  preprocessing Time
            solver.populateBoardOfSize(n, optimally: optimally)
            let endPreprocess   = NSDate()   //End preprocessing Time
            let timeIntervalPreprocess = endPreprocess.timeIntervalSinceDate(startPreprocess)
            
            solver.prepareForRunWith(algorithm, maxRuns: maxRuns, maxSteps: maxSteps, randomness: randomness, pickFirstBetter: pickFirstBetter)
            
            let start = NSDate() //Start Time
            if solver.run() {
                println("Solved at Step \(solver.stepsUsed)")
                successRate += 1
            } else {
                println("Not Solved!")
            }
            let end = NSDate()   //End Time
            let timeInterval = end.timeIntervalSinceDate(start)
            
            averageTime  += timeInterval
            averageTimePreprocess += timeIntervalPreprocess
            averageSteps += Double(solver.stepsUsed)
        }
        
        //Calculate & print average time
        averageTime  /= Double(trials)
        averageTimePreprocess /= Double(trials)
        averageTotalTime = averageTime + averageTimePreprocess
        
        averageSteps /= Double(trials)
        successRate  /= Double(trials)
        println()
        
        println("Average Solve Time Per Run : \(averageTime)")
        println("Average Preprocessing Time Per Run: \(averageTimePreprocess)")
        println("Average Total Time Per Run: \(averageTotalTime)")
        println("Average Steps Per Run: \(averageSteps)")
        println("Success Rate: \(successRate)")
    }
}

