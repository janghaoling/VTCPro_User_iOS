//
//  YourTripsViewController.swift
//  User
//
//  Created by CSS on 13/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import ImageSlideshow
import AlamofireImage
import GoogleMaps

class YourTripsDetailViewController: UITableViewController {
    
    //MARK:- IBOutlets
    
    var Lat:Double = 0.0
    var Long:Double = 0.0
    @IBOutlet private weak var imageViewMap : UIImageView!
  //  @IBOutlet private weak var Googlemap : GMSMapView!
    @IBOutlet private weak var view_waypoint : UIView!
    
    @IBOutlet private weak var imageViewProvider : UIImageView!
    @IBOutlet private weak var labelProviderName : UILabel!
    @IBOutlet private weak var viewRating : FloatRatingView!
    @IBOutlet private weak var labelDate : UILabel!
    @IBOutlet private weak var labelTime : UILabel!
    @IBOutlet private weak var labelBookingId : UILabel!
    @IBOutlet private weak var labelPayViaString : UILabel!
    @IBOutlet private weak var imageViewPayVia : UIImageView!
    @IBOutlet private weak var labelPayVia : UILabel!
    @IBOutlet private weak var labelPrice : UILabel!
    @IBOutlet private weak var labelCommentsString : UILabel!
    @IBOutlet private weak var textViewComments : UITextView!
    @IBOutlet private weak var buttonCancelRide : UIButton!
    @IBOutlet private weak var buttonViewReciptAndCall : UIButton!
    @IBOutlet private weak var viewLocation : UIView!
    @IBOutlet private weak var labelSourceLocation : UILabel!
    @IBOutlet private weak var labelDestinationLocation : UILabel!
    @IBOutlet private weak var labelWayLocation : UILabel!
    @IBOutlet private weak var viewComments : UIView!
    @IBOutlet private weak var viewButtons : UIView!
    @IBOutlet private weak var viewMore : UIView!
    @IBOutlet private weak var buttonDispute : UIButton!
    @IBOutlet private weak var buttonLostItem : UIButton!
    
    @IBOutlet weak var imageViewWeek0: UIImageView!
    @IBOutlet weak var lbWeek0: UILabel!
    @IBOutlet weak var imageViewWeek1: UIImageView!
    @IBOutlet weak var lbWeek1: UILabel!
    @IBOutlet weak var imageViewWeek2: UIImageView!
    @IBOutlet weak var lbWeek2: UILabel!
    @IBOutlet weak var imageViewWeek3: UIImageView!
    @IBOutlet weak var lbWeek3: UILabel!
    @IBOutlet weak var imageViewWeek4: UIImageView!
    @IBOutlet weak var lbWeek4: UILabel!
    @IBOutlet weak var imageViewWeek5: UIImageView!
    @IBOutlet weak var lbWeek5: UILabel!
    @IBOutlet weak var imageViewWeek6: UIImageView!
    @IBOutlet weak var lbWeek6: UILabel!

    var barbtnItemUpdate : UIBarButtonItem? = nil
    
    //MARK:- Local Variable
    
    var isUpcomingTrips = false  // Boolean to handle Past and Upcoming Trips
    private var heightArray : [CGFloat] = [62,75,70,145,44,44,44,44,44,44,44]
    private var dataSource : Request?
    private var viewRecipt : InvoiceView?
    private var blurView : UIView?
    private var requestId : Int?
    private var disputeView : DisputeLostItemView?
    private var disputeStatusView : DisputeStatusView?
    var disputeList:[String]=[]
    var providerIconUrl = ""
    var isBeforeShowedFordisputeView = false
    var isBeforeShowedFordisputeStatusView = false

    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.localize()
        self.setDesign()
        self.initialLoads()
        
         view_waypoint.isHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayouts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imageViewMap.image = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewButtons.isHidden = false
        self.viewMore.isHidden = false
        
