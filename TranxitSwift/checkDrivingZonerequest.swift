//
//  checkDrivingZonerequest.swift
//  TranxitUser
//
//  Created by Mac1 on 02/12/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

class checkDrivingZonerequest : JSONSerializable {
    
    var start_location : String?
    var destination_location : String?
    var way_location : String?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        start_location = try? values.decode(String.self, forKey: .start_location)
        destination_location = try? values.decode(String.self, forKey: .destination_location)
         way_location = try? values.decode(String.self, forKey: .way_location)
      
    }
    
    init() {   }
}

class start_location1: JSONSerializable
{
    var lat : Double?
    var lng : Double?
    var formatted_address : String?
    var region_name : String?
    var country : String?
    var address : String?
    
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try? values.decode(Double.self, forKey: .lat)
        lng = try? values.decode(Double.self, forKey: .lng)
        formatted_address = try? values.decode(String.self, forKey: .formatted_address)
        region_name = try? values.decode(String.self, forKey: .region_name)
        country = try? values.decode(String.self, forKey: .country)
        address = try? values.decode(String.self, forKey: .address)
        
    }
    
    init() {   }
    
}

class destination_location1: JSONSerializable
{
    var lat : Double?
    var lng : Double?
    var formatted_address : String?
    var region_name : String?
    var country : String?
    var address : String?
    
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try? values.decode(Double.self, forKey: .lat)
        lng = try? values.decode(Double.self, forKey: .lng)
        formatted_address = try? values.decode(String.self, forKey: .formatted_address)
        region_name = try? values.decode(String.self, forKey: .region_name)
        country = try? values.decode(String.self, forKey: .country)
        address = try? values.decode(String.self, forKey: .address)
        
    }
    
    init() {   }
    
}



class way_location1: JSONSerializable
{
    var lat : Double?
    var lng : Double?
    var formatted_address : String?
    var region_name : String?
    var country : String?
    var address : String?
    
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try? values.decode(Double.self, forKey: .lat)
        lng = try? values.decode(Double.self, forKey: .lng)
        formatted_address = try? values.decode(String.self, forKey: .formatted_address)
        region_name = try? values.decode(String.self, forKey: .region_name)
        country = try? values.decode(String.self, forKey: .country)
        address = try? values.decode(String.self, forKey: .address)
        
    }
    
    init() {   }
    
}
