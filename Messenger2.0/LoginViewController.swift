//
//  ViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 03.02.2024.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    
    //Labeles
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPasswordLabelOutlet: UILabel!
    @IBOutlet weak var signUpLabelOutlet: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextFieldOutlet: UITextField!
    @IBOutlet weak var passwordTextFieldOutlet: UITextField!
    
    @IBOutlet weak var repeatPasswordTextFieldOutlet: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    @IBOutlet weak var resendEmailButtonOutlet: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineViewOutlet: UIView!
    
    //MARK: - Vars
    var isLogin = true
    
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateUIFor(login: true)
        setupTextFieldDelegates()
        setupBackgroundTap()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func loginButttonPressedAction(_ sender: Any) {
        // login
        if isLogin == true {
            if isDataInputedFor(type: "Login") != true {
                ProgressHUD.failed("All fields are required")
            }
        }
        // register
        else {
            if isDataInputedFor(type: "Registration") != true {
                ProgressHUD.failed("All fields are required")
            }
        }
    }
    @IBAction func forgotPasswordButtonPressedAction(_ sender: Any) {
        // reset password
        if isDataInputedFor(type: "Password") != true {
            ProgressHUD.failed("Mail is required")
        }
    }
    @IBAction func resendEmailButtonPressedAction(_ sender: Any) {
        //resend verification mail
        if isDataInputedFor(type: "Password") != true {
            ProgressHUD.failed("Mail is required")
        }
    }
    @IBAction func signUpButtonPressedAction(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Login" {
            updateUIFor(login: true)
        }
        else {
            updateUIFor(login: false)
        }
        isLogin.toggle()
        
    }
    
    //MARK: - Setup
    private func setupTextFieldDelegates() {
        emailTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        passwordTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        repeatPasswordTextFieldOutlet.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        updatePlaceholdersLabels(textField: textField)
    }
    
    private func setupBackgroundTap() {
        let tapGesture =  UITapGestureRecognizer(target: self, action: #selector(backgroundTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroundTap() {
        view.endEditing(false)
    }
    
    
    
    //MARK: - Animations
    
    private func updateUIFor(login: Bool){
        
        if login == true {
            loginButtonOutlet.setImage(UIImage(named: "loginBtn"), for: .normal)
            signUpButtonOutlet.setTitle("Sign Up", for: .normal)
            signUpLabelOutlet.text = "Don't have an account?"
            
            UIView.animate(withDuration: 0.5) {
                self.repeatPasswordLabelOutlet.isHidden = true
                self.repeatPasswordTextFieldOutlet.isHidden = true
                self.repeatPasswordLineViewOutlet.isHidden = true
            }
        }
        else {
            loginButtonOutlet.setImage(UIImage(named: "registerBtn"), for: .normal)
            signUpButtonOutlet.setTitle("Login", for: .normal)
            signUpLabelOutlet.text = "Have an account?"
            UIView.animate(withDuration: 0.5) {
                self.repeatPasswordLabelOutlet.isHidden = false
                self.repeatPasswordTextFieldOutlet.isHidden = false
                self.repeatPasswordLineViewOutlet.isHidden = false
            }
        }
        
    }
    
    private func updatePlaceholdersLabels(textField: UITextField){
        
        switch textField {
        case emailTextFieldOutlet:
            if emailTextFieldOutlet.hasText {
                emailLabelOutlet.text = "Email"
            }
            else{
                emailLabelOutlet.text = ""
            }
        case passwordTextFieldOutlet:
            if passwordTextFieldOutlet.hasText {
                passwordLabelOutlet.text = "Password"
            }
            else{
                passwordLabelOutlet.text = ""
            }
        case repeatPasswordTextFieldOutlet:
            if repeatPasswordTextFieldOutlet.hasText {
                repeatPasswordLabelOutlet.text = "Repeat Password"
            }
            else{
                repeatPasswordLabelOutlet.text = ""
            }
        default: break
        }
        
    }
    
    //MARK: - Helpes
    private func isDataInputedFor(type: String) -> Bool {
        switch type {
        case "Login":
            if (emailTextFieldOutlet.text != "" && passwordTextFieldOutlet.text != ""){
                return true
            } else {
                return false
            }
            
        case "Registration":
            if (emailTextFieldOutlet.text != "" && passwordTextFieldOutlet.text != "" && repeatPasswordTextFieldOutlet.text != ""){
                return true
            } else {
                return false
            }
        default:
            if (emailTextFieldOutlet.text != ""){
                return true
            } else {
                return false
            }
        }
    }
    
}

