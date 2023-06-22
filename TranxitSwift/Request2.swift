//
//  Request2.swift
//  TranxitUser
//
//  Created by Eric on 2/11/20.
//  Copyright © 2020 Appoets. All rights reserved.
//

import Foundation

class Request2 : JSONSerializable {
    var id : Int?
    var booking_id : String?
    var user_id: Int?
    var provider_id: Int?
    var current_provider_id : Int?
    var fleet_id : Int?
    var service_type_id : Int?
    var note : String?
    var status : RideStatus?
    var payment_mode : PaymentType?
    var paid : Int?
    var distance: String?
    var s_address : String?
    var s_latitude : Double?
    var s_longitude : Double?
    var d_latitude : Double?
    var d_longitude : Double?
    var d_address : String?
    var way_points : String?
    var is_dispute : Int?
    var assigned_at : String?
    var schedule_at : String?
    var started_at : String?
    var finished_at : String?
    var is_scheduled : Bool?
    var user_rated : Int?
    var use_wallet : Int?
    var surge : Int?
    var route_key : String?
    var comment : String?
    var created_at : String?
    var updated_at : String?
    var created_by : String?
    var created_id : Int?
    var total_price : Float?
    var static_map : String?
    var estimated : Estimated?
    var service_type : Service1?
    var provider : Provider?

    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        booking_id = try? values.decode(String.self, forKey: .booking_id)
        user_id = try? values.decode(Int.self, forKey: .user_id)
        provider_id = try? values.decode(Int.self, forKey: .user_id)
        current_provider_id = try? values.decode(Int.self, forKey: .current_provider_id)
        fleet_id = try? values.decode(Int.self, forKey: .fleet_id)
        service_type_id = try? values.decode(Int.self, forKey: .service_type_id)
        note = try? values.decode(String.self, forKey: .note)
        status = try? values.decode(RideStatus.self, forKey: .status)
        payment_mode = try? values.decode(PaymentType.self, forKey: .payment_mode)
        paid = try? values.decode(Int.self, forKey: .paid)
        distance = try? values.decode(String.self, forKey: .distance)
        s_address = try? values.decode(String.self, forKey: .s_address)
        s_latitude = try? values.decode(Double.self, forKey: .s_latitude)
        s_longitude = try? values.decode(Double.self, forKey: .s_longitude)
        d_latitude = try? values.decode(Double.self, forKey: .d_latitude)
        d_longitude = try? values.decode(Double.self, forKey: .d_longitude)
        d_address = try? values.decode(String.self, forKey: .d_address)
        way_points = try? values.decode(String.self, forKey: .way_points)
        is_dispute = try? values.decode(Int.self, forKey: .is_dispute)
        assigned_at = try? values.decode(String.self, forKey: .assigned_at)
        schedule_at = try? values.decode(String.self, forKey: .schedule_at)
        started_at = try? values.decode(String.self, forKey: .started_at)
        finished_at = try? values.decode(String.self, forKey: .finished_at)
        is_scheduled = try? values.decode(Bool.self, forKey: .is_scheduled)
        user_rated = try? values.decode(Int.self, forKey: .user_rated)
        use_wallet = try? values.decode(Int.self, forKey: .use_wallet)
        surge = try? values.decode(Int.self, forKey: .surge)
        route_key = try? values.decode(String.self, forKey: .route_key)
        comment = try? values.decode(String.self, forKey: .comment)
        created_at = try? values.decode(String.self, forKey: .created_at)
        updated_at = try? values.decode(String.self, forKey: .updated_at)
        created_by = try? values.decode(String.self, forKey: .created_by)
        created_id = try? values.decode(Int.self, forKey: .created_id)
        total_price = try? values.decode(Float.self, forKey: .total_price)
        static_map = try? values.decode(String.self, forKey: .static_map)
        estimated = try? values.decode(Estimated.self, forKey: .estimated)
        service_type = try? values.decode(Service1.self, forKey: .service_type)
        provider = try? values.decode(Provider.self, forKey: .provider)
    }
    
    init() {   }
}
