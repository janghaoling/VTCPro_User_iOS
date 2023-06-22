//
//  getServicePOIDisatnceInfo.swift
//  TranxitUser
//
//  Created by Mac1 on 03/12/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation


class getServicePOIDisatnceInfo : JSONSerializable
{
    var id : Int?
    var name : String?
    var provider_name : String?
    var image : String?
    var marker : String?
    var capacity : Int?
    var luggage_capacity : Int?
    var fixed :String?
    var price : Int?
    var minute : Int?
    var hour : Int?
    var distance : Int?
    var calculator :String?
    var description : String?
    var waiting_free_mins : Int?
    var waiting_min_charge : Int?
    var status : Int?
    var fleet_id : Int?
    var sel : String?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        name = try? values.decode(String.self, forKey: .name)
        provider_name = try? values.decode(String.self, forKey: .provider_name)
        image = try? values.decode(String.self, forKey: .image)
        image = try? values.decode(String.self, forKey: .image)
        marker = try? values.decode(String.self, forKey: .marker)
        capacity = try? values.decode(Int.self, forKey: .capacity)
        luggage_capacity = try? values.decode(Int.self, forKey: .luggage_capacity)
        fixed = try? values.decode(String.self, forKey: .fixed)
        price = try? values.decode(Int.self, forKey: .price)
        minute = try? values.decode(Int.self, forKey: .minute)
        hour = try? values.decode(Int.self, forKey: .hour)
        distance = try? values.decode(Int.self, forKey: .distance)
        calculator = try? values.decode(String.self, forKey: .calculator)
        description = try? values.decode(String.self, forKey: .description)
        waiting_free_mins = try? values.decode(Int.self, forKey: .waiting_free_mins)
        waiting_min_charge = try? values.decode(Int.self, forKey: .waiting_min_charge)
        status = try? values.decode(Int.self, forKey: .status)
        fleet_id = try? values.decode(Int.self, forKey: .fleet_id)
          sel = try? values.decode(String.self, forKey: .sel)
    }
    
    init() {   }
}

/*class getServicePOIDisatnceInfo: JSONSerializable
{
    var getServicePOIDisatnceInfo : [getServicePOIDisatnceInfo1]?
}
*/
