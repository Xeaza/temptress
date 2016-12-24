//
//  HomeTempManager.swift
//  Temptress
//
//  Created by Taylor Wright-Sanson on 11/27/15.
//  Copyright © 2015 Taylor Wright-Sanson. All rights reserved.
//

import UIKit
import Alamofire

enum RoomType: String {
    case LivingRoom
    case Bedroom
}

class HomeTempManager: NSObject {
    static let sharedManager = HomeTempManager()
    
    func getRoomTemperature(_ room: RoomType, completion: @escaping (_ temperature: Double, _ connected: Bool) -> Void) {
        Alamofire.request(.GET, getRoomTemperatureURLString(room)).responseJSON { response in
            if let JSON = response.result.value {
                var connected = true
                if let coreInfo = JSON["coreInfo"] as? [String : AnyObject] {
                    if let isConnected = coreInfo["connected"] as? Bool {
                        connected = isConnected
                    }
                }
                let temperature = JSON["result"] as? Double != nil ? JSON["result"] as! Double : 0.0
                completion(temperature: temperature, connected: connected)
            } else {
                completion(temperature: 0.0, connected: false)
            }
        }
    }
    
    func getRoomTemperatureURLString(_ room: RoomType) -> String {
        var roomTempMonitorID: String!
        switch room {
        case .Bedroom:
            roomTempMonitorID = "48ff6b065067555039362387"
        case .LivingRoom:
            roomTempMonitorID = "55ff6d064989495321412587"
        }
        return "https://api.spark.io/v1/devices/\(roomTempMonitorID)/temperature?access_token=b55ebebd8d715d3dd0d01c57e5bd7bdfb26ab7e6"
    }
}
