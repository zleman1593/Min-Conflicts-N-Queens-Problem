//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var solver:minConflicts!

    override func viewDidLoad() {
        super.viewDidLoad()
        solver = minConflicts(n: 9, maxSteps:500)
        start()
    }

 
    
     func start(){
        if self.solver.minConflicts(){
            print("Solved!")
        } else{
            print(" Could no be solved in time!")
        }
    }
    
        
        
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

