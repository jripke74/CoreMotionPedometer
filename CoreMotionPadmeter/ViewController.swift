//
//  ViewController.swift
//  CoreMotionPadmeter
//
//  Created by Jeff Ripke on 7/14/17.
//  Copyright © 2017 Jeff Ripke. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var pedometer = CMPedometer()
    var pedometerData = CMPedometerData()
    
    let goGreen = UIColor(red: 0, green: 1.0, blue: 0.15, alpha: 1.0)
    let stopRed = UIColor(red: 1.0, green: 0, blue: 0.15, alpha: 1.0)
    var numberOfSteps: Int! = nil {
        didSet {
            //stepsLabel.text = String(format: "Steps: %i", numberOfSteps)
        }
    }
    var timer = Timer()
    var distance = 0.0
    var pace = 0.0
    var elapseSeconds = 0.0
    let interval = 0.1
    let motionActivityManager = CMMotionActivityManager()
    var motionActivity = CMMotionActivity()
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startStopPedometer: UIButton!
    @IBOutlet weak var paceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startStopPedometer.backgroundColor = goGreen
        stepsLabel.text = "Steps: Not Available"
    }
    
    func minutesSeconds(_ seconds: Double) -> String {
        let minutePart = Int(seconds) / 60
        let secondsPart = Int(seconds) % 60
        return String(format: "%02i:%02i", minutePart, secondsPart)
    }
    
    func startMotionActivityManager() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: OperationQueue.main, withHandler: { (motionActivity) in
                if let motionActivity = motionActivity {
                    self.motionActivity = motionActivity
                }
            })
        } else {
            print("JEFF: Motion activity not available")
        }
    }
    
    func activity() -> String {
        var activityString = "unkown"
        switch motionActivity.confidence {
        case .low:
            activityString = "Low"
        case .medium:
            activityString = "Meduim"
        case .high:
            activityString = "High"
        }
        if motionActivity.stationary { activityString += ":Stationary" }
        if motionActivity.walking { activityString += ":Walking" }
        if motionActivity.running { activityString += ":Running" }
        if motionActivity.automotive { activityString += ":Car" }
        if motionActivity.cycling { activityString += ":Bike" }
        if motionActivity.unknown { activityString += ":Unkown" }
        return activityString
    }
    
    func activity(motionActivity: CMMotionActivity) -> String {
        var activityString = "unkown"
        switch motionActivity.confidence {
        case .low:
            activityString = "Low"
        case .medium:
            activityString = "Meduim"
        case .high:
            activityString = "High"
        }
        if motionActivity.stationary { activityString += ":Stationary" }
        if motionActivity.walking { activityString += ":Walking" }
        if motionActivity.running { activityString += ":Running" }
        if motionActivity.automotive { activityString += ":Car" }
        if motionActivity.cycling { activityString += ":Bike" }
        if motionActivity.unknown { activityString += ":Unkown" }
        return activityString
    }
    
    func startTimer() {
        print("JEFF: Started Timer \(Data())")
        if !timer.isValid {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { (timer) in
                self.displayPedometerData()
                self.elapseSeconds += self.interval
            })
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        displayPedometerData()
    }
    
    func calulatedPace() -> Double {
        if distance > 0 {
            return elapseSeconds / distance
        } else {
            return 0
        }
    }
    
    func readActivityData() {
        let now = Date()
        let yesterday = Date(timeIntervalSince1970: (-3600 * 24))
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .long
        motionActivityManager.queryActivityStarting(from: yesterday, to: now, to: OperationQueue.main) { (motionActivities, error) in
            if let motionActivities = motionActivities {
                for motionActivity in motionActivities {
                    let activityString = dateFormatter.string(from: motionActivity.startDate) + "  " + self.activity(motionActivity: motionActivity)
                    print(activityString)
                }
            }
        }
    }
    
    func displayPedometerData() {
        statusLabel.text = activity() +  "--" + minutesSeconds(elapseSeconds)
        if let numberOfSteps = numberOfSteps {
            stepsLabel.text = String(format: "Steps: %i", numberOfSteps)
            print("JEFF: \(Date())) -- \(stepsLabel.text!)")
        }
        if let pedDistance = pedometerData.distance {
            distance = pedDistance as! Double
            distanceLabel.text = String(format: "Distance: %6.2f", distance)
            print("JEFF: \(distanceLabel.text!)")
        }
        let minutesPerMile = 1609.34
        if CMPedometer.isPaceAvailable() {
            if pedometerData.averageActivePace != nil {
                pace = pedometerData.averageActivePace as! Double
                paceLabel.text = String(format: "Pace %6.2f", minutesSeconds(pace * minutesPerMile))
            } else {
                paceLabel.text = "Pace: N/A"
            }
            print("JEFF: \(paceLabel.text!)")
        } else {
            //paceLabel.text = "Pace: Not Supported"
            //print("JEFF: Not Supported device for pace")
            paceLabel.text = "Avg. Pace: " + minutesSeconds(calulatedPace() * minutesPerMile)
            print("JEFF: \(paceLabel.text!)")
        }
    }
    
    @IBAction func startStopPedometer(_ sender: UIButton) {
        if sender.titleLabel?.text == "Start" {
            statusLabel.text = "Pedometer On"
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = stopRed
            if CMPedometer.isStepCountingAvailable() {
                startTimer()
                startMotionActivityManager()
                pedometer.startUpdates(from: Date(), withHandler: { (pedometerData, error) in
                    if let pedometerData = pedometerData {
                        self.pedometerData = pedometerData
                        //self.stepsLabel.text = "steps: \(pedometerData.numberOfSteps)"
                        self.numberOfSteps = Int(pedometerData.numberOfSteps)
                        //print("JEFF: \(Date()) -- \(pedometerData.numberOfSteps)")
                    }
            })
            } else {
                print("JEFF: Step counting is not available")
            }
        } else {
            pedometer.stopUpdates()
            motionActivityManager.stopActivityUpdates()
            stopTimer()
            statusLabel.text = "Pedometer Off"
            sender.backgroundColor = goGreen
            sender.setTitle("Start", for: .normal)
            readActivityData()
        }
    }
}
