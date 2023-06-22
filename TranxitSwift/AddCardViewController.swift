//
//  AddCardViewController.swift
//  User
//
//  Created by CSS on 23/07/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import CreditCardForm
import Stripe

class AddCardViewController: UIViewController, CardIOPaymentViewControllerDelegate {
    
    //MARK:- IBOutlets
    
    @IBOutlet private weak var creditCardView : CreditCardFormView!
    
    //MARK:- Local variable
    
    let paymentTextField = STPPaymentCardTextField()
    
    private lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickScanCard(_ sender: Any) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        self.present(cardIOVC!, animated: true, completion: nil)
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
        
        let cardParams = STPCardParams()
        cardParams.number = cardInfo.cardNumber
        cardParams.expMonth = cardInfo.expiryMonth
        cardParams.expYear = cardInfo.expiryYear
        cardParams.cvc = cardInfo.cvv
        self.addCard(cardParams: cardParams)
    }
    
}

//MARK:- local methods

extension AddCardViewController {
    
    func addCard(cardParams:STPCardParams!) {
        
        self.loader.isHidden = false
        STPAPIClient.shared().createToken(withCard: cardParams) { (stpToken, error) in
            
            guard let token = stpToken?.tokenId else {
                self.loader.isHideInMainThread(true)
                return
            }
            
            
            // Dimpal
            
//            print(User.main.id)
            var cardEntity = CardEntity()
            cardEntity.stripe_token = token
         //   cardEntity.user_id =  User.main.id
            
            
            self.presenter?.post(api: .postCards, data: cardEntity.toData())
            
        }
        
    }
    
    func initialLoads() {
        
        self.creditCardView.cardHolderString =  String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        self.creditCardView.defaultCardColor = .primary
        self.createTextField()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.addCardPayments.localize()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.string.Done.localize(), style: .done, target: self, action: #selector(self.doneButtonClick))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.dismissKeyBoardonTap()
    }
    
    func createTextField() {
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        paymentTextField.numberPlaceholder = "XXXXXXXXXXXXXXXX"
        
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardView.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    //  Done Button Click
    
    @IBAction private func doneButtonClick() {
        self.view.endEditingForce()
//        self.addCard(cardParams: paymentTextField.cardParams)
    }
}

// MARK:- STPPaymentCardTextFieldDelegate

extension AddCardViewController : STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = textField.isValid
        creditCardView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingCVC()
    }
}

// MARK:- PostViewProtocol

extension AddCardViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    func success(api: Base, message: String?) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            let alert = showAlert(message: message) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}
