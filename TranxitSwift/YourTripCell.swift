//
//  YourTripCell.swift
//  User
//
//  Created by CSS on 09/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import GoogleMaps


class YourTripCell: UITableViewCell {
    
    //MARK:- view outlets
    @IBOutlet var mainView: UIView!
    @IBOutlet var upComingView: UIView!
    
    //MARK:- UIimageView outLets
    @IBOutlet var upCommingCarImage: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    @IBOutlet var Googlemap: GMSMapView!
    
    //MARK:- label outlets
    @IBOutlet var upCommingDateLabel: UILabel!
    @IBOutlet var upCommingBookingIDLlabel: UILabel!
    @IBOutlet var upCommingCarName: UILabel!
    
    //MARK:- button outlets
    @IBOutlet var upCommingCancelBtn: UIButton!
    @IBOutlet private var labelPrice : UILabel!
    @IBOutlet private var labelModel : UILabel!
    @IBOutlet private var stackViewPrice : UIStackView!
    
    var Lat:Double = 0.0
     var Long:Double = 0.0
    private var requestId : Int?
    
    var onClickCancel : ((Int)->Void)?
    
    var isPastButton = false {
        didSet {
            self.stackViewPrice.isHidden = !isPastButton
            self.upCommingCancelBtn.isHidden = isPastButton
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
        self.upCommingCancelBtn.setTitle(Constants.string.cancelRide.localize(), for: .normal)
        self.upCommingCancelBtn.addTarget(self, action: #selector(self.buttonCancelAction), for: .touchUpInside)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// Mark :- Local Methods
extension YourTripCell {
    
    //  Set Font
    private func setDesign() {
        
        Common.setFont(to: upCommingDateLabel)
        Common.setFont(to: upCommingBookingIDLlabel)
        Common.setFont(to: upCommingCarName)
        Common.setFont(to: labelModel)
        Common.setFont(to: labelPrice)
    }
    
    // Set Values
    func set(values : Request)
    {
        self.requestId = values.id
        Cache.image(forUrl: values.service?.image)
        { (image) in
            if image != nil
            {
                DispatchQueue.main.async
                    {
                    self.upCommingCarImage.image = image
                }
            }
        }
        
        
        let mapImage = values.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.mapImageView.image = image
                }
            }
        }
        
    
     /*   let marker = GMSMarker()
        marker.appearAnimation = .none
        marker.snippet = values.s_address
        marker.icon =  #imageLiteral(resourceName: "start").resizeImage(newWidth: 30)
        marker.map = Googlemap
        marker.position = CLLocationCoordinate2D(latitude:(values.s_latitude)!, longitude: (values.s_longitude)!)
        
        let marker2 = GMSMarker()
        marker2.appearAnimation = .none
        marker2.snippet = values.d_address
        marker2.icon =  #imageLiteral(resourceName: "last").resizeImage(newWidth: 30)
        marker2.map = Googlemap
        marker2.position = CLLocationCoordinate2D(latitude:(values.d_latitude)!, longitude: (values.d_longitude)!)
        
        let way_pointaddress  =  values.way_points
        
        if way_pointaddress == nil || way_pointaddress == "Array"
        {
            
            let Position = GMSCameraPosition.camera(withLatitude: (values.s_latitude)!, longitude: (values.s_longitude)!, zoom: 10.0)
            Googlemap.camera = Position
            
            //view_waypoint.isHidden = true
         //   let coordinateSource = CLLocationCoordinate2D(latitude: ((values.s_latitude)!), longitude: ((values.s_longitude)!))
            
          //  let coordinateDes = CLLocationCoordinate2D(latitude: ((values.d_latitude)!), longitude: ((values.d_longitude)!))
            
           // fetchRouteTwolocation(from: coordinateSource, to: coordinateDes)
            
        }
        else
        {
           // view_waypoint.isHidden = false
            
            let Position = GMSCameraPosition.camera(withLatitude: (values.s_latitude)!, longitude: (values.s_longitude)!, zoom: 9.0)
            Googlemap.camera = Position
            
            Lat = 0.0
            Long = 0.0
            
            let jsonData = way_pointaddress!.data(using: .utf8)!
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            
            let Arry = dictionary as! NSArray
            let Dicdata = Arry[0] as! NSDictionary
            
            Lat = (Dicdata.value(forKey: "lat")as? Double)!
            Long = (Dicdata.value(forKey: "lng")as? Double)!
            
            let marker3 = GMSMarker()
            marker3.appearAnimation = .none
            marker3.snippet = Dicdata.value(forKey: "address")as? String
            marker3.icon =  #imageLiteral(resourceName: "stop").resizeImage(newWidth: 30)
            marker3.map = Googlemap
            marker3.position = CLLocationCoordinate2D(latitude:Lat, longitude: Long)
            
            
          //  let coordinateSource = CLLocationCoordinate2D(latitude: ((values.s_latitude)!), longitude: ((values.s_longitude)!))
            
         //   let coordinateDes = CLLocationCoordinate2D(latitude: ((values.d_latitude)!), longitude: ((values.d_longitude)!))
            
            //fetchRouteThreelocationFirst(from: coordinateSource, to: coordinateDes)
        }*/
        
        
        
        self.upCommingBookingIDLlabel.text = Constants.string.bookingId.localize()+": "+String.removeNil(values.booking_id)
        self.upCommingCarName.text = values.service?.name
        self.upCommingCarName.isHidden = isPastButton
        
        if let dateObject = Formatter.shared.getDate(from: isPastButton ? values.assigned_at : values.schedule_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss),
            let dateString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy),
            let timeString = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hh_mm_a)
        {
            
            self.upCommingDateLabel.text = dateString+" \(Constants.string.at.localize()) "+timeString
        }
        if self.isPastButton {
            self.labelModel.text = values.service?.name
            self.labelPrice.text = Formatter.shared.appPriceFormat(string: "\(Float.removeNil(values.payment?.total))")
//            self.labelPrice.text = "\(String.removeNil(User.main.currency)) \(Float.removeNil(values.payment?.total))"
        }
    }
  
    
    @IBAction private func buttonCancelAction() {
        if self.requestId != nil {
            self.onClickCancel?(self.requestId!)
        }
    }
}
