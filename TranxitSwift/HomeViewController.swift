    //
    //  HomeViewController.swift
    //  User
    //
    //  Created by CSS on 02/05/18.
    //  Copyright © 2018 Appoets. All rights reserved.
    //
    
    import UIKit
    import KWDrawerController
    import GoogleMaps
    import GooglePlaces
    import DateTimePicker
    import Firebase
    import MapKit
    //import PaymentSDK
    import Reachability
    import BraintreeDropIn
    import Braintree
    
    var riderStatus : RideStatus = .none // Provider Current Status
    
    class HomeViewController: UIViewController {
        
        
        //MARK:- IBOutlets
        var DurationFloat:Float = 0.0
        
        var Minutes:Int = 0
        
        var Hours:Int = 0
        
        @IBOutlet private var viewSideMenu : UIView!
        @IBOutlet private var viewCurrentLocation : UIView!
        @IBOutlet weak var viewMapOuter : UIView!
        @IBOutlet weak private var viewFavouriteSource : UIView!
        @IBOutlet weak private var viewFavouriteDestination : UIView!
        @IBOutlet weak private var viewFavouriteStop : UIView!
        @IBOutlet weak private var imageViewFavouriteSource : ImageView!
        @IBOutlet weak private var imageViewFavouriteDestination : ImageView!
        @IBOutlet weak private var imageViewFavouriteStop : ImageView!
        
        @IBOutlet weak var viewSourceLocation : UIView!
        @IBOutlet weak var viewDestinationLocation : UIView!
        @IBOutlet weak var viewStopLocation : UIView!
        
        @IBOutlet weak private var viewAddress : UIView!
        @IBOutlet weak var viewAddressOuter : UIView!
        @IBOutlet weak var textFieldSourceLocation : UITextField!
        @IBOutlet weak private var textFieldDestinationLocation : UITextField!
        @IBOutlet weak private var imageViewMarkerCenter : UIImageView!
        @IBOutlet weak private var imageViewSideBar : UIImageView!
        @IBOutlet weak var buttonSOS : UIButton!
        @IBOutlet weak private var viewHomeLocation : UIView!
        @IBOutlet weak private var viewWorkLocation : UIView!
        @IBOutlet weak var viewChangeDestinaiton : UIView!
        @IBOutlet weak var viewLocationDot : UIView!
        @IBOutlet weak var viewLocationButtons : UIStackView!
        @IBOutlet weak var buttonWithoutDest:UIButton! //not used
        @IBOutlet var constraint : NSLayoutConstraint!
        
        @IBOutlet weak var textStopLocation : UITextField!
        @IBOutlet weak var viewChangeStop : UIView!
        //MARK:- Local Variable
        
        var withoutDest:Bool = false
        var currentRequestId = 0
        var pathIndex = 0
        var isInvoiceShowed:Bool = false
        private var isUserInteractingWithMap = false // Boolean to handle Mapview User interaction
        private var isScheduled = false // Flag For Schedule
        var isTapDone:Bool = false
        
        var sourceLocationDetail : Bind<LocationDetail>? = Bind<LocationDetail>(nil)
        var currentLocation = Bind<LocationCoordinate>(defaultMapLocation)
        
        var providerLastLocation = LocationCoordinate()
        //var serviceSelectionView : ServiceSelectionView?
        var estimationFareView : RequestSelectionView?
        var couponView : CouponView?
        var locationSelectionView : LocationSelectionView?
        var requestLoaderView : LoaderView?
        var invoiceView : InvoiceView?
        var ratingView : RatingView?
        var rideNowView : RideNowView?
        var floatyButton : Floaty?
        var reasonView : ReasonView?
        var timerETA : Timer?
        var cancelReason = [ReasonEntity]()
        var markersProviders = [GMSMarker]()
        var reRouteTimer : Timer?
        var listOfProviders : [Provider]?
        var selectedService : Service?
        var mapViewHelper : GoogleMapsHelper?
        final var currentProvider: Provider?
        var recurrentReq = Array<Int>()
        var lbRecurrentReq : UILabel?
        var datePicker : DateTimePicker?
        
        var POIpriceLogic : checkPoiPriceLogic?
        
        var Latituget :Float = 0.0
        var Longitudget :Float = 0.0
        var SelectLocation : SelectLocation?
        
        var istap:Bool = false
        
        @IBOutlet weak var view_line : UIView!
        @IBOutlet weak var view_squer : UIView!
        
        
        // private let transition = CircularTransition()  // Translation to for location Tap
        // private var favouriteViewSource : LottieView?
        // private var favouriteViewDestination : LottieView?
        //  private var favouriteLocations : LocationService? //[(type : String,address: [LocationDetail])]() // Favourite Locations of User
        
        lazy var markerProviderLocation : GMSMarker = {  // Provider Location Marker
            let marker = GMSMarker()
            let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            imageView.contentMode =  .scaleAspectFit
            imageView.image = #imageLiteral(resourceName: "map-vehicle-icon-black")
            marker.iconView = imageView
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = self.mapViewHelper?.mapView
            return marker
        }()
        
        private var selectedLocationView = UIView() // View to change the location pinpoint
        {
            didSet{
                if !([viewSourceLocation, viewDestinationLocation].contains(selectedLocationView)) {
                    [viewSourceLocation, viewDestinationLocation].forEach({ $0?.transform = .identity })
                }
            }
        }
        
        var isOnBooking = false {  // Boolean to handle back using side menu button
            didSet {
                self.imageViewSideBar.image = isOnBooking ? #imageLiteral(resourceName: "back-icon") : #imageLiteral(resourceName: "menu_icon")
            }
        }
        
        private var isSourceFavourited = false {  // Boolean to handle favourite source location
            didSet{
                self.isAddFavouriteLocation(in: self.viewFavouriteSource, isAdd: isSourceFavourited)
            }
        }
        
        private var isDestinationFavourited = false { // Boolean to handle favourite destination location
            didSet{
                self.isAddFavouriteLocation(in: self.viewFavouriteDestination, isAdd: isDestinationFavourited)
            }
        }
        private var isSecondStopFavourited = false { // Boolean to handle favourite destination location
            didSet{
                self.isAddFavouriteLocation(in: self.viewFavouriteDestination, isAdd: isDestinationFavourited)
            }
        }
        
        var destinationLocationDetail : LocationDetail? {  // Destination Location Detail
            didSet{
                DispatchQueue.main.async {
                    self.isDestinationFavourited = false // reset favourite location on change
                    if self.destinationLocationDetail == nil {
                        self.isDestinationFavourited = false
                    }
                    self.textFieldDestinationLocation.text = (self.destinationLocationDetail?.address.removingWhitespaces().isEmpty ?? true) ? nil : self.destinationLocationDetail?.address
                }
            }
        }
        
        
        var secondStopdetail : LocationDetail? {  // Destination Location Detail
            didSet{
                DispatchQueue.main.async {
                    self.isDestinationFavourited = false // reset favourite location on change
                    if self.secondStopdetail == nil {
                        self.isSecondStopFavourited = false
                    }
                    self.textStopLocation.text = (self.secondStopdetail?.address.removingWhitespaces().isEmpty ?? true) ? nil : self.secondStopdetail?.address
                    
                    if self.textStopLocation.text?.count == 0
                    {
                        self.viewStopLocation.isHidden = true
                        self.view_line.isHidden = true
                        self.view_squer.isHidden = true
                    }
                    
                    
                }
            }
        }
        
        var rideStatusView : RideStatusView? {
            didSet {
                if self.rideStatusView == nil {
                    self.floatyButton?.removeFromSuperview()
                }
            }
        }
        
        lazy var loader  : UIView = {
            return createActivityIndicator(self.view)
        }()
        
        //MARKERS
        
        var sourceMarker : GMSMarker = {
            let marker = GMSMarker()
            marker.title = Constants.string.ETA.localize()
            marker.appearAnimation = .none
            marker.icon =  #imageLiteral(resourceName: "start").resizeImage(newWidth: 30)
            return marker
        }()
        
        var destinationMarker : GMSMarker = {
            let marker = GMSMarker()
            marker.appearAnimation = .none
            marker.icon =  #imageLiteral(resourceName: "last").resizeImage(newWidth: 30)
            return marker
        }()
        var  StopMarker : GMSMarker = {
            let marker = GMSMarker()
            marker.appearAnimation = .none
            marker.title = "Stop"
            marker.icon =  #imageLiteral(resourceName: "stop").resizeImage(newWidth: 30)
            return marker
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.initialLoads()
            self.localize()
            driverAppExist()
            
        }
        
        
        //MARK: - NotificationSelectmap
        
        @objc func NotificationSelectmap(notification: NSNotification)
        {
            
            self.SelectLocation = Bundle.main.loadNibNamed(XIB.Names.SelectLocation, owner: self, options: [:])?.first as? SelectLocation
            
            self.SelectLocation?.frame = self.view.bounds
            
            // self.SelectLocation?.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.SelectLocation!.frame.height))
            
            self.SelectLocation?.clipsToBounds = false
            self.SelectLocation?.show(with: .bottom, completion: nil)
            self.view.addSubview(self.SelectLocation!)
            //self.SelectLocation?.btn_confirm
            
            self.SelectLocation?.btn_confirm.addTarget(self, action: #selector(btn_confime_address_Click(_:)), for: .touchUpInside)
            
            self.SelectLocation?.btn_currentlocation.addTarget(self, action: #selector(self.getCurrentLocationStop), for: .touchUpInside)
            
            
            self.SelectLocation?.SelectStopMap?.delegate = self
            
            
            //self.SelectLocation?.SelectStopMap?.settings.myLocationButton = true
            self.SelectLocation?.SelectStopMap?.isMyLocationEnabled = true
            
            
            let cameraposition = GMSCameraPosition.camera(withLatitude:(self.currentLocation.value?.latitude)!, longitude:(self.currentLocation.value?.longitude)!, zoom: 15)
            self.SelectLocation?.SelectStopMap?.animate(to:cameraposition)
            self.SelectLocation?.SelectStopMap?.camera = cameraposition
            
            let circleView = UIImageView()
            circleView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            circleView.contentMode = .scaleAspectFit
            
            
            if (self.locationSelectionView?.selctAddress == 1)
            {
                circleView.image =  #imageLiteral(resourceName: "start")
            }
            else if (self.locationSelectionView?.selctAddress == 2)
            {
                if (self.locationSelectionView!.Addstop == true)
                {
                    circleView.image =  #imageLiteral(resourceName: "stop")
                }
                else
                {
                    circleView.image =  #imageLiteral(resourceName: "last")
                }
            }
            else if (self.locationSelectionView?.selctAddress == 3)
            {
                circleView.image =  #imageLiteral(resourceName: "last")
            }
            
            
            
            self.SelectLocation?.SelectStopMap?.addSubview(circleView)
            self.SelectLocation?.SelectStopMap?.bringSubviewToFront(circleView)
            
            circleView.translatesAutoresizingMaskIntoConstraints = false
            let heightConstraint = NSLayoutConstraint(item: circleView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            let widthConstraint = NSLayoutConstraint(item: circleView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
            let centerXConstraint = NSLayoutConstraint(item: circleView, attribute: .centerX, relatedBy: .equal, toItem: self.SelectLocation?.SelectStopMap, attribute: .centerX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: circleView, attribute: .centerY, relatedBy: .equal, toItem: self.SelectLocation?.SelectStopMap, attribute: .centerY, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([heightConstraint, widthConstraint, centerXConstraint, centerYConstraint])
            
            view.updateConstraints()
            
            
        }
        @IBAction func btn_confime_address_Click(_ sender: Any)
        {
            let getaddress =  self.geoCodeUsingAddress()
            self.SelectLocation?.lbl_address.text = getaddress
            
            UIView.animate(withDuration: 0.3, animations: {
                
            }) { (_) in
                self.SelectLocation?.isHidden = true
                self.SelectLocation?.removeFromSuperview()
            }
            
            
            self.destinationLocationDetail = LocationDetail(getaddress, LocationCoordinate(latitude: CLLocationDegrees(Latituget), longitude: CLLocationDegrees(Longitudget)))
            
            if (self.locationSelectionView?.selctAddress == 1)
            {
                self.locationSelectionView?.address?.source?.value =  self.destinationLocationDetail
                self.locationSelectionView?.textFieldSource.text = getaddress
            }
            else if (self.locationSelectionView?.selctAddress == 2)
            {
                self.locationSelectionView?.address?.destination =  self.destinationLocationDetail
                self.locationSelectionView?.textFieldDestination.text = getaddress
            }
            else if (self.locationSelectionView?.selctAddress == 3)
            {
                self.locationSelectionView?.txt_stop2.text = getaddress
                self.locationSelectionView?.address?.stop2 =  self.destinationLocationDetail
            }
            
            self.locationSelectionView?.autoFill(with: self.destinationLocationDetail)
            
            
        }
        func geoCodeUsingAddress() -> String {
            
            var address = ""
            
            let addressstr = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(Latituget),\(Longitudget)&key=\(googleMapKey)"
            
            let urlStr  = addressstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let searchURL: NSURL = NSURL(string: urlStr! as String)!
            do {
                let newdata = try Data(contentsOf: searchURL as URL)
                if let responseDictionary = try JSONSerialization.jsonObject(with: newdata, options: []) as? NSDictionary {
                    print(responseDictionary)
                    let array = responseDictionary.object(forKey: "results") as! NSArray
                    
                    if array.count > 0
                    {
                        
                        let dic = array[0] as! NSDictionary
                        //  let locationDic = (dic.object(forKey: "geometry") as! NSDictionary).object(forKey: "location") as! NSDictionary
                        
                        
                        address = (dic.value(forKey:"formatted_address") as? String)!
                        
                        print(address)
                        
                        
                        // dimpal
                        
                        
                        
                    }
                    
                }} catch {
            }
            
            return address
        }
        
        
        
        override func viewWillAppear(_ animated: Bool)
        {
            super.viewWillAppear(animated)
            self.viewWillAppearCustom()
            
            // Chat push redirection
            NotificationCenter.default.addObserver(self, selector: #selector(NotificationSelectmap), name: NSNotification.Name(rawValue: "NotificationforSelectmap"), object: nil)
            // Chat push redirection
            NotificationCenter.default.addObserver(self, selector: #selector(isChatPushRedirection), name: NSNotification.Name("ChatPushRedirection"), object: nil)
            // Voice push redirection
            NotificationCenter.default.addObserver(self, selector: #selector(isVoicePushRedirection), name: NSNotification.Name("VoicePushRedirection"), object: nil)
        }
        
        @objc func isVoicePushRedirection()
        {
            
            if let VoicePage = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.VoiceChatViewController) as? VoiceChatViewController {
                VoicePage.set(connected: true, user: self.currentProvider ?? Provider(), requestId: User.main.id!)
                let navigation = UINavigationController(rootViewController: VoicePage)
                navigation.setNavigationBarHidden(true, animated: false)
                self.present(navigation, animated: true, completion: nil)
            }
        }
        
        @objc func isChatPushRedirection()
        {
            
            if let ChatPage = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
                ChatPage.set(user: self.currentProvider ?? Provider(), requestId: self.currentRequestId)
                let navigation = UINavigationController(rootViewController: ChatPage)
                self.present(navigation, animated: true, completion: nil)
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
            NotificationCenter.default.removeObserver(self)
        }
        
        override func didReceiveMemoryWarning()
        {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        override func viewWillLayoutSubviews()
        {
            super.viewWillLayoutSubviews()
            
            self.viewLayouts()
        }
        
    }
    
    
    
    // MARK:- Local  Methods
    
    extension HomeViewController {
        
        private func initialLoads() {
            
            self.addMapView()
            self.getFavouriteLocations()
            self.viewSideMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sideMenuAction)))
            self.navigationController?.isNavigationBarHidden = true
            self.viewFavouriteDestination.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            self.viewFavouriteSource.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            [self.viewSourceLocation, self.viewDestinationLocation,self.viewStopLocation].forEach({ $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.locationTapAction(sender:))))})
            self.currentLocation.bind(listener: { (locationCoordinate) in
                // TODO:- Handle Current Location
                if locationCoordinate != nil {
                    self.mapViewHelper?.moveTo(location: locationCoordinate!, with: self.viewMapOuter.center)
                    self.selectedLocationView = self.viewSourceLocation
                    self.sourceMarker.map = self.mapViewHelper?.mapView
                    self.sourceMarker.position = locationCoordinate!
                }
            })
            self.viewCurrentLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.getCurrentLocation)))
            self.sourceLocationDetail?.bind(listener: { (locationDetail) in
                //                if locationDetail == nil {
                //                    self.isSourceFavourited = false
                //                }
                DispatchQueue.main.async {
                    self.isSourceFavourited = false // reset favourite location on change
                    self.textFieldSourceLocation.text = locationDetail?.address
                    self.textFieldSourceLocation.textColor = .black
                }
            })
            // destination pin
            
            
            self.viewDestinationLocation.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.checkForProviderStatus()
            self.buttonSOS.isHidden = true
            self.buttonSOS.addTarget(self, action: #selector(self.buttonSOSAction), for: .touchUpInside)
            self.setDesign()
            NotificationCenter.default.addObserver(self, selector: #selector(self.observer(notification:)), name: .providers, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
            
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowRateView(info:)), name: .UIKeyboardWillShow, object: nil)
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideRateView(info:)), name: .UIKeyboardWillHide, object: nil)      }
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.presenter?.get(api: .getProfile, parameters: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.presenter?.get(api: .cancelReason, parameters: nil)
            })
            //MARK :Hide it , android is not have
            self.viewFavouriteSource.isHidden = true
            self.viewFavouriteDestination.isHidden = true
            self.viewChangeDestinaiton.isHidden = true
            self.viewChangeDestinaiton.backgroundColor = .primary
            
            self.viewFavouriteStop.isHidden = true
            self.viewChangeStop.isHidden = true
            self.viewChangeStop.backgroundColor = .primary
            
            //            self.buttonWithoutDest.addTarget(self, action: #selector(tapWithoutDest), for: .touchUpInside)
            self.reRouteTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (_) in
                if isRerouteEnable {
                    self.drawPolyline(isReroute: true)
                    print("Reroute Timer")
                }
                if riderStatus == .pickedup {
                    self.updateCamera()
                }
            })
        }
        
        //  viewWillAppearCustom
        
        private func viewWillAppearCustom() {
            isInvoiceShowed = false
            self.navigationController?.isNavigationBarHidden = true
            self.localize()
            self.getFavouriteLocationsFromLocal()
            self.getAllProviders()
        }
        
        //  View Will Layouts
        
        private func viewLayouts() {
            
            self.viewCurrentLocation.makeRoundedCorner()
            self.mapViewHelper?.mapView?.frame = viewMapOuter.bounds
            self.viewSideMenu.makeRoundedCorner()
            self.navigationController?.isNavigationBarHidden = true
        }
        
        @IBAction private func getCurrentLocation(){
            
            self.viewCurrentLocation.addPressAnimation()
            if currentLocation.value != nil {
                self.mapViewHelper?.getPlaceAddress(from: currentLocation.value!, on: { (locationDetail) in  // On Tapping current location, set
                    if self.selectedLocationView == self.viewSourceLocation
                    {
                        self.sourceLocationDetail?.value = locationDetail
                    }
                    else if self.selectedLocationView == self.viewDestinationLocation {
                        self.destinationLocationDetail = locationDetail
                    }
                })
                self.mapViewHelper?.moveTo(location: self.currentLocation.value!, with: self.viewMapOuter.center)
            }
        }
        @IBAction private func getCurrentLocationStop(){
            
            
            let cameraposition = GMSCameraPosition.camera(withLatitude:(self.currentLocation.value?.latitude)!, longitude:(self.currentLocation.value?.longitude)!, zoom: 15)
            self.SelectLocation?.SelectStopMap?.animate(to:cameraposition)
            self.SelectLocation?.SelectStopMap?.camera = cameraposition
            
        }
        //  Localize
        
        private func localize(){
            
            self.textFieldSourceLocation.placeholder = Constants.string.source.localize()
            self.textFieldDestinationLocation.placeholder = Constants.string.destination.localize()
            self.textStopLocation.placeholder = Constants.string.Addstop.localize()
            
            //            self.buttonWithoutDest.setTitle(Constants.string.withoutDest, for: .normal)
            
        }
        
        func getAllProviders() {
            
            
            
            if currentLocation.value?.latitude != nil || currentLocation.value?.longitude != nil {
                let json = [Constants.string.latitude : self.sourceLocationDetail?.value?.coordinate.latitude ?? defaultMapLocation.latitude, Constants.string.longitude : self.sourceLocationDetail?.value?.coordinate.longitude ?? defaultMapLocation.longitude] as [String : Any]
                self.presenter?.get(api: .getProviders, parameters: json)
            }
            
        }
        
        //  Set Design
        
        private func setDesign() {
            
            Common.setFont(to: textFieldSourceLocation)
            Common.setFont(to: textFieldDestinationLocation)
            Common.setFont(to: textStopLocation)
            //            Common.setFont(to: buttonWithoutDest)
            //            Common.setFont(to: buttonWithoutDest, isTitle: true, size: 17)
            //            buttonWithoutDest.titleLabel?.textColor = .primary
        }
        
        //  Add Mapview
        
        private func addMapView(){
            
            self.mapViewHelper = GoogleMapsHelper()
            self.mapViewHelper?.getMapView(withDelegate: self, in: self.viewMapOuter)
            self.getCurrentLocationDetails()
        }
        // Getting current location detail
        private func getCurrentLocationDetails() {
            self.mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
                if self.sourceLocationDetail?.value == nil {
                    self.mapViewHelper?.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in
                        self.sourceLocationDetail?.value = locationDetail
                    })
                }
                self.currentLocation.value = location.coordinate
            })
        }
        
        
        
        func showRideNowWithoutDest(with source : [Service]) {
            
            
            if self.rideNowView == nil {
                
                self.rideNowView = Bundle.main.loadNibNamed(XIB.Names.RideNowView, owner: self, options: [:])?.first as? RideNowView
                self.rideNowView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.rideNowView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.rideNowView!.frame.height))
                self.rideNowView?.clipsToBounds = false
                self.rideNowView?.show(with: .bottom, completion: nil)
                self.view.addSubview(self.rideNowView!)
                self.isOnBooking = true
                self.rideNowView?.onClickProceed = { [weak self] service in
                    self?.showEstimationView(with: service)
                }
                self.rideNowView?.onClickService = { [weak self] service in
                    guard let self = self else {return}
                    self.sourceMarker.snippet = service?.pricing?.time
                    self.mapViewHelper?.mapView?.selectedMarker = (service?.pricing?.time) == nil ? nil : self.sourceMarker
                    self.selectedService = service
                    self.showProviderInCurrentLocation(with: self.listOfProviders!, serviceTypeID: (service?.id)!)
                }
                
            }
            self.rideNowView?.setAddress(source: currentLocation.value!, destination: currentLocation.value!)
            self.rideNowView?.set(source: source)
        }
        
        //  Observer
        
        @objc private func observer(notification : Notification) {
            if notification.name == .providers, let data = notification.userInfo?[Notification.Name.providers.rawValue] as? [Provider] {
                self.listOfProviders = data
                self.showProviderInCurrentLocation(with: self.listOfProviders!, serviceTypeID:0)
            }
        }
        
        //  Get Favourite Location From Local
        
        private func getFavouriteLocationsFromLocal() {
            
            let favouriteLocationFromLocal = CoreDataHelper().favouriteLocations()
            [self.viewHomeLocation, self.viewWorkLocation].forEach({
                $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewLocationButtonAction(sender:))))
                $0?.isHidden = true
            })
            for location in favouriteLocationFromLocal
            {
                switch location.key {
                case CoreDataEntity.work.rawValue where location.value is Work:
                    if let workObject = location.value as? Work, let address = workObject.address {
                        if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.work}) {
                            favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude)))
                        } else {
                            favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude))))
                        }
                        self.viewWorkLocation.isHidden = false
                    }
                case CoreDataEntity.home.rawValue where location.value is Home:
                    if let homeObject = location.value as? Home, let address = homeObject.address {
                        if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.home}) {
                            favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude)))
                        }
                        else {
                            favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude))))
                        }
                        self.viewHomeLocation.isHidden = false
                    }
                default:
                    break
                    
                }
            }
        }
        
        //  View Location Action
        
        @IBAction private func viewLocationButtonAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            if senderView == viewHomeLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.home.rawValue] as? Home, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            } else if senderView == viewWorkLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.work.rawValue] as? Work, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            }
            
            if destinationLocationDetail == nil { // No Previous Location Avaliable
                self.showLocationView()
            } else {
                print("Polydraw 1")
                self.drawPolyline(isReroute: false) // Draw polyline between source and destination
                
                //Dimpal 10 Dec
                self.getServicesList(home: "home") // get Services
                //                self.withoutDest = false
            }
            
        }
        
        
        //  Favourite Location Action
        
        @IBAction private func favouriteLocationAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            senderView.addPressAnimation()
            if senderView == viewFavouriteSource {
                self.isSourceFavourited = self.sourceLocationDetail?.value != nil ? !self.isSourceFavourited : false
            } else if senderView == viewFavouriteDestination {
                self.isDestinationFavourited = self.destinationLocationDetail != nil ? !self.isDestinationFavourited : false
            }
        }
        
        //  Favourite Location Action
        
        private func isAddFavouriteLocation(in viewFavourite : UIView, isAdd : Bool) {
            
            if viewFavourite == viewFavouriteSource {
                self.imageViewFavouriteSource.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
            } else {
                self.imageViewFavouriteDestination.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
            }
            self.favouriteLocationApi(in: viewFavourite, isAdd: isAdd) // Send to Api Call
            
        }
        
        //  Favourite Location Action
        
        @IBAction private func locationTapAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view  else { return }
            if riderStatus != .none, senderView == viewSourceLocation { // Ignore if user is onRide and trying to change source location
                return
            }
            self.selectedLocationView.transform = CGAffineTransform.identity
            
            if self.selectedLocationView == senderView {
                self.showLocationView()
            }
            else
            {
                self.selectedLocationView = senderView
                
                if senderView == self.viewDestinationLocation ||  senderView == self.viewStopLocation
                {
                    self.showLocationView()
                }
                else
                {
                    self.selectionViewAction(in: senderView)
                }
            }
            
            self.selectedLocationView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.viewAddress.bringSubviewToFront(self.selectedLocationView)
            // self.showLocationView()
        }
        
        
        //  Show Marker on Location
        
        private func selectionViewAction(in currentSelectionView : UIView){
            
            if currentSelectionView == self.viewSourceLocation {
                
                if let coordinate = self.sourceLocationDetail?.value?.coordinate{
                    self.plotMarker(marker: &sourceMarker, with: coordinate)
                    print("Source Marker - ", coordinate.latitude, " ",coordinate.longitude)
                }
                else {
                    self.showLocationView()
                }
            }
            else if currentSelectionView == self.viewDestinationLocation {
                
                if let coordinate = self.destinationLocationDetail?.coordinate{
                    self.plotMarker( marker: &destinationMarker, with: coordinate)
                    print("Destination Marker - ", coordinate.latitude, " ",coordinate.longitude)
                }
                else {
                    self.showLocationView()
                }
            }
            else if currentSelectionView == self.viewStopLocation {
                
                if let coordinate = self.secondStopdetail?.coordinate{
                    self.plotMarker( marker: &StopMarker, with: coordinate)
                    print("Destination Marker - ", coordinate.latitude, " ",coordinate.longitude)
                }
                else {
                    self.showLocationView()
                }
            }
        }
        
        private func plotMarker(marker : inout GMSMarker, with coordinate : CLLocationCoordinate2D){
            
            marker.position = coordinate
            marker.map = self.mapViewHelper?.mapView
            self.mapViewHelper?.mapView?.animate(toLocation: coordinate)
        }
        
        //  Show Location View
        
        @IBAction private func showLocationView() {
            
            if let locationView = Bundle.main.loadNibNamed(XIB.Names.LocationSelectionView, owner: self, options: [:])?.first as? LocationSelectionView
            {
                locationView.frame = self.view.bounds
                locationView.setValues(address: (sourceLocationDetail,destinationLocationDetail,secondStopdetail)) { [weak self] (address) in
                    guard let self = self else {return}
                    self.sourceLocationDetail = address.source
                    
                    
                    if riderStatus != .pickedup { //
                        
                        if address.stop2 != nil
                        {
                            self.secondStopdetail = address.stop2
                            print(self.secondStopdetail as Any)
                            self.viewStopLocation.isHidden = false
                            self.view_line.isHidden = false
                            self.view_squer.isHidden = false
                            
                        }
                        else
                        {
                            self.secondStopdetail  = nil
                            locationView.Addstop  = false
                            self.viewStopLocation.isHidden = true
                            self.view_line.isHidden = true
                            self.view_squer.isHidden = true
                        }
                        self.destinationLocationDetail = address.destination
                        //self.secondStopdetail = address.stop2
                        
                        if locationView.Addstop == true
                        {
                            self.drawPolylineStop(isReroute: false)
                        }
                        else
                        {
                            self.drawPolyline(isReroute: false)
                        }
                        
                        
                    }
                    if [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) {
                        if let dAddress = address.destination?.address, let coordinate = address.destination?.coordinate {
                            
                            if coordinate.latitude != 0 && coordinate.longitude != 0 {
                                if riderStatus == .pickedup {
                                    showAlert(message: Constants.string.locationChange.localize(), okHandler: {
                                        self.destinationLocationDetail = address.destination
                                        self.extendTrip(requestID: self.currentRequestId, dLat: coordinate.latitude, dLong: coordinate.longitude, address: dAddress)
                                        self.drawPolyline(isReroute: false)
                                    }, cancelHandler: {
                                        
                                    }, fromView: self)
                                }
                            }
                            self.updateLocation(with: (dAddress,coordinate))
                        }
                    }
                    else {
                        self.removeUnnecessaryView(with: .cancelled) // Remove services or ride now if previously open
                        self.getServicesList(home: "") // get Services
                        //                        self.withoutDest = false
                    }
                }
                self.view.addSubview(locationView)
                if selectedLocationView == self.viewSourceLocation {
                    locationView.textFieldSource.becomeFirstResponder()
                }
                else  if selectedLocationView == self.viewDestinationLocation
                {
                    locationView.textFieldDestination.becomeFirstResponder()
                }
                else
                {
                    locationView.txt_stop2.becomeFirstResponder()
                }
                self.selectedLocationView.transform = .identity
                if riderStatus != .none {
                    
                } else {
                    self.selectedLocationView = UIView()
                }
                self.locationSelectionView = locationView
            }
        }
        
        // MARK:- Remove Location VIew
        
        func removeLocationView() {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.locationSelectionView?.tableViewBottom.frame.origin.y = (self.locationSelectionView?.tableViewBottom.frame.height) ?? 0
                self.locationSelectionView?.viewTop.frame.origin.y = -(self.locationSelectionView?.viewTop.frame.height ?? 0)
            }) { (_) in
                self.locationSelectionView?.isHidden = true
                self.locationSelectionView?.removeFromSuperview()
                self.locationSelectionView = nil
            }
        }
        
        
        
        // Draw Polyline
        
        func drawPolylineStop(isReroute:Bool)
        {
            self.showCenterPinOnMap(isSource: true, isShow: false)
            // self.imageViewMarkerCenter.isHidden = true
            if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
                let destinationCoordinate = self.destinationLocationDetail?.coordinate,
                let StopCoordinate = self.secondStopdetail?.coordinate
            {  // Draw polyline from source to destination
                
                self.mapViewHelper?.mapView?.clear()
                self.sourceMarker.map = self.mapViewHelper?.mapView
                self.destinationMarker.map = self.mapViewHelper?.mapView
                self.StopMarker.map = self.mapViewHelper?.mapView
                
                if isReroute{
                    isRerouteEnable = false
                    let coordinate = CLLocationCoordinate2D(latitude: (providerLastLocation.latitude), longitude: (providerLastLocation.longitude))
                    sourceCoordinate = coordinate
                }
                if !isReroute {
                    self.sourceMarker.position = sourceCoordinate
                    self.destinationMarker.position = StopCoordinate
                    self.StopMarker.position = destinationCoordinate
                }
                //self.selectionViewAction(in: self.viewSourceLocation)
                //self.selectionViewAction(in: self.viewDestinationLocation)
                //self.mapViewHelper?.mapView?.drawPolygon(from: sourceCoordinate, to: destinationCoordinate)
                self.mapViewHelper?.mapView?.drawPolygonStop(from: sourceCoordinate, to: destinationCoordinate, stop: StopCoordinate)
                
                self.selectedLocationView = UIView()
            }
        }
        
        // Draw Polyline
        func drawPolyline(isReroute:Bool) {
            self.showCenterPinOnMap(isSource: true, isShow: false)
            // self.imageViewMarkerCenter.isHidden = true
            if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
                let destinationCoordinate = self.destinationLocationDetail?.coordinate {  // Draw polyline from source to destination
                
                self.mapViewHelper?.mapView?.clear()
                self.sourceMarker.map = self.mapViewHelper?.mapView
                self.destinationMarker.map = self.mapViewHelper?.mapView
                if isReroute{
                    isRerouteEnable = false
                    let coordinate = CLLocationCoordinate2D(latitude: (providerLastLocation.latitude), longitude: (providerLastLocation.longitude))
                    sourceCoordinate = coordinate
                }
                if !isReroute {
                    self.sourceMarker.position = sourceCoordinate
                    self.destinationMarker.position = destinationCoordinate
                }
                //self.selectionViewAction(in: self.viewSourceLocation)
                //self.selectionViewAction(in: self.viewDestinationLocation)
                self.mapViewHelper?.mapView?.drawPolygon(from: sourceCoordinate, to: destinationCoordinate)
                self.selectedLocationView = UIView()
            }
        }
        
        // MARK:- Get Favourite Locations
        
        private func getFavouriteLocations(){
            
            favouriteLocations.append((Constants.string.home,nil))
            favouriteLocations.append((Constants.string.work,nil))
            self.presenter?.get(api: .locationService, parameters: nil)
        }
        
        //  Cancel Request if it exceeds a certain interval
        
        @IBAction func validateRequest() {
            
            if riderStatus == .searching {
                UIApplication.shared.keyWindow?.makeToast(Constants.string.noDriversFound.localize())
                
                self.cancelRequest()
            }
        }
        
        //  SideMenu Button Action
        
        @IBAction private func sideMenuAction(){
            
            if self.isOnBooking { // If User is on Ride Selection remove all view and make it to default
                self.clearAllView()
                print("ViewAddressOuter ", #function)
            } else {
                self.drawerController?.openSide(selectedLanguage == .arabic ? .right : .left)
                self.viewSideMenu.addPressAnimation()
            }
            
        }
        
        // Clear Map
        
        func clearAllView() {
            self.removeLoaderView()
            self.removeUnnecessaryView(with: .cancelled)
            self.clearMapview()
            self.viewAddressOuter.isHidden = false
            self.viewLocationButtons.isHidden = false
        }
        
        
        //  Show DateTimePicker
        
        func schedulePickerView(on completion : @escaping ((Date)->())){
            
            var dateComponents = DateComponents()
            dateComponents.day = 7
            let now = Date()
            let maximumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            dateComponents.minute = 5
            dateComponents.day = nil
            let minimumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            datePicker = DateTimePicker.create(minimumDate: minimumDate, maximumDate: maximumDate)
            self.datePicker?.includeMonth = true
            self.datePicker?.cancelButtonTitle = Constants.string.Cancel.localize()
            
            self.datePicker?.doneButtonTitle = Constants.string.Done.localize()
            self.datePicker?.is12HourFormat = true
            self.datePicker?.dateFormat = DateFormat.list.hhmmddMMMyyyy
            self.datePicker?.highlightColor = .primary
            self.datePicker?.doneBackgroundColor = .secondary
            self.datePicker?.completionHandler = { date in
                completion(date)
                print(date)
                self.datePicker = nil
            }
            
            self.datePicker?.show()
            
        }
        
        func scheduleRecurrentPickerView(on completion : @escaping ((Date, Array<Int>)->())){
            
            let viewBG = UIView()
            var dateComponents = DateComponents()
            dateComponents.day = 7
            let now = Date()
            let maximumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            dateComponents.minute = 5
            dateComponents.day = nil
            let minimumDate = Calendar.current.date(byAdding: dateComponents, to: now)
            self.datePicker = DateTimePicker.create(minimumDate: minimumDate, maximumDate: maximumDate)
            self.datePicker?.includeMonth = true
            self.datePicker?.cancelButtonTitle = Constants.string.Cancel.localize()
            
            self.datePicker?.doneButtonTitle = Constants.string.OK.localize()
            self.datePicker?.is12HourFormat = false
            self.datePicker?.dateFormat = DateFormat.list.ddMMyyyyhhmma
            //            self.datePicker?.dateFormat = DateFormat.list.hhmmddMMMyyyy
            self.datePicker?.highlightColor = .primary
            self.datePicker?.doneBackgroundColor = .secondary
            
            // for recurrent
            viewBG.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
            viewBG.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            let viewRepeat = UIView()
            viewRepeat.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            let btn = UIButton(type: .custom)
            let lbRepeat = UILabel()
            let ivArrow = UIImageView(image: #imageLiteral(resourceName: "right-arrow"))
            ivArrow.contentMode = UIView.ContentMode.scaleAspectFit
            //            lbRepeat.text = "Repeat"
            lbRepeat.text = Constants.string.Repeat.localize()
            viewRepeat.addSubview(lbRepeat)
            viewRepeat.addSubview(ivArrow)
            viewRepeat.addSubview(btn)
            btn.addTarget(self, action: #selector(goRepeatWeekly), for: .touchUpInside)
            lbRecurrentReq = UILabel()
            lbRecurrentReq?.textAlignment = NSTextAlignment.right
            resetRecurrent(data: recurrentReq)
            viewRepeat.addSubview(lbRecurrentReq!)
            
            self.datePicker?.frame = CGRect(x: 0, y: viewBG.frame.size.height - (self.datePicker?.frame.size.height)!, width: (self.datePicker?.frame.size.width)!, height: (self.datePicker?.frame.size.height)!)
            viewRepeat.frame = CGRect(x: 0, y: viewBG.frame.size.height - (self.datePicker?.frame.size.height)! - 44, width: viewBG.frame.size.width, height: 44)
            viewRepeat.isUserInteractionEnabled = true
            btn.frame = CGRect(x: 0, y: 0, width: viewRepeat.frame.size.width, height: viewRepeat.frame.size.height)
            lbRepeat.frame = CGRect(x: 15, y: 0, width: viewRepeat.frame.size.width - 40, height: viewRepeat.frame.size.height)
            ivArrow.frame = CGRect(x: viewRepeat.frame.size.width - 20, y: (viewRepeat.frame.size.height - 15) / 2, width: 15, height: 15)
            lbRecurrentReq?.frame = CGRect(x: 20, y: 0, width: viewRepeat.frame.size.width - 44, height: viewRepeat.frame.size.height)
            
            viewBG.addSubview(viewRepeat)
            viewBG.addSubview(self.datePicker!)
            self.view.addSubview(viewBG)
            //
            
            self.datePicker?.completionHandler = { date in
                completion(date, self.recurrentReq)
                viewBG.removeFromSuperview()
                self.recurrentReq = []
                self.lbRecurrentReq = nil
                self.datePicker = nil
            }
            
            self.datePicker?.dismissHandler = {() in
                
                viewBG.removeFromSuperview()
                self.recurrentReq = []
                self.lbRecurrentReq = nil
                self.datePicker = nil
            }
        }
        
        @objc func goRepeatWeekly() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RepeatWeekdayViewController") as! RepeatWeekdayViewController
            vc.recurrentReq = self.recurrentReq
            vc.dateString = self.datePicker!.selectedDateString
            navigationController?.pushViewController(vc, animated: true)
        }
        
        func resetRecurrent(data:Array<Int>) -> Void {
            let weekly = [Constants.string.Sunday.localize(), Constants.string.Monday.localize(), Constants.string.Tuesday.localize(), Constants.string.Wednesday.localize(), Constants.string.Thursday.localize(), Constants.string.Friday.localize(), Constants.string.Saturday.localize()]
            recurrentReq = data
            var txt = ""
            let never = Constants.string.Never.localize()
            recurrentReq.forEach { (dayOfWeek) in
                //                txt += "\(dayOfWeek.prefix(3)), "
                txt += "\(weekly[dayOfWeek].prefix(3)), "
            }
            //            lbRecurrentReq?.text = "\(recurrentReq.count > 0 ? txt.prefix(txt.count - 2) : "Never")" --original code
            //           lbRecurrentReq?.text = "\(recurrentReq.count > 0 ? txt.prefix(txt.count - 2) : \(never))"
            
            //            lbRecurrentReq?.text =  never
            //            if recurrentReq.count > 0{
            //                lbRecurrentReq?.text = "\(txt.prefix(txt.count - 2))"
            //            }
            
            lbRecurrentReq?.text = (recurrentReq.count > 0) ? "\(txt.prefix(txt.count - 2))" : "\(never)"
            
        }
        
        //  Observe Network Changes
        @objc private func networkChanged(notification : Notification) {
            if let reachability = notification.object as? Reachability, ([Reachability.Connection.cellular, .wifi].contains(reachability.connection)) {
                self.getCurrentLocationDetails()
            }
        }
        
    }
    
    // Mark:- If driver app exist
    
    extension HomeViewController {
        
        // if driver app exist need to show warning alert
        func driverAppExist() {
            let app = UIApplication.shared
            let bundleId = driverBundleID+"://"
            
            if app.canOpenURL(URL(string: bundleId)!) {
                let appExistAlert = UIAlertController(title: "", message: Constants.string.warningMsg.localize(), preferredStyle: .actionSheet)
                
                appExistAlert.addAction(UIAlertAction(title: Constants.string.Continue.localize(), style: .default, handler: { (Void) in
                    print("App is install")
                }))
                present(appExistAlert, animated: true, completion: nil)
            }
            else {
                print("App is not installed")
            }
        }
    }
    
    // MARK:- GMSMapViewDelegate
    
    extension HomeViewController : GMSMapViewDelegate {
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            
            if mapView == SelectLocation?.SelectStopMap
            {
                
                Latituget = Float(position.target.latitude)
                
                Longitudget = Float(position.target.longitude)
                
                let getaddress =  self.geoCodeUsingAddress()
                self.SelectLocation?.lbl_address.text = getaddress
            }
            else
            {
                
                if self.isUserInteractingWithMap {
                    
                    func getUpdate(on location : CLLocationCoordinate2D, completion :@escaping ((LocationDetail)->Void)) {
                        self.drawPolyline(isReroute: false)
                        print("Polydraw 3")
                        self.getServicesList(home: "")
                        //                    self.withoutDest = false
                        self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                            completion(locationDetail)
                        })
                    }
                    
                    if self.selectedLocationView == self.viewSourceLocation, self.sourceLocationDetail != nil {
                        
                        if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                            self.sourceLocationDetail?.value?.coordinate = location
                            getUpdate(on: location) { (locationDetail) in
                                self.sourceLocationDetail?.value = locationDetail
                            }
                            self.sourceMarker.map = mapView
                            //                        self.sourceMarker.position = location
                            showCenterPinOnMap(isSource: true, isShow: false)
                        }
                    }
                    //                else if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                    //
                    //                    if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                    //                        self.destinationLocationDetail?.coordinate = location
                    //                        getUpdate(on: location) { (locationDetail) in
                    //                            self.destinationLocationDetail = locationDetail
                    //                            if riderStatus == .pickedup {
                    //                                showAlert(message: Constants.string.locationChange.localize(), okHandler: {
                    //
                    //                                    self.extendTrip(requestID: self.currentRequestId, dLat: locationDetail.coordinate.latitude, dLong: locationDetail.coordinate.longitude, address: locationDetail.address)
                    //                                }, cancelHandler: {
                    //
                    //                                }, fromView: self)
                    //                            }else{
                    //                                self.updateLocation(with: locationDetail) // Update Request Destination Location
                    //                            }
                    //                        }
                    //                    }
                    //                }
                }
                self.isMapInteracted(false)
            }
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            
            if mapView == SelectLocation?.SelectStopMap
            {
                
            }
            else
            {
                print("Gesture ",gesture)
                self.isUserInteractingWithMap = gesture
                
                if self.isUserInteractingWithMap {
                    self.isMapInteracted(true)
                }
                
                if self.selectedLocationView == self.viewSourceLocation, self.sourceLocationDetail != nil {
                    self.sourceMarker.map = nil
                    showCenterPinOnMap(isSource: true, isShow: true)
                }
            }
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            
            // return
            
            if mapView == SelectLocation?.SelectStopMap
            {
                Latituget = Float(position.target.latitude)
                
                Longitudget = Float(position.target.longitude)
                
            }
            else
            {
                
                if isUserInteractingWithMap {
                    
                    if self.selectedLocationView == self.viewSourceLocation, self.sourceLocationDetail != nil {
                        
                        //                    self.sourceMarker.map = nil
                        self.sourceMarker.position = mapView.camera.target
                        //                    showCenterPinOnMap(isSource: true, isShow: true)
                        //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                        //                    self.sourceLocationDetail?.value?.coordinate = location
                        //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                        //                        print(locationDetail)
                        //                        self.sourceLocationDetail?.value = locationDetail
                        ////                        let sLocation = self.sourceLocationDetail
                        ////                        self.sourceLocationDetail = sLocation
                        //                    })
                        //                }
                        
                        
                    } else if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                        
                        //                    self.destinationMarker.map = nil
                        //                    showCenterPinOnMap(isSource: false, isShow: true)
                        
                        //                    self.imageViewMarkerCenter.tintColor = .primary
                        //                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "destinationPin").withRenderingMode(.alwaysTemplate)
                        //                    self.imageViewMarkerCenter.isHidden = true//false
                        //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                        //                    self.destinationLocationDetail?.coordinate = location
                        //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                        //                        print(locationDetail)
                        //                        self.destinationLocationDetail = locationDetail
                        //                    })
                        //                }
                    }
                    
                }
                //        else {
                //            self.destinationMarker.map = self.mapViewHelper?.mapView
                //            self.sourceMarker.map = self.mapViewHelper?.mapView
                //            self.imageViewMarkerCenter.isHidden = true
                //        }
            }
        }
        
        func showCenterPinOnMap(isSource: Bool, isShow: Bool) {
            self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "destinationPin").withRenderingMode(.alwaysOriginal)
            if isSource == true {
                self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "sourcePin").withRenderingMode(.alwaysOriginal)
            }
            self.imageViewMarkerCenter.isHidden = !isShow // false
        }
        
        func extendTrip(requestID:Int,dLat:Double,dLong:Double,address:String)
        {
            
            var extendTrip = ExtendTrip()
            extendTrip.request_id = requestID
            extendTrip.latitude = dLat
            extendTrip.longitude = dLong
            extendTrip.address = address
            self.presenter?.post(api: .extendTrip, data: extendTrip.toData())
        }
        
    }
    
    // MARK:- Service Calls
    
    extension HomeViewController  {
        
        // Check For Service Status
        
        private func checkForProviderStatus() {
            
            HomePageHelper.shared.startListening(on: { (error, request) in
                
                if error != nil {
                    riderStatus = .none
                    //                    DispatchQueue.main.async {
                    //                        showAlert(message: error?.localizedDescription, okHandler: nil, fromView: self)
                    //                    }
                } else if request != nil {
                    if let requestId = request?.id {
                        self.currentRequestId = requestId
                    }
                    if let pLatitude = request?.provider?.latitude, let pLongitude = request?.provider?.longitude {
                        DispatchQueue.main.async {
                            //                            self.moveProviderMarker(to: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
                            self.getDataFromFirebase(providerID: (request?.provider?.id)!)
                            // MARK:- Showing Provider ETA
                            let currentStatus = request?.status ?? .none
                            if [RideStatus.accepted, .started, .arrived, .pickedup].contains(currentStatus) {
                                self.showETA(with: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
                            }
                        }
                    }
                    guard riderStatus != request?.status else {
                        return
                    }
                    riderStatus = request?.status ?? .none
                    self.isScheduled = ((request?.is_scheduled ?? false) && riderStatus == .searching)
                    self.handle(request: request!)
                } else {
                    let previousStatus = riderStatus
                    riderStatus = request?.status ?? .none
                    if riderStatus != previousStatus {
                        self.clearMapview()
                    }
                    if self.isScheduled {
                        self.isScheduled = false
                        //                        if let yourtripsVC = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                        //                            yourtripsVC.isYourTripsSelected = true
                        //                            yourtripsVC.isFirstBlockSelected = false
                        //                            self.navigationController?.pushViewController(yourtripsVC, animated: true)
                        //                        }
                        self.removeUnnecessaryView(with: .cancelled)
                    } else {
                        self.removeUnnecessaryView(with: .none)
                    }
                    
                }
            })
        }
        
        func getDataFromFirebase(providerID:Int)  {
            Database .database()
                .reference()
                .child("loc_p_\(providerID)").observe(.value, with: { (snapshot) in
                    guard let _ = snapshot.value as? NSDictionary else {
                        print("Error")
                        return
                    }
                    let providerLoc = ProviderLocation(from: snapshot)
                    
                    /* var latDouble = 0.0 //for android sending any or double
                     var longDouble = 0.0
                     var bearingDouble = 0.0
                     if let latitude = dict.value(forKey: "lat") as? Double {
                     latDouble = Double(latitude)
                     }else{
                     let strLat = dict.value(forKey: "lat")
                     latDouble = Double("\(strLat ?? 0.0)")!
                     }
                     if let longitude = dict.value(forKey: "lng") as? Double {
                     longDouble = Double(longitude)
                     }else{
                     let strLong = dict.value(forKey: "lng")
                     longDouble = Double("\(strLong ?? 0.0)")!
                     }
                     if let bearing = dict.value(forKey: "bearing") as? Double {
                     bearingDouble = bearing
                     } */
                    
                    //                    if let pLatitude = latDouble, let pLongitude = longDouble {
                    DispatchQueue.main.async {
                        print("Moving \(String(describing: providerLoc?.lat)) \(String(describing: providerLoc?.lng))")
                        self.moveProviderMarker(to: LocationCoordinate(latitude: providerLoc?.lat ?? defaultMapLocation.latitude , longitude: providerLoc?.lng ?? defaultMapLocation.longitude),bearing: providerLoc?.bearing ?? 0.0)
                        if polyLinePath.path != nil {
                            if riderStatus == .pickedup {
                                self.updateTravelledPath(currentLoc: CLLocationCoordinate2D(latitude: providerLoc?.lat ?? defaultMapLocation.latitude, longitude: providerLoc?.lng ?? defaultMapLocation.longitude))
                                self.mapViewHelper?.checkPolyline(coordinate:  LocationCoordinate(latitude: providerLoc?.lat ?? defaultMapLocation.latitude , longitude: providerLoc?.lng ?? defaultMapLocation.longitude))
                            }
                        }
                    }
                })
        }
        
        
        // Get Services provided by Provider
        
        private func getServicesList(home:String)
        {
            if self.sourceLocationDetail?.value != nil, self.destinationLocationDetail != nil, riderStatus == .none || riderStatus == .searching
            {
                // Get Services only if location Available
                
                //  self.presenter?.get(api: .servicesList, parameters: nil)
                
                // dimpal
                
//                guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, let destinationLocation = self.destinationLocationDetail?.coordinate, sourceLocation.latitude>0, sourceLocation.longitude>0, destinationLocation.latitude>0, destinationLocation.longitude>0
//                    else
//                {
//                    return
//                }
                
                
                let startlocation =  start_location1()
                let destinationlocation =  destination_location1()
                
                let ceo: CLGeocoder = CLGeocoder()
                
                let loc: CLLocation = CLLocation(latitude:(self.sourceLocationDetail?.value?.coordinate.latitude)!, longitude: (self.sourceLocationDetail?.value?.coordinate.longitude)!)
                
                ceo.reverseGeocodeLocation(loc, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        }
//                        let pm = placemarks as! [CLPlacemark]
                        if let pm = placemarks as? [CLPlacemark] {
                            if pm.count > 0
                            {
                                let pm = placemarks![0]
                                startlocation.lat =  self.sourceLocationDetail?.value?.coordinate.latitude
                                startlocation.lng = self.sourceLocationDetail?.value?.coordinate.longitude
                                startlocation.formatted_address = self.sourceLocationDetail?.value?.address
                                startlocation.region_name = pm.locality
                                startlocation.country = pm.country
                                startlocation.address = self.sourceLocationDetail?.value?.address
                                
                                
                                let ceo: CLGeocoder = CLGeocoder()
                                
                                let loc: CLLocation = CLLocation(latitude:(self.destinationLocationDetail?.coordinate.latitude)!, longitude: (self.destinationLocationDetail?.coordinate.longitude)!)
                                
                                ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        if pm.count > 0
                                        {
                                            let pm = placemarks![0]
                                            
                                            destinationlocation.lat = self.destinationLocationDetail?.coordinate.latitude
                                            destinationlocation.lng = self.destinationLocationDetail?.coordinate.longitude
                                            destinationlocation.formatted_address = self.destinationLocationDetail?.address
                                            destinationlocation.region_name = pm.locality
                                            destinationlocation.country = pm.country
                                            destinationlocation.address = self.destinationLocationDetail?.address
                                            
                                            
                                            let Startloc = [startlocation]
                                            
                                            let Start_String = String(data: Startloc[0].toData()! , encoding: .utf8)
                                            let Startlocat = Start_String?.replacingOccurrences(of: "\\", with: "")
                                            print(Startlocat!)
                                            
                                            
                                            let Destloc = [destinationlocation]
                                            
                                            let Des_String = String(data: Destloc[0].toData()! , encoding: .utf8)
                                            let Deslocat = Des_String?.replacingOccurrences(of: "\\", with: "")
                                            print(Deslocat!)
                                            
                                            self.CheckDrivingZoneApi(Startlocat: Startlocat!, Deslocat: Deslocat!, home: home)
                                            
                                            /*    let DrivingZonerequest = checkDrivingZonerequest()
                                             DrivingZonerequest.start_location = Startlocat!
                                             DrivingZonerequest.destination_location = Deslocat!
                                             DrivingZonerequest.way_location = ""
                                             
                                             self.presenter?.post(api: .checkdriverzone, data: DrivingZonerequest.toData())*/
                                            
                                        }
                                })
                            }
                        }
                        
                })
                
                
                
                
                
                
            }
            
        }
        
        func CheckDrivingZoneApi(Startlocat:String,Deslocat:String,home:String)
        {
            var Waylocat = ""
            
            if home == "home"
            {
                let DrivingZonerequest = checkDrivingZonerequest()
                DrivingZonerequest.start_location = Startlocat
                DrivingZonerequest.destination_location = Deslocat
                DrivingZonerequest.way_location = Waylocat
                
                self.presenter?.post(api: .checkdriverzone, data: DrivingZonerequest.toData())
            }
            else
            {
                
                if (self.locationSelectionView!.Addstop == true)
                {
                    let Way_location = way_location1()
                    
                    let ceo: CLGeocoder = CLGeocoder()
                    
                    let loc: CLLocation = CLLocation(latitude:(self.secondStopdetail?.coordinate.latitude)!, longitude: (self.secondStopdetail?.coordinate.longitude)!)
                    
                    ceo.reverseGeocodeLocation(loc, completionHandler:
                        {(placemarks, error) in
                            if (error != nil)
                            {
                                print("reverse geodcode fail: \(error!.localizedDescription)")
                            }
                            let pm = placemarks! as [CLPlacemark]
                            
                            if pm.count > 0
                            {
                                let pm = placemarks![0]
                                
                                Way_location.lat = self.secondStopdetail?.coordinate.latitude
                                Way_location.lng = self.secondStopdetail?.coordinate.longitude
                                Way_location.formatted_address = self.secondStopdetail?.address
                                Way_location.region_name = pm.locality
                                Way_location.country = pm.country
                                Way_location.address = self.secondStopdetail?.address
                            }
                    })
                    
                    
                    let Wayloc = [Way_location]
                    
                    let Way_String = String(data: Wayloc[0].toData()! , encoding: .utf8)
                    Waylocat = (Way_String?.replacingOccurrences(of: "\\", with: ""))!
                    print(Waylocat)
                    
                    let DrivingZonerequest = checkDrivingZonerequest()
                    DrivingZonerequest.start_location = Startlocat
                    DrivingZonerequest.destination_location = Deslocat
                    DrivingZonerequest.way_location = Waylocat
                    
                    self.presenter?.post(api: .checkdriverzone, data: DrivingZonerequest.toData())
                    
                    
                }
                else
                {
                    let DrivingZonerequest = checkDrivingZonerequest()
                    DrivingZonerequest.start_location = Startlocat
                    DrivingZonerequest.destination_location = Deslocat
                    DrivingZonerequest.way_location = Waylocat
                    
                    self.presenter?.post(api: .checkdriverzone, data: DrivingZonerequest.toData())
                }
                
            }
            
            
        }
        
        
        
        // Get Estimate Fare
        
        func getEstimateFareFor(serviceId : Int,isWODest:Bool) {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                
                guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, let destinationLocation = self.destinationLocationDetail?.coordinate, sourceLocation.latitude>0, sourceLocation.longitude>0, destinationLocation.latitude>0, destinationLocation.longitude>0 else {
                    return
                }
                var estimateFare = EstimateFareRequest()
                estimateFare.s_latitude = sourceLocation.latitude
                estimateFare.s_longitude = sourceLocation.longitude
                estimateFare.d_latitude = destinationLocation.latitude
                estimateFare.d_longitude = destinationLocation.longitude
                estimateFare.service_type = serviceId
                
                self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
                
                
                
            }
        }
        
        
        
        // Cancel Request
        
        func cancelRequest(reason : String? = nil) {
            
            if self.currentRequestId>0 {
                let request = Request()
                request.request_id = self.currentRequestId
                request.cancel_reason = reason
                self.presenter?.post(api: .cancelRequest, data: request.toData())
            }
        }
        
        
        // Create Request
        
        func createRequest(for service : Service, isScheduled : Bool, scheduleDate : Date?, recurrent:Array<Int>?, note:String, cardEntity entity : CardEntity?, paymentType : PaymentType) {
            // Validate whether the card entity has valid data
            if paymentType == .CARD && entity == nil {
                UIApplication.shared.keyWindow?.make(toast: Constants.string.selectCardToContinue.localize())
                return
            }
            
            self.showLoaderView()
            DispatchQueue.global(qos: .background).async
                {
                    let request = Request()
                    request.s_address = self.sourceLocationDetail?.value?.address
                    request.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
                    request.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
                    request.d_address = self.destinationLocationDetail?.address
                    request.d_latitude = self.destinationLocationDetail?.coordinate.latitude
                    request.d_longitude = self.destinationLocationDetail?.coordinate.longitude
                    request.service_type = service.id
                    request.payment_mode = paymentType
                    request.distance = "\(service.pricing?.distance ?? 0)"
                    request.use_wallet = service.pricing?.useWallet
                    request.card_id = entity?.card_id
                    request.note = note
                    request.total_price = service.fixed ?? 0
                    
                    if (self.POIpriceLogic?.price?.floatValue() == request.total_price!)
                    {
                        request.calculateState = "poi"
                    }
                    else
                    {
                        request.calculateState = "distance"
                    }
                    
                    if (self.locationSelectionView!.Addstop == true)
                    {
                        let waylocation = Way_locations()
                        
                        waylocation.lat = self.secondStopdetail?.coordinate.latitude
                        waylocation.lng = self.secondStopdetail?.coordinate.longitude
                        waylocation.formatted_address = self.secondStopdetail?.address
                        waylocation.region_name = " "
                        waylocation.country = ""
                        waylocation.address = self.secondStopdetail?.address
                        
                        let wayloc = [waylocation]
                        
                        //  let jsonData: Data? = try? JSONSerialization.data(withJSONObject: wayloc[0].toData())
                        let HolidayDate_String = String(data: wayloc[0].toData()! , encoding: .utf8)
                        let way_locations = HolidayDate_String?.replacingOccurrences(of: "\\", with: "")
                        
                        let way_locations1 = "\("[")\(way_locations!)\("]")"
                        print(way_locations!)
                        
                        request.way_locations = way_locations1
                        
                        
                    }
                    
                    if isScheduled {
                        
                        request.chbs_service_type_id = "2"
                        
                        if let dateString = Formatter.shared.getString(from: scheduleDate, format: DateFormat.list.ddMMyyyyhhmma) {
                            let dateArray = dateString.components(separatedBy: " ")
                            request.schedule_date = dateArray.first
                            request.schedule_time = dateArray.last
                            if recurrent?.count ?? 0 > 0 {
                                request.recurrent = recurrent
                            }
                        }
                    }
                    else
                    {
                        request.chbs_service_type_id = "1"
                    }
                    
                    if let couponId = service.promocode?.id
                    {
                        request.promocode_id = couponId
                    }
                    
                    
                    let Orderdetail_String = String(data:  request.toData()!, encoding: .utf8)
                    let Orderdetail = Orderdetail_String?.replacingOccurrences(of: "\\", with: "")
                    
                    print(Orderdetail!)
                    
                    self.presenter?.post(api: .sendRequest, data: request.toData())
                    
                    // self.presenter?.post(api: .sendStopRequest, data: request.toData())
                    
            }
        }
        
        // MARK:- Update Location for Existing Request
        
        func updateLocation(with detail : LocationDetail) {
            //.pickedup
            guard [RideStatus.accepted, .arrived, .started].contains(riderStatus) else { return } // Update Location only if status falls under certain category
            
            let request = Request()
            request.request_id = self.currentRequestId
            request.address = detail.address
            request.latitude = detail.coordinate.latitude
            request.longitude = detail.coordinate.longitude
            self.presenter?.post(api: .updateRequest, data: request.toData())
            
        }
        
        //  Change Payment Type For existing Request
        func updatePaymentType(with cardDetail : CardEntity?, paymentType: PaymentType) {
            let request = Request()
            request.request_id = self.currentRequestId
            if paymentType == .CARD {
                request.payment_mode = .CARD
                request.card_id = cardDetail!.card_id
            }
            else {
                request.payment_mode = paymentType
            }
            self.loader.isHideInMainThread(false)
            self.presenter?.post(api: .updateRequest, data: request.toData())
        }
        
        //  Favourite Location on Other Category
        func favouriteLocationApi(in view : UIView, isAdd : Bool) {
            
            guard isAdd else { return }
            
            let service = Service() // Save Favourite location in Server
            service.type = CoreDataEntity.other.rawValue.lowercased()
            if view == self.viewFavouriteSource, let address = self.sourceLocationDetail?.value {
                service.address = address.address
                service.latitude = address.coordinate.latitude
                service.longitude = address.coordinate.longitude
            } else if view == self.viewFavouriteDestination, self.destinationLocationDetail != nil {
                service.address = self.destinationLocationDetail!.address
                service.latitude = self.destinationLocationDetail!.coordinate.latitude
                service.longitude = self.destinationLocationDetail!.coordinate.longitude
            } else { return }
            
            self.presenter?.post(api: .locationServicePostDelete, data: service.toData())
            
        }
    }
    
    // MARK:- PostViewProtocol
    
    extension HomeViewController : PostViewProtocol {
        
        
        func GetServiceType(api: Base, data: [Service])
        {
            print(DurationFloat)
            
            let hourstotal = Hours * 60
            let tuple = minutesToHoursMinutes(minutes: hourstotal + Minutes )
            
            let hourspass = tuple.hours
            let minutspass = tuple.leftMinutes
            
            print(hourspass)
            print(minutspass)
            
            
            if api == .getServiceType
            {
                DispatchQueue.main.async {
                    
                    for i in 0..<data.count
                    {
                        let Dicdata = data[i]
                        
                        Dicdata.time = "\(hourspass)\(" hours")\(" ")\(minutspass)\(" min")"
                        Dicdata.distance = self.DurationFloat
                        
                    }
                    
                    self.showRideNowView(with: data)
                    
                }
            }
        }
        
        func GetServicePOIDisatnceInfo(api: Base, data: [Service])
        {
            print(DurationFloat)
            
            let hourstotal = Hours * 60
            
            let tuple = minutesToHoursMinutes(minutes: hourstotal + Minutes )
            
            let hourspass = tuple.hours
            let minutspass = tuple.leftMinutes
            
            print(hourspass)
            print(minutspass)
            
            if api == .getServicePOIDisatnceInfo {
                DispatchQueue.main.async {
                    
                    for i in 0..<data.count
                    {
                        let Dicdata = data[i]
                        
                        Dicdata.time = "\(hourspass)\(" hours")\(" ")\(minutspass)\(" min")"
                        Dicdata.distance = self.DurationFloat
                        
                    }
                    
                    self.showRideNowView(with: data)
                    
                }
            }
            
        }
        
        // MARK:- TwoLocationSourceAndDestination
        
        func TwoLocationSourceAndDestination(Sourc:String,Destination:String) -> NSArray
        {
            
            var arrayLocation = NSArray()
            
            /*  https://maps.googleapis.com/maps/api/distancematrix/json?origins=39.9041657,116.40771840000002&destinations=39.9769548,116.48072239999999&mode=driving&sensor=false&units=metric&key=AIzaSyCjd0AaXmIV3o665Jwy7wKlRw1U_SF9_dU*/
            
            /*   let latitudesource =  self.sourceLocationDetail?.value?.coordinate.latitude
             let longitudesourc =  self.sourceLocationDetail?.value?.coordinate.longitude
             
             let combileSource = "\(latitudesource!)\(",")\(longitudesourc!)"
             
             let latitudesource =  self.sourceLocationDetail?.value?.coordinate.latitude
             let longitudesourc =  self.sourceLocationDetail?.value?.coordinate.longitude
             
             let combileSource = "\(latitudesource!)\(",")\(longitudesourc!)"*/
            
            // let addressstr = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(combileSource),\("&destinations=")\(Destination)&key=\(googleMapKey)"
            
            let addressstr = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(Sourc),\("&destinations=")\(Destination)\("&mode=driving&sensor=false&units=metric")&key=\(googleMapKey)"
            
            let urlStr  = addressstr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            let searchURL: NSURL = NSURL(string: urlStr! as String)!
            
            do {
                let newdata = try Data(contentsOf: searchURL as URL)
                if let responseDictionary = try JSONSerialization.jsonObject(with: newdata, options: []) as? NSDictionary
                {
                    print(responseDictionary)
                    
                    arrayLocation = responseDictionary.object(forKey: "rows") as! NSArray
                    
                    if arrayLocation.count != 0
                    {
                        
                        let elements = arrayLocation.value(forKey: "elements")as! NSArray
                        
                        let Arry0 = elements[0]as! NSArray
                        
                        let Dicdata = Arry0[0]as! NSDictionary
                        
                        let status = Dicdata.value(forKey: "status")as! String
                        
                        print(status)
                        
                        if status == "ZERO_RESULTS"
                        {
                            arrayLocation = NSArray()
                        }
                    }
                    
                }
                
            }
            catch
            {
                
            }
            
            return arrayLocation
        }
        
        
        
        
        func CheckPoiPriceLogic(api: Base, data: checkPoiPriceLogic?)
        {
//            print(data!.JSONRepresentation)
            
            POIpriceLogic = data
            
            if data?.status == true
            {
                //getServicePOIDisatnceInfo Api
                
                DurationFloat = 0.0
                
                Minutes = 0
                
                Hours = 0
                
                let startaddress = self.sourceLocationDetail?.value?.address
                let Desaddress = self.destinationLocationDetail?.address
                
                let ArryLocation = TwoLocationSourceAndDestination(Sourc: startaddress!, Destination: Desaddress!)
                
                if ArryLocation.count == 0
                {
                    UIApplication.shared.keyWindow?.make(toast: "It is not possible to create a route between chosen points.")
                    
                    return
                }
                
                let elements = ArryLocation.value(forKey: "elements")as! NSArray
                let distanceArry = elements.value(forKey: "distance")as! NSArray
                let distancetext = distanceArry[0]as! NSArray
                let Dicdata = distancetext[0]as! NSDictionary
                let Distancetotal = Dicdata.value(forKey: "text")as! String
                
                let Arr2 = Distancetotal.components(separatedBy: " ")
                
                let DurationString = Arr2[0]
                
                let myFloat : Float = NSString(string: DurationString).floatValue
                
                DurationFloat = myFloat
                
                let durationArry = elements.value(forKey: "duration")as! NSArray
                
                let  durationtext = durationArry[0]as! NSArray
                let Dicdata1 = durationtext[0]as! NSDictionary
                
                let Durationtotal = Dicdata1.value(forKey: "text")as! String
                
                let Arr = Durationtotal.components(separatedBy: " ")
                
                var min:String = "0"
                var hours:String = "0"
                
                
                if Arr.count == 2
                {
                    if Durationtotal.contains("hours")
                    {
                        hours   = Arr[0]
                        Hours = Int(hours)!
                    }
                    else
                    {
                        min   = Arr[0]
                        Minutes = Int(min)!
                    }
                    
                }
                else
                {
                    hours   = Arr[0]
                    min   = Arr[2]
                    
                    Hours = Int(hours)!
                    Minutes = Int(min)!
                }
                
                let Poiservicetypeid = String(format: "%@",(data?.service_type_id)!)
                let poiserviceid = data?.service_id
                let poiPrice = String(format: "%@",(data?.price)!)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let currentTime = dateFormatter.string(from: Date())
                print(currentTime)
                
                let POIdistanceinfo = getServicePOIDisatnceInforequest()
                POIdistanceinfo.passenger = "1"
                POIdistanceinfo.suitcase = "0"
                POIdistanceinfo.vehicle_type = "0"
                POIdistanceinfo.total_kilometer = String(DurationFloat)
                POIdistanceinfo.total_hours = String(Hours)
                POIdistanceinfo.total_minutes = String(Minutes)
                POIdistanceinfo.poiPrice = poiPrice
                POIdistanceinfo.Poi_service_type_id = Poiservicetypeid
                POIdistanceinfo.poi_service_id = poiserviceid
                POIdistanceinfo._token = deviceTokenString
                POIdistanceinfo.start_time = currentTime
                
                
                self.presenter?.post(api: .getServicePOIDisatnceInfo, data: POIdistanceinfo.toData())
                
            }
            else
            {
                DurationFloat = 0.0
                
                Minutes = 0
                
                Hours = 0
                
                let startaddress = self.sourceLocationDetail?.value?.address
                let Desaddress = self.destinationLocationDetail?.address
                
                let ArryLocation = TwoLocationSourceAndDestination(Sourc: startaddress!, Destination: Desaddress!)
                
                if ArryLocation.count == 0
                {
                    UIApplication.shared.keyWindow?.make(toast: "It is not possible to create a route between chosen points.")
                    
                    return
                }
                
                let elements = ArryLocation.value(forKey: "elements")as! NSArray
                let distanceArry = elements.value(forKey: "distance")as! NSArray
                let distancetext = distanceArry[0]as! NSArray
                
                let Dicdata = distancetext[0]as! NSDictionary
                
                let Distancetotal = Dicdata.value(forKey: "text")as! String
                
                let Arr2 = Distancetotal.components(separatedBy: " ")
                
                let DurationString = Arr2[0]
                
                let myFloat : Float = NSString(string: DurationString).floatValue
                
                DurationFloat = myFloat
                
                let durationArry = elements.value(forKey: "duration")as! NSArray
                let  durationtext = durationArry[0]as! NSArray
                let Dicdata1 = durationtext[0]as! NSDictionary
                
                let Durationtotal = Dicdata1.value(forKey: "text")as! String
                
                let Arr = Durationtotal.components(separatedBy: " ")
                
                var min:String = "0"
                var hours:String = "0"
                
                if Arr.count == 2
                {
                    if Durationtotal.contains("hours")
                    {
                        hours   = Arr[0]
                        Hours = Int(hours)!
                    }
                    else
                    {
                        min   = Arr[0]
                        Minutes = Int(min)!
                        
                    }
                    
                }
                else
                {
                    hours   = Arr[0]
                    min   = Arr[2]
                    
                    Hours = Int(hours)!
                    Minutes = Int(min)!
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                let currentTime = dateFormatter.string(from: Date())
                print(currentTime)
                
                let ServiceType = getServiceTyperequest()
                ServiceType.passenger = "1"
                ServiceType.suitcase = "0"
                ServiceType.vehicle_type = "0"
                ServiceType.total_kilometer = String(DurationFloat)
                ServiceType.total_hours = String(Hours)
                ServiceType.total_minutes = String(Minutes)
                ServiceType.chbs_service_type_id = "1"
                ServiceType.start_time = currentTime
                
                self.presenter?.post(api: .getServiceType, data: ServiceType.toData())
            }
            
        }
        
        
        func WayPointCalculation()
        {
            let startaddress = self.destinationLocationDetail?.address
            let Desaddress = self.locationSelectionView?.txt_stop2.text
            
            let ArryLocation = TwoLocationSourceAndDestination(Sourc: startaddress!, Destination: Desaddress!)
            
            if ArryLocation.count == 0
            {
                //clearAllView()
                UIApplication.shared.keyWindow?.make(toast: "It is not possible to create a route between chosen points.")
                
                return
            }
            
            let elements = ArryLocation.value(forKey: "elements")as! NSArray
            
            print(elements)
            
            let distanceArry = elements.value(forKey: "distance")as! NSArray
            
            print(distanceArry)
            
            let distancetext = distanceArry[0]as! NSArray
            
            
            let Dicdata = distancetext[0]as! NSDictionary
            
            
            let Distancetotal2 = Dicdata.value(forKey: "text")as! String
            
            print(Distancetotal2)
                        
            let Arrdis = Distancetotal2.components(separatedBy: " ")
            if Float(Arrdis[0]) != nil {
                DurationFloat = DurationFloat + Float(Arrdis[0])!
                
                print(DurationFloat)
            }
            
            let durationArry = elements.value(forKey: "duration")as! NSArray
            
            print(durationArry)
            
            let  durationtext = durationArry[0]as! NSArray
            
            
            let Dicdata1 = durationtext[0]as! NSDictionary
            
            
            let Durationtotal = Dicdata1.value(forKey: "text")as! String
            print(Durationtotal)
            
            let Arr = Durationtotal.components(separatedBy: " ")
            
            var min:String = "0"
            var hours:String = "0"
            
            
            if Arr.count == 2
            {
                if Durationtotal.contains("hours")
                {
                    hours   = Arr[0]
                    
                    Hours = Hours + Int(hours)!
                }
                else
                {
                    min   = Arr[0]
                    
                    Minutes = Minutes + Int(min)!
                    
                    
                }
                
            }
            else
            {
                hours   = Arr[0]
                min   = Arr[2]
                
                Hours = Hours + Int(hours)!
                Minutes = Minutes + Int(min)!
            }
            
            
            print(Hours)
            print(Minutes)
            
            
            let tuple = minutesToHoursMinutes(minutes: Hours + Minutes )
            
            let hourspass = tuple.hours
            let minutspass = tuple.leftMinutes
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let currentTime = dateFormatter.string(from: Date())
            print(currentTime)
            
            let ServiceType = getServiceTyperequest()
            ServiceType.passenger = "1"
            ServiceType.suitcase = "0"
            ServiceType.vehicle_type = "0"
            ServiceType.total_kilometer = String(DurationFloat)
            ServiceType.total_hours = String(hourspass)
            ServiceType.total_minutes = String(minutspass)
            ServiceType.chbs_service_type_id = "1"
            ServiceType.start_time = currentTime
            
            self.presenter?.post(api: .getServiceType, data: ServiceType.toData())
            
        }
        
        //MARK: - minutesToHoursMinutes
        
        func minutesToHoursMinutes (minutes : Int) -> (hours : Int , leftMinutes : Int)
        {
            return (minutes / 60, (minutes % 60))
        }
        
        func CheckDrivingZone(api: Base, data: checkDrivingZone?)
        {
            print(data!.JSONRepresentation)
            
            if data?.status == false
            {
                UIApplication.shared.keyWindow?.make(toast:(data?.error)!)
            }
            else
            {
                
                //dimpal
                
                if  self.locationSelectionView == nil
                {
                    var Poipricelogic = checkPoiPriceLogicrequst()
                    
                    Poipricelogic.start_location_lat = self.sourceLocationDetail?.value?.coordinate.latitude
                    Poipricelogic.start_location_lng = self.sourceLocationDetail?.value?.coordinate.longitude
                    Poipricelogic.dest_location_lat = self.destinationLocationDetail?.coordinate.latitude
                    Poipricelogic.dest_location_lng = self.destinationLocationDetail?.coordinate.longitude
                    
                    self.presenter?.post(api: .checkPoiPriceLogic, data: Poipricelogic.toData())
                    
                }
                else
                {
                    if (self.locationSelectionView!.Addstop == true)
                    {
                        //getservicetype Api
                        
                        if (self.locationSelectionView!.Addstop == true)
                        {
                            DurationFloat = 0.0
                            Minutes = 0
                            Hours = 0
                            
                            let startaddress = self.sourceLocationDetail?.value?.address
                            let Desaddress = self.destinationLocationDetail?.address
                            
                            let ArryLocation = TwoLocationSourceAndDestination(Sourc: startaddress!, Destination: Desaddress!)
                            
                            if ArryLocation.count == 0
                            {
                                UIApplication.shared.keyWindow?.make(toast: "It is not possible to create a route between chosen points.")
                                
                                return
                            }
                            
                            let elements = ArryLocation.value(forKey: "elements")as! NSArray
                            
                            print(elements)
                            
                            let distanceArry = elements.value(forKey: "distance")as! NSArray
                            
                            print(distanceArry)
                            
                            let distancetext = distanceArry[0]as! NSArray
                            
                            
                            let Dicdata = distancetext[0]as! NSDictionary
                            
                            
                            let Distancetotal = Dicdata.value(forKey: "text")as! String
                            
                            print(Distancetotal)
                            
                            let Arr2 = Distancetotal.components(separatedBy: " ")
                            
                            let DurationString = Arr2[0]
                            
                            let myFloat : Float = NSString(string: DurationString).floatValue
                            
                            DurationFloat = myFloat
                            
                            let durationArry = elements.value(forKey: "duration")as! NSArray
                            
                            print(durationArry)
                            
                            let  durationtext = durationArry[0]as! NSArray
                            
                            let Dicdata1 = durationtext[0]as! NSDictionary
                            
                            let Durationtotal = Dicdata1.value(forKey: "text")as! String
                            print(Durationtotal)
                            
                            let Arr = Durationtotal.components(separatedBy: " ")
                            
                            var min:String = "0"
                            var hours:String = "0"
                            
                            
                            if Arr.count == 2
                            {
                                if Durationtotal.contains("hours")
                                {
                                    hours   = Arr[0]
                                    
                                    Hours = Hours + Int(hours)!
                                    
                                }
                                else
                                {
                                    min   = Arr[0]
                                    
                                    Minutes = Minutes + Int(min)!
                                }
                                
                            }
                            else
                            {
                                hours   = Arr[0]
                                min   = Arr[2]
                                
                                Minutes = Minutes + Int(min)!
                                
                                Hours = Hours + Int(hours)!
                                
                            }
                            
                            WayPointCalculation()
                            
                        }
                        else
                        {
                            
                            DurationFloat = 0.0
                            Minutes = 0
                            Hours = 0
                            
                            let startaddress = self.sourceLocationDetail?.value?.address
                            let Desaddress = self.destinationLocationDetail?.address
                            
                            let ArryLocation = TwoLocationSourceAndDestination(Sourc: startaddress!, Destination: Desaddress!)
                            
                            
                            if ArryLocation.count == 0
                            {
                                UIApplication.shared.keyWindow?.make(toast: "It is not possible to create a route between chosen points.")
                                
                                return
                            }
                            
                            let elements = ArryLocation.value(forKey: "elements")as! NSArray
                            
                            let distanceArry = elements.value(forKey: "distance")as! NSArray
                            
                            let distancetext = distanceArry[0]as! NSArray
                            
                            let Dicdata = distancetext[0]as! NSDictionary
                            
                            let Distancetotal = Dicdata.value(forKey: "text")as! String
                            
                            let Arr2 = Distancetotal.components(separatedBy: " ")
                            
                            let DurationString = Arr2[0]
                            
                            let myFloat : Float = NSString(string: DurationString).floatValue
                            
                            DurationFloat = myFloat
                            
                            let durationArry = elements.value(forKey: "duration")as! NSArray
                            
                            let  durationtext = durationArry[0]as! NSArray
                            
                            let Dicdata1 = durationtext[0]as! NSDictionary
                            
                            let Durationtotal = Dicdata1.value(forKey: "text")as! String
                            
                            let Arr = Durationtotal.components(separatedBy: " ")
                            
                            var min:String = "0"
                            var hours:String = "0"
                            
                            if Arr.count == 2
                            {
                                if Durationtotal.contains("hours")
                                {
                                    hours   = Arr[0]
                                    Hours = Int(hours)!
                                }
                                else
                                {
                                    min   = Arr[0]
                                    
                                    Minutes =  Int(min)!
                                }
                                
                            }
                            else
                            {
                                hours   = Arr[0]
                                min   = Arr[2]
                                
                                Minutes =  Int(min)!
                                
                                Hours = Int(hours)!
                            }
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "HH:mm"
                            let currentTime = dateFormatter.string(from: Date())
                            print(currentTime)
                            
                            let ServiceType = getServiceTyperequest()
                            ServiceType.passenger = "1"
                            ServiceType.suitcase = "0"
                            ServiceType.vehicle_type = "0"
                            ServiceType.total_kilometer = String(DurationFloat)
                            ServiceType.total_hours = String(Hours)
                            ServiceType.total_minutes = String(Minutes)
                            ServiceType.chbs_service_type_id = "1"
                            ServiceType.start_time = currentTime
                            
                            self.presenter?.post(api: .getServiceType, data: ServiceType.toData())
                        }
                        
                        
                    }
                    else
                    {
                        var Poipricelogic = checkPoiPriceLogicrequst()
                        
                        Poipricelogic.start_location_lat = self.sourceLocationDetail?.value?.coordinate.latitude
                        Poipricelogic.start_location_lng = self.sourceLocationDetail?.value?.coordinate.longitude
                        Poipricelogic.dest_location_lat = self.destinationLocationDetail?.coordinate.latitude
                        Poipricelogic.dest_location_lng = self.destinationLocationDetail?.coordinate.longitude
                        
                        self.presenter?.post(api: .checkPoiPriceLogic, data: Poipricelogic.toData())
                    }
                }
                
            }
            
        }
        
        
        func onError(api: Base, message: String, statusCode code: Int) {
            
            DispatchQueue.main.async {
                self.loader.isHidden = true
                if api == .locationServicePostDelete {
                    UIApplication.shared.keyWindow?.make(toast: message)
                } else {
                    if code != StatusCode.notreachable.rawValue && api != .checkRequest && api != .cancelRequest{
                        showAlert(message: message.localize(), okHandler: nil, fromView: self)
                    }
                    
                }
                if api == .sendRequest || api == .sendStopRequest  {
                    self.removeLoaderView()
                }
            }
        }
        
        func getServiceList(api: Base, data: [Service]) {
            
            if api == .servicesList {
                DispatchQueue.main.async {  // Show Services
                    //                    if self.withoutDest {
                    //                        self.showRideNowWithoutDest(with: data)
                    //                    }else{
                    self.showRideNowView(with: data)
                    //                    }
                    //                    self.getAllProviders()
                }
            }
            
        }
        
        func getProviderList(api: Base, data: [Provider]) {
            if api == .getProviders {  // Show Providers in Current Location
                DispatchQueue.main.async {
                    self.listOfProviders = data
                    self.showProviderInCurrentLocation(with: self.listOfProviders!,serviceTypeID:0)
                }
            }
        }
        
        func getRequest(api: Base, data: Request?) {
            
            print(data?.request_id ?? 0)
            
            if api == .sendRequest || api == .sendStopRequest
            {
                self.success(api: api, data: nil)
                
                self.currentRequestId = data?.request_id ?? 0
                self.checkForProviderStatus()
                
                if data?.message == Constants.string.scheduleReqMsg {
                    UIApplication.shared.keyWindow?.makeToast(Constants.string.rideCreated.localize())
                    
                    
                    /* self.textStopLocation.text = ""
                     self.viewStopLocation.isHidden = true
                     self.view_line.isHidden = true
                     self.view_squer.isHidden = true*/
                    
                    clearAllView()
                    self.removeLoaderView()
                }else{
                    DispatchQueue.main.async {
                        self.showLoaderView(with: self.currentRequestId)
                    }
                }
            }
        }
        
        func success(api: Base, message: String?) {
            riderStatus = .none
            self.loader.isHideInMainThread(true)
        }
        
        func getWalletEntity(api: Base, data: WalletEntity?) {
            
        }
        
        func success(api: Base, data: WalletEntity?) {
            
            
            if api == .updateRequest {
                riderStatus = .none
                return
            }
            else if api == .locationServicePostDelete {
                self.presenter?.get(api: .locationService, parameters: nil)
            }else if api == .rateProvider  {
                riderStatus = .none
                getAllProviders()
                return
            }
            else if api == .payNow {
                self.isInvoiceShowed = true
                
                //                paytym
                //                self.makePaymentWithPaytm(paymentEntity: data)
                
                //                payumoney
                //                self.makePaymentWithPayumoney(paymentEntity: data)
                
            }
            else if api == .cancelRequest
            {
                riderStatus = .none
            }
            else
            {
                riderStatus = .none // Make Ride Status to Default
                //                if api == .payNow { // Remove PayNow if Card Payment is Success
                //                    self.removeInvoiceView()
                //                }
            }
        }
        
        func getLocationService(api: Base, data: LocationService?) {
            
            self.loader.isHideInMainThread(true)
            storeFavouriteLocations(from: data)
        }
        
        func getProfile(api: Base, data: Profile?)
        {
            Common.storeUserData(from: data)
            storeInUserDefaults()
        }
        
        func getReason(api: Base, data: [ReasonEntity]) {
            self.cancelReason = data
        }
        
        func getExtendTrip(api: Base, data: ExtendTrip) {
            print(data)
        }
    }
    
    //MARK:- PayTM Payment Gateway
//    extension HomeViewController {
//        func makePaymentWithPaytm(paymentEntity: PayTmEntity?) {
//            
//            PGServerEnvironment().selectServerDialog(self.view, completionHandler: {(type: ServerType) -> Void in
//                
//                let amount: String = "\(paymentEntity?.TXN_AMOUNT ?? 0.0)"
//                let customerId: String = "\(paymentEntity?.CUST_ID ?? "")"
//                let type :ServerType = .eServerTypeStaging
//                let order = PGOrder(orderID: (paymentEntity?.ORDER_ID)!,
//                                    customerID: customerId,
//                                    amount: amount,
//                                    eMail: (paymentEntity?.EMAIL)!,
//                                    mobile: (paymentEntity?.MOBILE_NO)!)
//                
//                order.params = [Constants().mid: (paymentEntity?.MID)!,
//                                Constants().orderId: (paymentEntity?.ORDER_ID)!,
//                                Constants().custId: customerId,
//                                Constants().mobileNo: (paymentEntity?.MOBILE_NO)!,
//                                Constants().emailId: (paymentEntity?.EMAIL)!,
//                                Constants().channelId: (paymentEntity?.CHANNEL_ID)!,
//                                Constants().website: (paymentEntity?.WEBSITE)!,
//                                Constants().txnAmount: amount,
//                                Constants().industryType: (paymentEntity?.INDUSTRY_TYPE_ID)!,
//                                Constants().checksumhash: (paymentEntity?.CHECKSUMHASH)!,
//                                Constants().callbackUrl: (paymentEntity?.CALLBACK_URL)!]
//                
//                let txnController = PGTransactionViewController().initTransaction(for: order) as! PGTransactionViewController
//                //                self.txnController = self.txnController?.initTransaction(for: order) as? PGTransactionViewController
//                txnController.title = "Paytm Payments"
//                txnController.setLoggingEnabled(true)
//                if(type != ServerType.eServerTypeNone) {
//                    txnController.serverType = type
//                } else {
//                    return
//                }
//                txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
//                txnController.delegate = self
//                self.navigationController?.pushViewController(txnController, animated: true)
//            })
//        }
//    }
    
    //MARK:- PGTransactionDelegate
    
//    extension HomeViewController: PGTransactionDelegate {
//        //this function triggers when transaction gets finished
//        func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
//            let msg : String = responseString
//            var titlemsg : String = ""
//            if let data = responseString.data(using: String.Encoding.utf8) {
//                do {
//                    if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
//                        titlemsg = jsonresponse["STATUS"] as? String ?? ""
//                    }
//                } catch {
//                    print("Something went wrong")
//                }
//            }
//            let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
//            let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
//                action -> Void in
//                controller.navigationController?.popViewController(animated: true)
//            }
//            actionSheetController.addAction(cancelAction)
//            self.present(actionSheetController, animated: true, completion: nil)
//        }
//        //this function triggers when transaction gets cancelled
//        func didCancelTrasaction(_ controller : PGTransactionViewController) {
//            controller.navigationController?.popViewController(animated: true)
//        }
//        //Called when a required parameter is missing.
//        func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
//            controller.navigationController?.popViewController(animated: true)
//        }
//    }
//
    
    //MARK:- BrainTree Payment
    
    extension HomeViewController {
        func fetchBrainTreeClientToken() {
            self.presenter?.get(api: .getbraintreenonce, parameters: nil)
        }
        
        func getBrainTreeToken(api: Base, data: TokenEntity) {
            guard let token: String = data.token else {
                return
            }
            self.showDropIn(newToken: token)
        }
        
        
        func showDropIn(newToken: String) {
            let newRequest =  BTDropInRequest()
            let dropIn = BTDropInController(authorization: newToken, request: newRequest)
            { (controller, result, error) in
                if (error != nil) {
                    print("ERROR")
                } else if (result?.isCancelled == true) {
                    print("CANCELLED")
                } else if let result = result {
                    // Use the BTDropInResult properties to update your UI
                    // result.paymentOptionType
                    // result.paymentMethod
                    // result.paymentIcon
                    // result.paymentDescription
                    print(result)
                }
                controller.dismiss(animated: true, completion: nil)
            }
            self.present(dropIn!, animated: true, completion: nil)
        }
    }
    
    // Mark:- Pay with payumoney on Invoice payment
    
    extension HomeViewController {
        func makePaymentWithPayumoney(paymentEntity: PayUMoneyEntity) {
            print(paymentEntity as Any)
            PayUServiceHelper.sharedManager()?.getPayment(self, paymentEntity.email, "8179722510", paymentEntity.firstname,"\((paymentEntity.amount)!)", paymentEntity.txnid, paymentEntity.merchant_id, paymentEntity.key, paymentEntity.payu_salt, paymentEntity.surl, paymentEntity.curl, productInfo: paymentEntity.productinfo, udf1: "\(self.currentRequestId)", didComplete: { (dict, error) in
                
                if let result = dict?["result"] as? NSDictionary {
                    var payUEntity = PayUMoneyEntity()
                    payUEntity.request_id = self.currentRequestId
                    let txnId = (result.value(forKey: Constants().stxnid))
                    let param = [Constants().sid : self.currentRequestId,
                                 Constants().spay : txnId!,
                                 Constants().swallet : 0,
                                 Constants().stype : UserType.user.rawValue,
                                 Constants().suid : User.main.id ?? ""] as [String : Any]
                    self.presenter?.get(api: .payUMoneySuccessResponse, parameters: param)
                }
                
            }) { (error) in
                print("Payment Process Breaked")
            }
        }
    }
    
    
    
    
    
    
    
    extension String {
        func toDouble() -> Double {
            if let unwrappedNum = Double(self) {
                return unwrappedNum
            } else {
                // Handle a bad number
                print("Error converting \"" + self + "\" to Double")
                return 0.0
            }
        }
    }

