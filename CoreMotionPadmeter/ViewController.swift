//
//  ViewController.swift
//  CoreMotionPadmeter
//
//  Created by Jeff Ripke on 7/14/17.
//  Copyright © 2017 Jeff Ripke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let goGreen = UIColor(red: 0, green: 1.0, blue: 0.15, alpha: 1.0)
    let stopRed = UIColor(red: 1.0, green: 0, blue: 0.15, alpha: 1.0)
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBAction func startStopPedometer(_ sender: UIButton) {
        
    }
}
