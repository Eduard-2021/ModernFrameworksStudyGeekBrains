//
//  RegisterViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit

class RegisterViewController: UIViewController {
    
    var loginAndRegisterViewModel: LoginAndRegisterViewModel?
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
    }


    @IBAction func registerButtonDidTap(_ sender: Any) {
        guard let loginAndRegisterViewModel = loginAndRegisterViewModel,
              let login = loginTextField.text,
              let password = passwordTextField.text
        else {
            return
        }
        loginAndRegisterViewModel.register(login: login, password: password)
    }
}
