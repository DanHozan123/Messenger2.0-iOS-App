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
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Buttons
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    
    //Views
    @IBOutlet weak var repeatPasswordLineView: UIView!
    
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
    
    @IBAction func loginButttonPressed(_ sender: Any) {
        
        if isDataInputedFor(type: isLogin ? .login : .registration){
            isLogin ? loginUser() : registerUser()
        }
        else {
            ProgressHUD.failed("All fields are required")
            
        }
    }
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        // reset password
        if isDataInputedFor(type: .passwordReset){
            resetPassword()
        } else {
            ProgressHUD.failed("Mail is required")
        }
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        //resend verification mail
        if isDataInputedFor(type: .resendEmail){
            resendVerificationEmail()
        } else {
            ProgressHUD.failed("Mail is required")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
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
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
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
        
        let loginImage = UIImage(named: login ? "loginBtn" : "registerBtn")
        loginButton.setImage(loginImage, for: .normal)
        signUpButton.setTitle(login ? "Sign Up" : "Login", for: .normal)
        signUpLabel.text = (login ? "Don't have an account?" : "Have an account?")
        
        UIView.animate(withDuration: 0.5) {
            self.repeatPasswordLabel.isHidden = login
            self.repeatPasswordTextField.isHidden = login
            self.repeatPasswordLineView.isHidden = login
        }
        
    }
    
    private func updatePlaceholdersLabels(textField: UITextField){
        switch textField {
        case emailTextField:
            emailLabel.text = emailTextField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = passwordTextField.hasText ? "Password" : ""
        case repeatPasswordTextField:
            repeatPasswordLabel.text = repeatPasswordTextField.hasText ? "Repeat Password" : ""
        default: break
        }
    }
    
    //MARK: - Helpers
    
    private enum InputType {
        case login
        case registration
        case passwordReset
        case resendEmail
    }
    
    private func isDataInputedFor(type: InputType) -> Bool {
        switch type {
        case .login:
            return emailTextField.text != "" && passwordTextField.text != ""
        case .registration:
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        case .passwordReset:
            return emailTextField.text != ""
        case .resendEmail:
            return emailTextField.text != ""
        }
        
    }
 
    private func loginUser(){
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                if isEmailVerified {
                    self.goToApp()
                } else {
                    ProgressHUD.failed("Please verify email.")
                    self.resendEmailButton.isHidden = false
                }
            } else {
                ProgressHUD.failed(error!.localizedDescription)
            }
            
        }
    }
    
    private func registerUser(){
        if passwordTextField.text == repeatPasswordTextField.text {
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { error in
                if error == nil {
                    ProgressHUD.succeed("Verification email sent")
                    self.resendEmailButton.isHidden = false
                }
                else {
                    ProgressHUD.failed(error!.localizedDescription)
                }
            }
            
        } else {
            ProgressHUD.failed("The passwords don't match")
        }
    }
    
    private func resetPassword() {
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.succeed("Reset link sent to email.")
            } else {
                ProgressHUD.failed(error!.localizedDescription)
            }
        }
    }
    
    private func resendVerificationEmail() {
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) { (error) in
            
            if error == nil {
                ProgressHUD.succeed("New verification email sent.")
            } else {
                ProgressHUD.failed(error!.localizedDescription)
            }
        }
    }
    
    
    //MARK: - Navigation
    private func goToApp() {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
}
