//
//  WeatherManager.swift
//  Temptress
//
//  Created by Taylor Wright-Sanson on 11/27/15.
//  Copyright © 2015 Taylor Wright-Sanson. All rights reserved.
//

import UIKit
import Alamofire
// let weatherAPIKey = "6b968bf62b0b808b"

class WeatherManager: NSObject {
    static let sharedManager = WeatherManager()
    let wilmingtonWeatherURLString = "http://api.wunderground.com/api/6b968bf62b0b808b/conditions/q/NY/Wilmington.json"
    
    func getWeather(completion: (outsideTemp: Float, currentForcastImageURL: NSURL) -> Void) {
        Alamofire.request(.GET, wilmingtonWeatherURLString).responseJSON { response in
            if let JSON = response.result.value {
                if let currentObservation = JSON["current_observation"] as? [String : AnyObject] {
                    let outsideTemp = currentObservation["temp_f"] as! Float
                    let currentForcastImageURLString = currentObservation["icon_url"] as! String
                    let currentForcastImageURLStringIconSetI = currentForcastImageURLString.stringByReplacingOccurrencesOfString("/k/", withString: "/i/", options: NSStringCompareOptions.LiteralSearch, range: nil)

                    completion(outsideTemp: outsideTemp, currentForcastImageURL: NSURL(string: currentForcastImageURLStringIconSetI)!)
                }
            }
        }
    }
}
