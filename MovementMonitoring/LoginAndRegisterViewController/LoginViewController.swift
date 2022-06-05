//
//  LoginViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    var loginAndRegisterViewModel: LoginAndRegisterViewModel?
//    var unCorrectLoginOrPassword: ((UIAlertController) -> Void)?
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginAndRegisterViewModel?.unCorrectLoginOrPassword = {alertController in
            self.present(alertController, animated: true)
        }
    }
    
    
    @IBAction func enterButtonDidTap(_ sender: Any) {
        guard let loginAndRegisterViewModel = loginAndRegisterViewModel,
              let login = loginTextField.text,
              let password = passwordTextField.text
        else {
            return
        }
        loginTextField.text = ""
        passwordTextField.text = ""
        loginAndRegisterViewModel.check(login: login, password: password)
    }
    
    @IBAction func registrationButtonDidTap(_ sender: Any) {
        loginAndRegisterViewModel?.registrationButtonDidTap()
    }
}
