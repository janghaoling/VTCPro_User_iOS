//
//  getServiceTyperequest.swift
//  TranxitUser
//
//  Created by Mac1 on 04/12/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

class getServiceTyperequest : JSONSerializable {
    
    var passenger : String?
    var suitcase : String?
    var vehicle_type : String?
    var total_kilometer : String?
    var total_hours : String?
    var total_minutes : String?
    var chbs_service_type_id : String?
    var start_time : String?
    
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        passenger = try? values.decode(String.self, forKey: .passenger)
        suitcase = try? values.decode(String.self, forKey: .suitcase)
        vehicle_type = try? values.decode(String.self, forKey: .vehicle_type)
        total_kilometer = try? values.decode(String.self, forKey: .total_kilometer)
        total_hours = try? values.decode(String.self, forKey: .total_hours)
        total_minutes = try? values.decode(String.self, forKey: .total_minutes)
        chbs_service_type_id = try? values.decode(String.self, forKey: .chbs_service_type_id)
        start_time = try? values.decode(String.self, forKey: .start_time)
    }
    
    init() {   }
}
