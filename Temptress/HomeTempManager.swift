//
//  HomeTempManager.swift
//  Temptress
//
//  Created by Taylor Wright-Sanson on 11/27/15.
//  Copyright © 2015 Taylor Wright-Sanson. All rights reserved.
//

import UIKit
import Alamofire

class HomeTempManager: NSObject {
    static let sharedManager = HomeTempManager()

    func getBedroomTemperature(completion: (bedroomTemp: Double, connected: Bool) -> Void) {
        let bedroomTemperatureURLString = "https://api.spark.io/v1/devices/48ff6b065067555039362387/temperature?access_token=b55ebebd8d715d3dd0d01c57e5bd7bdfb26ab7e6"
        
        Alamofire.request(.GET, bedroomTemperatureURLString).responseJSON { response in
            if let JSON = response.result.value {
                var connected = true
                if let coreInfo = JSON["coreInfo"] as? [String : AnyObject] {
                    if let isConnected = coreInfo["connected"] as? Bool {
                        connected = isConnected
                    }
                }
                let temperature = JSON["result"] as? Double != nil ? JSON["result"] as! Double : 0.0
                completion(bedroomTemp: temperature, connected: connected)
            } else {
                completion(bedroomTemp: 0.0, connected: false)
            }
        }
        
    }
}
