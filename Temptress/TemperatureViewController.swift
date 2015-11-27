//
//  ViewController.swift
//  Temptress
//
//  Created by Taylor Wright-Sanson on 11/26/15.
//  Copyright © 2015 Taylor Wright-Sanson. All rights reserved.
//

import UIKit

class TemperatureViewController: UIViewController {
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureTitleLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var outsideTemperatureLabel: UILabel!
    @IBOutlet weak var outsideTempTitleLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureTitleLabelTopConstraint: NSLayoutConstraint!
    
    var timer: NSTimer!
    var temperatureTitleLabelTopStartingConstant: CGFloat!
    var updating: Bool = false
    let degreesUnicode = "\u{00B0}F"

    override func viewDidAppear(animated: Bool) {
        updateAllTemperatures()
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "changeBackgroundColor", userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = getRandomColor()
        temperatureTitleLabelTopStartingConstant = temperatureTitleLabelTopConstraint.constant
        hideLabels()
        degreeLabel.text = degreesUnicode
        lastUpdatedLabel.text = "Last updated: Stardate \(arc4random_uniform(600)).\(arc4random_uniform(256))"
        temperatureTitleLabel.text = "Thinking about what temperature it might be..."
    }
    
    func updateAllTemperatures() {
        if !updating {
            updateWeather()
            updateBedroomTemperature()
        }
    }
    
    func updateWeather() {
        updating = true
        WeatherManager.sharedManager.getWeather { (outsideTemp, currentForcastImageURL) -> Void in
            self.outsideTemperatureLabel.text = "\(outsideTemp)\(self.degreesUnicode)"
            self.weatherImageView.pin_setImageFromURL(currentForcastImageURL)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.outsideTemperatureLabel.alpha = 1.0
                self.outsideTempTitleLabel.alpha = 1.0
                self.updating = false
            })
        }
    }
    
    func updateBedroomTemperature() {
        updating = true
        HomeTempManager.sharedManager.getBedroomTemperature { (bedroomTemp, connected) -> Void in
            self.updateTemperatureLabel(bedroomTemp)
            if !connected {
                self.emergency()
            }
            self.updateLastUpdatedLabel()
            self.updating = false
        }
    }
    
    @IBAction func onTapGestureRecognized(sender: AnyObject) {
        updateAllTemperatures()
    }
    
    func updateTemperatureLabel(temperature: Double) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.temperatureLabel.text = String(Int(round(temperature)))
            self.temperatureTitleLabelTopConstraint.constant = self.temperatureTitleLabelTopStartingConstant
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.temperatureLabel.alpha = 1.0
                self.degreeLabel.alpha = 1.0
                self.temperatureTitleLabel.alpha = 0.0
                self.view.layoutSubviews()
                }, completion: { (Bool) -> Void in
                    self.temperatureTitleLabel.text = "Bedroom".uppercaseString
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        self.temperatureTitleLabel.alpha = 1.0
                    })
            })
        }
    }
    
    func updateLastUpdatedLabel() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
        let currentDateTime = "Last updated: \(dateFormatter.stringFromDate(NSDate()))"
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.lastUpdatedLabel.alpha = 0.0
            self.lastUpdatedLabel.text = currentDateTime
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.lastUpdatedLabel.alpha = 1.0
            })
        }
    }

    func changeBackgroundColor() {
        UIView.animateWithDuration(2.0) { () -> Void in
            self.view.backgroundColor = self.getRandomColor()
        }
    }
    
    func getRandomColor() -> UIColor {
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func hideLabels() {
        degreeLabel.alpha = 0.0
        temperatureLabel.alpha = 0.0
        outsideTemperatureLabel.alpha = 0.0
        outsideTempTitleLabel.alpha = 0.0
        temperatureTitleLabelTopConstraint.constant = -80
    }
    
    func emergency() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.temperatureTitleLabel.text = "Refresh, your spark core might be disconnected..."
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        timer = nil
    }
}

