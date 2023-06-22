//
//  AppData.swift
//  User
//
//  Created by CSS on 10/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

let AppName = "VTCPRO Fleet"
var deviceTokenString = Constants.string.noDevice
//let stripePublishableKey = "pk_test_UJjNe590TPdxaEoQKct3TG0d"
let googleMapKey = "AIzaSyAw0ehACgYbZzhBLIhMn3D2U1ekSSX2uAc"
let appSecretKey = "OMV3biaXeE78bOW5TIOJABYLkLOnz2YTx5kadSK3"
let appClientId = 2
let passwordLengthMax = 10
let defaultMapLocation = LocationCoordinate(latitude: 13.009245, longitude: 80.212929)

let baseUrl = "https://fleet.solutionweb.io/"
//let baseUrl = "http://192.168.0.105:8000/"
var supportNumber = "919585290750"
var supportEmail = "support@vtc.com"
var offlineNumber = "57777"
let helpSubject = "\(AppName) Help"

let requestInterval : TimeInterval = 60
let requestCheckInterval : TimeInterval = 5
let driverBundleID = "com.vtcpro.driver"

// AppStore URL

enum AppStoreUrl : String {
    
    case user = "https://itunes.apple.com/fr/app/uber/id368677368"
    case driver = "https://itunes.apple.com/fr/app/uber-driver-pour-chauffeurs/id1131342792?mt=8"
    
}
