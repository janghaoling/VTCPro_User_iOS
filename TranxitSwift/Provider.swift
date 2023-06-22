//
//  Provider.swift
//  User
//
//  Created by CSS on 01/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct Provider : JSONSerializable {
    
    var id : Int?
    var latitude :Double?
    var longitude :Double?
    var avatar : String?
    var first_name : String?
    var last_name : String?
    var rating : String?
    var mobile : String?
    var country_code : String?
    var service : ServiceDetails?
    
    var user_type : String?
    var company_name : String?

}

struct ServiceDetails : JSONSerializable {
    
    var id : Int?
    var service_model :String?
    var service_type_id :Int?
  
    
}
