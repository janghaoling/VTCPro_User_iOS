//
//  SelectLocation.swift
//  TranxitUser
//
//  Created by Mac3 on 09/11/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit
 import GoogleMaps
import GooglePlaces
  import MapKit


class SelectLocation: UIView {
 
    @IBOutlet weak var lbl_address : UILabel!
    @IBOutlet weak var btn_confirm : UIButton!
    @IBOutlet weak var btn_currentlocation : UIButton!
    
     private var isUserInteractingWithMap = false // Boolean to handle Mapview User interaction
     @IBOutlet weak var SelectStopMap : GMSMapView?
    
    
    
    
    @IBAction private func backButtonAction()
    {
        UIView.animate(withDuration: 0.3, animations: {
           
        }) { (_) in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        btn_confirm.layer.cornerRadius = 5
        btn_confirm.clipsToBounds = true
        
        
        Common.setFont(to: lbl_address)
        Common.setFont(to: btn_confirm)
    }
    
 
    
}




