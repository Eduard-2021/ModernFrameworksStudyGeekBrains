//
//  LoginViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var loginAndRegisterViewModel: LoginAndRegisterViewModel?
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var enterButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
        configureLoginBindings()
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
    
    private func configureLoginBindings() {
        Observable
            .combineLatest(loginTextField.rx.text, passwordTextField.rx.text)
            .map { login, password in
                return !(login ?? "").isEmpty && !(password ?? "").isEmpty
            }
            .bind { [weak enterButtonOutlet] inputFilled in
                enterButtonOutlet?.isEnabled = inputFilled
            }
    }
}
