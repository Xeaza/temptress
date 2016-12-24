//
//  ViewController.swift
//  Temptress
//
//  Created by Taylor Wright-Sanson on 11/26/15.
//  Copyright © 2015 Taylor Wright-Sanson. All rights reserved.
//

import UIKit
import SDWebImage

class TemperatureViewController: UIViewController {
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var temperatureTitleLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var outsideTemperatureLabel: UILabel!
    @IBOutlet weak var outsideTempTitleLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureTitleLabelTopConstraint: NSLayoutConstraint!
    
    var timer: Timer!
    var temperatureTitleLabelTopStartingConstant: CGFloat!
    var updating: Bool = false
    let degreesUnicode = "\u{00B0}F"
    var rooms: [RoomType] = [.Bedroom]
    var nextRoomTempToShow: RoomType = .Bedroom
    var indexOfCurrentRoom: Int = 0
    
    override func viewDidAppear(_ animated: Bool) {
        updateAllTemperatures()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(TemperatureViewController.changeBackgroundColor), userInfo: nil, repeats: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rooms = [.Bedroom, .LivingRoom]
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
            updateMainTemperature()
        }
    }
    
    func updateWeather() {
        updating = true
        WeatherManager.sharedManager.getWeather { (outsideTemp, currentForcastImageURL) -> Void in
            self.outsideTemperatureLabel.text = "\(outsideTemp)\(self.degreesUnicode)"
            self.weatherImageView.sd_setImage(with: currentForcastImageURL)

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.outsideTemperatureLabel.alpha = 1.0
                self.outsideTempTitleLabel.alpha = 1.0
                self.updating = false
            })
        }
    }
    
    func updateMainTemperature() {
        updating = true
        HomeTempManager.sharedManager.getRoomTemperature(nextRoomTempToShow) { (temperature, connected) -> Void in
            self.updateTemperatureLabel(temperature)
            if !connected {
                self.emergency()
            }
            self.updateLastUpdatedLabel()
            self.updating = false
        }
    }
    
    @IBAction func onTapGestureRecognized(_ sender: AnyObject) {
        setRoomToShowGetTemperatureFor()
        updateAllTemperatures()
    }
    
    func updateTemperatureLabel(_ temperature: Double) {
        DispatchQueue.main.async { () -> Void in
            self.temperatureLabel.text = String(Int(round(temperature)))
            self.temperatureTitleLabelTopConstraint.constant = self.temperatureTitleLabelTopStartingConstant
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.temperatureLabel.alpha = 1.0
                self.degreeLabel.alpha = 1.0
                self.temperatureTitleLabel.alpha = 0.0
                self.view.layoutSubviews()
                }, completion: { (Bool) -> Void in
                    self.temperatureTitleLabel.text = self.nextRoomTempToShow.rawValue.uppercased()
                    UIView.animate(withDuration: 0.1, animations: { () -> Void in
                        self.temperatureTitleLabel.alpha = 1.0
                    })
            })
        }
    }
    
    func updateLastUpdatedLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a" // superset of OP's format
        let currentDateTime = "Last updated: \(dateFormatter.string(from: Date()))"
        
        DispatchQueue.main.async { () -> Void in
            self.lastUpdatedLabel.alpha = 0.0
            self.lastUpdatedLabel.text = currentDateTime
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.lastUpdatedLabel.alpha = 1.0
            })
        }
    }
    
    func setRoomToShowGetTemperatureFor() {
        indexOfCurrentRoom += 1
        if indexOfCurrentRoom >= rooms.count {
            indexOfCurrentRoom = 0
        }
        nextRoomTempToShow = rooms[indexOfCurrentRoom]
    }

    func changeBackgroundColor() {
        UIView.animate(withDuration: 2.0, animations: { () -> Void in
            self.view.backgroundColor = self.getRandomColor()
        }) 
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
        DispatchQueue.main.async { () -> Void in
            self.temperatureTitleLabel.text = "Tap to refresh, your spark core might be disconnected..."
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        timer = nil
    }
}