        if isBeforeShowedFordisputeView {
            self.disputeView?.isHidden = false
        }
        if isBeforeShowedFordisputeStatusView {
            self.disputeStatusView?.isHidden = false
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        var disputeList = DisputeList()
        disputeList.dispute_type = UserType.user.rawValue
        self.presenter?.post(api: .getDisputeList, data: disputeList.toData())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideRecipt()

        isBeforeShowedFordisputeView = !(self.disputeView?.isHidden ?? true)
        isBeforeShowedFordisputeStatusView = !(self.disputeStatusView?.isHidden ?? true)
        
        self.viewMore.isHidden = true
        self.disputeView?.isHidden = true
        self.disputeStatusView?.isHidden = true
        self.viewButtons.isHidden = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.disputeView?.removeFromSuperview()
        self.disputeView = nil
        self.disputeStatusView?.removeFromSuperview()
        self.disputeStatusView = nil
    }
    
    deinit {
        self.viewButtons.removeFromSuperview()
        self.viewMore.removeFromSuperview()
        self.disputeView?.removeFromSuperview()
        self.disputeView = nil
        self.disputeStatusView?.removeFromSuperview()
        self.disputeStatusView = nil
        
    }
    
    @IBAction func onClickProviderIcon(_ sender: Any) {
        let vc = FullScreenSlideshowViewController()
        vc.inputs = [
            AlamofireSource(urlString: self.providerIconUrl)!
        ]
        self.present(vc, animated: true, completion:nil)

    }
}

// MARK:-  Local Methods

extension YourTripsDetailViewController {
    
