//
//  LoginViewController.swift
//  Wardah
//
//  Created by Hani on 4/25/17.
//  Copyright © 2017 BrainSocket. All rights reserved.
//

import UIKit

class LoginViewController: AbstractController {
    
    // MARK: Properties
    // login view
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
//    @IBOutlet weak var signupButton: UIButton!
    
    // process View
    
    
    
    var homeViewControllerId = "HomeNavigationController"
    var signupViewControllerId = "SignupViewController"
    
    // MARK: Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.setCustomeNavBarTitle(type: .signin)
        self.showNavBackButton = true        
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // Customize all view members (fonts - style - text)
    override func customizeView() {
        super.customizeView()
        // set fonts
        loginButton.titleLabel?.font = AppFonts.normal
        

        loginButton.backgroundColor = AppColors.orange
    
        emailTextField.placeholder = "Username".localized
        passwordTextField.placeholder = "Password".localized
        // text field styles
        emailTextField.appStyle()
        passwordTextField.appStyle()
        
        // customize button
        loginButton.makeRounded()
        loginView.addShaddow()
        
    }
    
    // Build up view elements
    override func buildUp() {
        loginView.animateIn(mode: .animateInFromBottom, delay: 0.2)
    }
    
    // MARK: Actions
    @IBAction func loginAction(_ sender: UIButton) {
        // validate email
        guard let db = DataStore.shared.currentCompany?.DB else {return}
        if let email = emailTextField.text, !email.isEmpty {
                // validate password
                if let password = passwordTextField.text, !password.isEmpty {
                
                        // start login process
                        self.showActivityLoader(true)
                    
                    ApiManager.shared.getProjectList(companyDB: db, username: email, password: password) { (success, error, resutl) in
                            // stop loading
                            self.showActivityLoader(false)
                        
                            // login success
                            if (success) {
                                DataStore.shared.logged = 1
                                DataStore.shared.currentCompany?.projects = resutl
                                let user = AppUser()
                                user.username = email
                                user.password = password
                                DataStore.shared.me = user
                                self.presentViewController(viewControllerId: self.homeViewControllerId,storyBoard: .mainStoryboard)
                            } else {
                                if let msg = error?.errorName{
                                    self.showMessage(message:msg, type: .error)
                                    
                                }
                            }
                        }
                    
                } else {
                    self.passwordTextField.errorMode()
                    showMessage(message:"Enter Password".localized, type: .warning)
                }
          
        } else {
            self.emailTextField.errorMode()
            showMessage(message:"Enter Username".localized, type: .warning)
        }
    }
    
    
    // MARK: textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            loginAction(loginButton)
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    
}

