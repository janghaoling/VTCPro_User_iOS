//
//  checkPoiPriceLogicrequst.swift
//  TranxitUser
//
//  Created by Mac1 on 02/12/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

/*class checkPoiPriceLogicrequst : JSONSerializable {
    
     var start_location_lat : Double?
     var start_location_lng : Double?
     var dest_location_lat : Double?
     var dest_location_lng : Double?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        start_location_lat = try? values.decode(Double.self, forKey: .start_location_lat)
        start_location_lng = try? values.decode(Double.self, forKey: .start_location_lng)
        dest_location_lat = try? values.decode(Double.self, forKey: .dest_location_lat)
        dest_location_lng = try? values.decode(Double.self, forKey: .dest_location_lng)
    
    }
    
    init() {   }
}
*/

struct checkPoiPriceLogicrequst : JSONSerializable
{
    
    var start_location_lat : Double?
    var start_location_lng : Double?
    var dest_location_lat : Double?
    var dest_location_lng : Double?
}