    //  Initial Loads
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        if !isUpcomingTrips {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.tapMore))
        } else {
            barbtnItemUpdate = UIBarButtonItem.init(title: "OK", style: .plain, target: self, action: #selector(onClickUpdateRecurrent))
            self.navigationItem.rightBarButtonItem = barbtnItemUpdate
            barbtnItemUpdate!.isEnabled = false
        }
        
        self.buttonCancelRide.isHidden = !isUpcomingTrips
        self.buttonCancelRide.addTarget(self, action: #selector(self.buttonCancelRideAction(sender:)), for: .touchUpInside)
        self.buttonViewReciptAndCall.addTarget(self, action: #selector(self.buttonCallAndReciptAction(sender:)), for: .touchUpInside)
        self.buttonDispute.addTarget(self, action: #selector(self.buttonDisputeAction(sender:)), for: .touchUpInside)
        self.buttonLostItem.addTarget(self, action: #selector(self.buttonLostItemAction(sender:)), for: .touchUpInside)
        self.loader.isHidden = false
        let api : Base = self.isUpcomingTrips ? .upcomingTripDetail : .pastTripDetail
        self.presenter?.get(api: api, parameters: ["request_id":self.requestId!])
        
        self.viewRating.minRating = 1
        self.viewRating.maxRating = 5
        self.viewRating.emptyImage = #imageLiteral(resourceName: "StarEmpty")
        self.viewRating.fullImage = #imageLiteral(resourceName: "StarFull")
        self.imageViewMap.image = #imageLiteral(resourceName: "rd-map")
        UIApplication.shared.keyWindow?.addSubview(self.viewButtons)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        self.viewButtons.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor, constant: -16).isActive = true
        self.viewButtons.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor, constant: 0).isActive = true
        
        let moreViewY = (self.navigationController?.navigationBar.frame.height)!+(self.navigationController?.navigationBar.frame.origin.y)!
        self.viewMore.frame = CGRect(x: self.view.frame.width-170, y: moreViewY , width: 150, height: 100)
        UIApplication.shared.keyWindow?.addSubview(self.viewMore)
        self.viewMore.alpha = 0
        //UIApplication.shared.keyWindow?.addSubview(self.stackViewButtons)
        
//        let touchOutside: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.touchOutside))
//        view.addGestureRecognizer(touchOutside)
    }
    
    @objc func onClickUpdateRecurrent() {
        let api : Base = .updateRecurrent
        var data = UpdateRecurrent()
        data.recurrent_id = dataSource?.user_req_recurrent_id
        data.recurrent = dataSource?.repeated
        self.presenter?.post(api: api, data: data.toData())
    }

    
    @objc func touchOutside() {
        self.viewMore.alpha = 0
    }
    
    
    func setId(id : Int) {
        self.requestId = id
    }
    
    //  Localize
    private func localize() {
        
        self.buttonViewReciptAndCall.setTitle((isUpcomingTrips ? Constants.string.call:Constants.string.viewRecipt).localize().uppercased(), for: .normal)
        self.labelPayViaString.text = (isUpcomingTrips ? Constants.string.paymentMethod : Constants.string.payVia).localize()
        self.buttonLostItem.setTitle(Constants.string.lostItem.localize(), for: .normal)
        
        if isUpcomingTrips {
            self.buttonCancelRide.setTitle(Constants.string.cancelRide.localize().uppercased(), for: .normal)
        } else {
            self.labelCommentsString.text = Constants.string.comments.localize()
        }
        self.navigationItem.title = (isUpcomingTrips ? Constants.string.upcomingTripDetails : Constants.string.pastTripDetails).localize()
        
    }
    
    // Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: self.labelCommentsString, isTitle: true)
        Common.setFont(to: self.labelPayViaString, isTitle:  true)
        Common.setFont(to: self.labelDate, size : 12)
        Common.setFont(to: self.labelTime, size : 12)
        Common.setFont(to: self.labelBookingId)
        Common.setFont(to: self.labelPrice)
        Common.setFont(to: self.labelProviderName)
        Common.setFont(to: self.labelSourceLocation, size : 12)
        Common.setFont(to: self.labelWayLocation, size : 12)
        Common.setFont(to: self.labelDestinationLocation, size : 12)
        Common.setFont(to: self.labelPayVia)
        Common.setFont(to: self.buttonViewReciptAndCall, isTitle: true)
        Common.setFont(to: self.buttonDispute, isTitle: false)
        Common.setFont(to: self.buttonLostItem, isTitle: false)
        if isUpcomingTrips {
            Common.setFont(to: self.buttonCancelRide, isTitle: true)
        }
        
    }
    
    //  Layouts
    
    private func setLayouts() {
        
        self.imageViewProvider.makeRoundedCorner()
        let height = tableView.tableFooterView?.frame.origin.y ?? 0//(self.buttonViewReciptAndCall.convert(self.buttonViewReciptAndCall.frame, to: UIApplication.shared.keyWindow ?? self.tableView).origin.y+self.buttonViewReciptAndCall.frame.height)
        guard height <= UIScreen.main.bounds.height else { return }
        let footerHeight = UIScreen.main.bounds.height-height
        self.tableView.tableFooterView?.frame.size.height = (footerHeight-(self.buttonViewReciptAndCall.frame.height*2)-(self.navigationController?.navigationBar.frame.height ?? 0))
    }
    
    
     //  Two location
    
 /*   func fetchRouteTwolocation(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
        let session = URLSession.shared
    
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleMapKey)")!
        
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any], let jsonResponse = jsonResult else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
          
           // self.drawPath(from: polyLineString)
             self.drawPath(with: polyLineString)
        })
        task.resume()
        
         
        
    }*/
    
    
    //MARK:- Draw polygon
    
  /*  private func drawPath(with points : String){
        
        print("Drawing Polyline ", points)
        
        DispatchQueue.main.async {
            
            guard let path = GMSPath(fromEncodedPath: points) else { return }
            let polyline = GMSPolyline(path: path)
            polyline.map = nil
            polyLinePath = polyline
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .primary
            polyline.map = self.Googlemap
            var bounds = GMSCoordinateBounds()
            for index in 1...path.count() {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
            
        }
    }*/
    
 /*   func fetchRouteThreelocationFirst(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleMapKey)")!
        
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any], let jsonResponse = jsonResult else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            self.drawPath(with: polyLineString)
            
            self.fetchRouteThreelocationSecond(from: source, to: destination)
            
        })
        task.resume()
        
    }
    
    func fetchRouteThreelocationSecond(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D)
    {
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(destination.latitude),\(destination.longitude)&destination=\(Lat),\(Long)&sensor=false&mode=driving&key=\(googleMapKey)")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any], let jsonResponse = jsonResult else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes[0] as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            self.drawPath(with: polyLineString)
        })
        task.resume()
        
    }*/
    
    //  Set values
    
    private func setValues()
    {
      /*  https://maps.googleapis.com/maps/api/staticmap?center=Surin Beach, Choeng Thale, Thalang District, Phuket 83110&zoom=10.5&size=600x500&maptype=roadmap&markers=color:blue%7Clabel:A%7C7.9754731,98.2784667&markers=color:green%7Clabel:B%7C7.8367169,98.3483897&markers=color:red%7Clabel:C%7C8.1344747999999996,98.2989307&key=AIzaSyAw0ehACgYbZzhBLIhMn3D2U1ekSSX2uAc*/
      
    /*  https://maps.googleapis.com/maps/api/staticmap?center=Surin Beach, Choeng Thale, Thalang District, Phuket 83110&zoom=10.5&size=600x500&maptype=roadmap&markers=color:blue%7Clabel:A%7C7.9754731,98.2784667&markers=color:green%7Clabel:B%7C7.8367169,98.3483897&key=AIzaSyAw0ehACgYbZzhBLIhMn3D2U1ekSSX2uAc*/
        
       
      /*  let marker = GMSMarker()
        marker.appearAnimation = .none
        marker.snippet = self.dataSource?.s_address
        marker.icon =  #imageLiteral(resourceName: "start").resizeImage(newWidth: 30)
        marker.map = Googlemap
        marker.position = CLLocationCoordinate2D(latitude:(self.dataSource?.s_latitude)!, longitude: (self.dataSource?.s_longitude)!)
        
        let marker2 = GMSMarker()
        marker2.appearAnimation = .none
        marker2.snippet = self.dataSource?.d_address
        marker2.icon =  #imageLiteral(resourceName: "last").resizeImage(newWidth: 30)
        marker2.map = Googlemap
        marker2.position = CLLocationCoordinate2D(latitude:(self.dataSource?.d_latitude)!, longitude: (self.dataSource?.d_longitude)!)*/
        
        let way_pointaddress  =  self.dataSource?.way_points
        
        if way_pointaddress == nil || way_pointaddress == "Array"
        {
              view_waypoint.isHidden = true
            
            /*let Position = GMSCameraPosition.camera(withLatitude: (self.dataSource?.s_latitude)!, longitude: (self.dataSource?.s_longitude)!, zoom: 9.0)
            Googlemap.camera = Position
            
            
            let coordinateSource = CLLocationCoordinate2D(latitude: ((self.dataSource?.s_latitude)!), longitude: ((self.dataSource?.s_longitude)!))
            
            let coordinateDes = CLLocationCoordinate2D(latitude: ((self.dataSource?.d_latitude)!), longitude: ((self.dataSource?.d_longitude)!))
            
            fetchRouteTwolocation(from: coordinateSource, to: coordinateDes)*/
            
        }
        else
        {
              view_waypoint.isHidden = false
            
           /* let Position = GMSCameraPosition.camera(withLatitude: (self.dataSource?.s_latitude)!, longitude: (self.dataSource?.s_longitude)!, zoom: 9.0)
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
            
            
            let coordinateSource = CLLocationCoordinate2D(latitude: ((self.dataSource?.s_latitude)!), longitude: ((self.dataSource?.s_longitude)!))
            
            let coordinateDes = CLLocationCoordinate2D(latitude: ((self.dataSource?.d_latitude)!), longitude: ((self.dataSource?.d_longitude)!))
            
            fetchRouteThreelocationFirst(from: coordinateSource, to: coordinateDes)*/
        }
       
        let mapImage = self.dataSource?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                self.imageViewMap.image = image
                }
            }
        }
        
        self.labelProviderName.text = String.removeNil(self.dataSource?.provider?.first_name) + " " + String.removeNil(self.dataSource?.provider?.last_name)
        let imageUrl = String.removeNil(self.dataSource?.provider?.avatar).contains(WebConstants.string.http) ? self.dataSource?.provider?.avatar : Common.getImageUrl(for: self.dataSource?.provider?.avatar)
        self.providerIconUrl = imageUrl ?? ""
        Cache.image(forUrl: imageUrl) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewProvider.image = image
                }
            }
        }
        
        self.viewRating.rating = Float(self.dataSource?.rating?.provider_rating ?? 0)
        let comment = self.dataSource?.rating?.provider_comment
        self.textViewComments.text = comment?.count == 0 ? Constants.string.noComments.localize() : comment
        self.labelSourceLocation.text = self.dataSource?.s_address
        self.labelDestinationLocation.text = self.dataSource?.d_address
        
        let way_point  =  self.dataSource?.way_points
        
        if way_point == nil || way_pointaddress == "Array"
        {
            self.labelWayLocation.isHidden = true
        }
        else
        {
            self.labelWayLocation.isHidden = false
            
            let jsonData = way_point!.data(using: .utf8)!
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableLeaves)
            
            let Arry = dictionary as! NSArray
            let Dicdata = Arry[0] as! NSDictionary
