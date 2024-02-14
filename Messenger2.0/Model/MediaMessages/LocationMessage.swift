//
//  LocationMessage.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 14.02.2024.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage: NSObject, LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
    
}
