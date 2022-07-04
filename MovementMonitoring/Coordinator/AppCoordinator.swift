//
//  Coordinator.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit

class AppCooridanor: Coordinator{
    let navigationController: UINavigationController
    var loginAndRegisterViewModel: LoginAndRegisterViewModel?
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(){
        loginAndRegisterViewModel = LoginAndRegisterViewModel()
        goToLoginViewController()
    }
    
    func goToLoginViewController() {
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        
        loginViewController.loginAndRegisterViewModel = loginAndRegisterViewModel
        loginAndRegisterViewModel?.appCoordinator = self
        navigationController.pushViewController(loginViewController, animated: true)
    }
    
    func goToMapViewController(){
        guard let MapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as? MapViewController else {
            return
        }
        navigationController.pushViewController(MapViewController, animated: true)
    }
    
    func goToRegisterViewController() {
        guard let registerViewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController else {
            return
        }
        
        registerViewController.loginAndRegisterViewModel = loginAndRegisterViewModel
        navigationController.pushViewController(registerViewController, animated: true)
    }

}