//            self.labelWayLocation.text = Dicdata.value(forKey: "address")as? String
            self.labelDestinationLocation.text = Dicdata.value(forKey: "address")as? String
            self.labelWayLocation.text = self.dataSource?.d_address
        }
       
        self.labelPayVia.text = self.dataSource?.payment_mode?.rawValue.localize()
        self.imageViewPayVia.image = self.dataSource?.payment_mode == .CASH ? #imageLiteral(resourceName: "money_icon") : #imageLiteral(resourceName: "visa")
        self.labelBookingId.text = self.dataSource?.booking_id
        
        if let dateObject = Formatter.shared.getDate(from: self.isUpcomingTrips ? self.dataSource?.schedule_at : self.dataSource?.assigned_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            self.labelTime.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hh_mm_a)
        }
        self.labelPrice.text = Formatter.shared.appPriceFormat(string: "\(self.dataSource?.payment?.total ?? 0)")
//        self.labelPrice.text = String.removeNil(User.main.currency)+" \(self.dataSource?.payment?.total ?? 0)"
        
        self.buttonDispute.setTitle(self.dataSource?.dispute != nil ? Constants.string.disputeStatus.localize() : Constants.string.dispute.localize(), for: .normal)
        self.buttonLostItem.setTitle(self.dataSource?.lostitem != nil ? Constants.string.lostItemStatus.localize() : Constants.string.lostItem.localize(), for: .normal)
        
        // Set Recurrent Dates
        if dataSource?.repeated != nil {
            imageViewWeek0.image = ((dataSource?.repeated!.contains(0))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek1.image = ((dataSource?.repeated!.contains(1))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek2.image = ((dataSource?.repeated!.contains(2))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek3.image = ((dataSource?.repeated!.contains(3))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek4.image = ((dataSource?.repeated!.contains(4))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek5.image = ((dataSource?.repeated!.contains(5))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            imageViewWeek6.image = ((dataSource?.repeated!.contains(6))! ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
            lbWeek0.text = Constants.string.Sunday.localize()
            lbWeek1.text = Constants.string.Monday.localize()
            lbWeek2.text = Constants.string.Tuesday.localize()
            lbWeek3.text = Constants.string.Wednesday.localize()
            lbWeek4.text = Constants.string.Thursday.localize()
            lbWeek5.text = Constants.string.Friday.localize()
            lbWeek6.text = Constants.string.Saturday.localize()
        }
        
//        if (dataSource?.status == .scheduled && dataSource?.manual_assigned_at == nil && dataSource?.provider != nil && dataSource?.provider?.id != 0) {
//            buttonViewReciptAndCall.isHidden = false
//        } else {
//            buttonViewReciptAndCall.isHidden = true
//        }
        
        buttonViewReciptAndCall.isHidden = isUpcomingTrips
        
        if isUpcomingTrips {
//            self.labelPrice.text = Formatter.shared.appPriceFormat(string:"\(dataSource?.estimated?.estimated_fare ?? 0.0)")
            self.labelPrice.text = Formatter.shared.appPriceFormat(string: "\(self.dataSource?.total_price ?? 0)")
        }
    }
    
    //  Cancel Ride
    
    @IBAction private func buttonCancelRideAction(sender : UIButton) {
        
        if isUpcomingTrips, self.dataSource?.id != nil {
            
            self.loader.isHidden = false
            // Cancel Request
            let request = Request()
            request.request_id = self.dataSource?.id
            self.presenter?.post(api: .cancelRequest, data: request.toData())
        }
        
    }
    
    //  Call and View Recipt
    
    @IBAction private func buttonCallAndReciptAction(sender : UIButton) {
        
        if isUpcomingTrips {
            let number = "\(self.dataSource?.provider?.country_code ?? "")\(self.dataSource?.provider?.mobile ?? "")"
            if number != "" {
                Common.call(to: number)
            }
        } else {
            self.showRecipt()
        }
        
    }
    
    @objc func tapMore() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.viewMore?.alpha == 0.0 {
                self.viewMore.alpha = 1.0
            }else{
                self.viewMore.alpha = 0.0
            }
        })
    }
    
    @IBAction private func buttonDisputeAction(sender : UIButton) {
        self.viewMore.alpha = 0.0
        if self.dataSource?.dispute != nil {
            //            showAlert(message: Constants.string.disputecreated.localize(), okHandler: nil, fromView: self)
            showDisputeStatus(isDispute: true)
            return
        }
        self.showDisputeView(isDispute:true)
        
    }
    
    @IBAction private func buttonLostItemAction(sender : UIButton) {
        self.viewMore.alpha = 0.0
        if self.dataSource?.lostitem != nil {
            self.showDisputeStatus(isDispute: false)
            return
        }
        self.showDisputeView(isDispute: false)
    }
    
    //  Show Recipt
    private func showRecipt() {
        
        if let viewReciptView = Bundle.main.loadNibNamed(XIB.Names.InvoiceView, owner: self, options: [:])?.first as? InvoiceView, self.dataSource != nil {
            viewReciptView.isShowingRecipt = true
            viewReciptView.set(request: self.dataSource!)
            viewReciptView.frame = CGRect(origin: CGPoint(x: 0, y: (UIApplication.shared.keyWindow?.frame.height)!-viewReciptView.frame.height), size: CGSize(width: self.view.frame.width, height: viewReciptView.frame.height))
            self.viewRecipt = viewReciptView
            UIApplication.shared.keyWindow?.addSubview(viewReciptView)
            viewReciptView.show(with: .bottom) { [weak self] in
                self?.addBlurView()
            }
            viewReciptView.onClickPaynow = { [unowned self]_ in
                self.hideRecipt()
            }
            viewReciptView.onDoneClick = { [unowned self]_ in
                self.hideRecipt()
            }
        }
        
    }
    
    func showDisputeView(isDispute:Bool){
        if self.disputeView == nil, let disputeView = Bundle.main.loadNibNamed(XIB.Names.DisputeLostItemView, owner: self, options: [:])?.first as? DisputeLostItemView {
            let disputeHeight = isDispute ? disputeView.frame.height : 250
            disputeView.frame = CGRect(x: 0, y: self.view.frame.height-disputeHeight, width: self.view.frame.width, height: disputeHeight)
            self.disputeView = disputeView
            if isDispute {
                disputeView.set(value: self.disputeList, isDispute: isDispute, requestID: self.requestId ?? 0,providerID: self.dataSource?.provider?.id ?? 0)
            }else{
                disputeView.set(value: [], isDispute: isDispute, requestID: self.requestId ?? 0,providerID: self.dataSource?.provider?.id ?? 0)
            }
            
            UIApplication.shared.keyWindow?.addSubview(disputeView)
            self.disputeView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeView?.onClickClose = { closed in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeView?.alpha = 0
            }, completion: { (_) in
                self.disputeView?.removeFromSuperview()
                self.disputeView = nil
            })
        }
    }
    
    private func showDisputeStatus(isDispute:Bool){
        if self.disputeStatusView == nil, let disputeStatusView = Bundle.main.loadNibNamed(XIB.Names.DisputeStatusView, owner: self, options: [:])?.first as? DisputeStatusView {
            
            disputeStatusView.frame = CGRect(x: 0, y: self.view.frame.height-disputeStatusView.frame.height, width: self.view.frame.width, height: disputeStatusView.frame.height)
            self.disputeStatusView = disputeStatusView
            
            if isDispute {
                disputeStatusView.setDispute(dispute: (self.dataSource?.dispute ?? Dispute()))
            }else{
                disputeStatusView.setLostItem(lostItem: (self.dataSource?.lostitem ?? Lostitem()))
            }
            
            UIApplication.shared.keyWindow?.addSubview(disputeStatusView)
            self.disputeStatusView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                            self.disputeStatusView?.transform = .identity },
                           completion: { Void in()  })
        }
        self.disputeStatusView?.onClickClose = { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.disputeStatusView?.alpha = 0
            }, completion: { (_) in
                self.disputeStatusView?.removeFromSuperview()
                self.disputeStatusView = nil
            })
        }
    }
    
    private func addBlurView() {
        
        self.blurView = UIView(frame: UIScreen.main.bounds)
        self.blurView?.alpha = 0
        self.blurView?.backgroundColor = .black
        self.blurView?.isUserInteractionEnabled = true
        self.view.addSubview(self.blurView!)
        self.blurView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideRecipt)))
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.6
        })
        
    }
    
    //  Remove Recipt
    @IBAction private func hideRecipt() {
        
        self.viewRecipt?.dismissView(onCompletion: {
            self.viewRecipt = nil
            self.blurView?.removeFromSuperview()
        })
    }
}

