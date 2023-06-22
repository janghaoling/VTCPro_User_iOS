//
//  RepeatWeekdayViewController.swift
//  TranxitUser
//
//  Created by Xiaoming Tian on 4/5/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class RepeatWeekdayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lbRepeat: UILabel!
    var recurrentReq : Array<Int> = []
    var dateString : String = ""
    let weekly = [Constants.string.Sunday.localize(), Constants.string.Monday.localize(), Constants.string.Tuesday.localize(), Constants.string.Wednesday.localize(), Constants.string.Thursday.localize(), Constants.string.Friday.localize(), Constants.string.Saturday.localize()]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.string.Repeat.localize()
        lbRepeat.text = Constants.string.Repeat.localize()
        let txtback =  "\(Constants.string.Back.localize())"
        let bk = "<"
        let back = "\(bk) \(txtback)"
        btnBack.setTitle(back, for: .normal)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickDone(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        let previousViewController = navigationController?.viewControllers.last as? HomeViewController
        previousViewController?.resetRecurrent(data: self.recurrentReq)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekly.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepeatWeeklySelection", for: indexPath)
//        (cell.contentView.viewWithTag(1) as! UIImageView).image = (recurrentReq.contains(weekly[indexPath.row]) ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
        (cell.contentView.viewWithTag(1) as! UIImageView).image = (recurrentReq.contains(indexPath.row) ? #imageLiteral(resourceName: "check") : #imageLiteral(resourceName: "check-box-empty")).withRenderingMode(.alwaysTemplate)
        let every = Constants.string.Every.localize()
        (cell.contentView.viewWithTag(2) as! UILabel).text = "\(every) \(weekly[indexPath.row])"
        (cell.contentView.viewWithTag(3) as! UILabel).text = ""//"\(dateString.prefix(8))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if recurrentReq.contains(indexPath.row) {
            recurrentReq.remove(at: recurrentReq.firstIndex(of:indexPath.row)!)
        } else {
            recurrentReq.append(indexPath.row)
        }
        tableView.reloadData()
    }
}
