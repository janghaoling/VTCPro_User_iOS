//
//  ScheduleRideNoteView.swift
//  TranxitUser
//
//  Created by Ansar on 11/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation
import UIKit

class ScheduleRideNoteView : UIView {
    
    //MARK:- IBOutlet

    @IBOutlet weak var lblAppNameTitle:UILabel!
    @IBOutlet weak var fieldNote:HoshiTextField!
    @IBOutlet weak var btnDismiss:UIButton!
    @IBOutlet weak var btnSubmit:UIButton!
    @IBOutlet weak var viewContainer: UIView!
    
    //MARK:- LocalVariable
    
    var onClickDismiss : ((String, Bool)->Void)? //both for submit and dismiss
    var keyboardShow: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setFont()
        localize()
        fieldNote.delegate = self
        self.btnDismiss.addTarget(self, action: #selector(tapDismiss), for: .touchUpInside)
        self.btnSubmit.addTarget(self, action: #selector(tapSubmit), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
}

//MARK:- LocalMethod

extension ScheduleRideNoteView {
    
    func setFont()  {
        Common.setFont(to: lblAppNameTitle)
        Common.setFont(to: fieldNote)
        Common.setFont(to: btnDismiss)
        Common.setFont(to: btnSubmit)
        lblAppNameTitle.textColor = .primary
        btnDismiss.backgroundColor = .primary
        btnSubmit.backgroundColor = .secondary
    }
    
    func localize() {
        lblAppNameTitle.text = Constants.string.writeanoteforthedriver.localize()
        btnDismiss.setTitle(Constants.string.no_thanks.localize(), for: .normal)
        btnSubmit.setTitle(Constants.string.send.localize(), for: .normal)
        fieldNote.text = ""
    }
    
    @objc func tapDismiss() {
        onClickDismiss!("", true)
    }
    
    @objc func tapSubmit() {
        onClickDismiss!(fieldNote.text!, false)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if !keyboardShow {
                keyboardShow = true
                self.viewContainer.frame.origin.y = (((UIApplication.shared.keyWindow?.frame.size.height)!/2+(self.viewContainer.frame.height/2))-keyboardHeight)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardShow = false
        self.viewContainer.frame.origin.y = (((UIApplication.shared.keyWindow?.frame.size.height)!/2)-(self.viewContainer.frame.height/2))
    }
    
}

//MARK:- UITextFieldDelegate

extension ScheduleRideNoteView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if (textField.text?.isEmpty)! {
//            textField.text = "0"
//        }
        return true
    }
}