// MARK:- Postview Protocol

extension YourTripsDetailViewController: PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message.localize(), okHandler: nil, fromView: self)
        }
    }
    
    func getRequestArray(api: Base, data: [Request]) {
        
        if (api == .upcomingTripDetail || api == .pastTripDetail) {
            if data.count>0 {
                self.dataSource = data.first
            }
            
            DispatchQueue.main.async {
                self.loader.isHidden = true
                self.setValues()
                self.tableView.reloadData()
            }
        }
    }
    
    func getRequest2Array(api: Base, data: [Request2]) {
        print("getRequest2Array=>", data)
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setValues()
            self.tableView.reloadData()
        }
    }
    
    func getDisputeList(api: Base, data: [DisputeList]) {
        for disputeName in data {
            self.disputeList.append(disputeName.dispute_name ?? "")
        }
    }
    
    func success(api : Base, message : String?) {
        self.loader.isHidden = true
        if api == .updateRecurrent {
            showAlert(message: message?.localize(), okHandler: nil, fromView: self)
        } else if api == .cancelRequest {
            showAlert(message: message?.localize(), okHandler: {
                self.navigationController?.popViewController(animated: true)
            }, fromView: self)
        }
    }
    
}

//// MARK:- ScrollView Delegate
//
//extension YourTripsDetailViewController {
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        guard scrollView.contentOffset.y<0 else { return }
//
//        let inset = abs(scrollView.contentOffset.y/imageViewMap.frame.height)
//
//        self.imageViewMap.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
//
//    }
//
//}

extension YourTripsDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if isUpcomingTrips && indexPath.row == 3 {
            return 0
        }
        if indexPath.row >= 4 {
            if !isUpcomingTrips { return 0 }
            if dataSource?.repeated == nil || dataSource?.repeated?.count == 0 {
                return 0
            }
        }
        return heightArray[indexPath.row]
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 4 {
            if dataSource?.repeated?.contains(indexPath.row - 4) == true {
                let index = (dataSource?.repeated?.firstIndex(of: indexPath.row - 4))!
                dataSource?.repeated?.remove(at: index)
            } else {
                dataSource?.repeated?.append(indexPath.row - 4)
            }
            //        self.tableView.reloadData()
            self.setValues()
            barbtnItemUpdate?.isEnabled = true
        }
        self.tableView .deselectRow(at: indexPath, animated: true)
    }
    
}
