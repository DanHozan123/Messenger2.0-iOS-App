//
//  ViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 03.02.2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    
    //Labeles
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabelOutlet: UILabel!
    @IBOutlet weak var signUpLabelOutlet: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    @IBOutlet weak var loginTextFieldOutlet: UITextField!
    @IBOutlet weak var repeatPasswordTextFieldOutlet: UILabel!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineViewOutlet: UIView!
    
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    
    
    //MARK: - IBActions
    
    @IBAction func loginButttonPressedAction(_ sender: Any) {
    }
    @IBAction func forgotPasswordButtonPressedAction(_ sender: Any) {
    }
    @IBAction func resendEmailButtonPressedAction(_ sender: Any) {
    }
    @IBAction func signUpButtonPressedAction(_ sender: Any) {
    }
    
    


}

