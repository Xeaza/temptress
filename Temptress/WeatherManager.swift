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
    
    func getWeather(_ completion: @escaping (_ outsideTemp: Float, _ currentForcastImageURL: URL) -> Void) {
        Alamofire.request(wilmingtonWeatherURLString).responseJSON { response in
            if let JSON = response.result.value as? [String : AnyObject] {
                if let currentObservation = JSON["current_observation"] {
                    let outsideTemp = currentObservation["temp_f"] as! Float
                    let currentForcastImageURLString = currentObservation["icon_url"] as! String
                    let currentForcastImageURLStringIconSetI = currentForcastImageURLString.replacingOccurrences(of: "/k/", with: "/i/", options: NSString.CompareOptions.literal, range: nil)

                    completion(outsideTemp, URL(string: currentForcastImageURLStringIconSetI)!)
                }
            }

        }
    }
}
