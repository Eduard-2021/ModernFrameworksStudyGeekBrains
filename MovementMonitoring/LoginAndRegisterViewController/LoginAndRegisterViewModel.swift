//
//  LoginViewModel.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit
import RealmSwift

class LoginAndRegisterViewModel {
    var appCoordinator: Coordinator?
    var unCorrectLoginOrPassword: ((UIAlertController) -> Void)?
    
    func check(login: String, password: String) {
        
        if let loginFromRealm = try? RealmService.loadAndCheck(typeOf: User.self, login: login),
            loginFromRealm.count != 0,
            loginFromRealm.first?.password == password  {
            appCoordinator?.goToMapViewController()
        }
        else {
            showAlert {alertController in
                guard let unCorrectLoginOrPassword = self.unCorrectLoginOrPassword else {return}
                unCorrectLoginOrPassword(alertController)
            }
        }
    }
    
    func registrationButtonDidTap(){
        appCoordinator?.goToRegisterViewController()
    }
    
    
    func register(login: String, password: String) {
        
        if let oldUserTypeResult = try? RealmService.loadAndCheck(typeOf: User.self, login: login) {
            let oldUserWithNewPassword = User()
            guard let oldUserTypeUser = oldUserTypeResult.first else {return}
            oldUserWithNewPassword.login =  oldUserTypeUser.login
            oldUserWithNewPassword.password = password
            try? RealmService.delete(object: oldUserTypeResult)
            try? RealmService.save(items: [oldUserWithNewPassword])

        } else {
            let loginAndPasswordForSave = User()
            loginAndPasswordForSave.login = login
            loginAndPasswordForSave.password = password
            try? RealmService.save(items: [loginAndPasswordForSave])
        }
        appCoordinator?.goToMapViewController()
    }
    
    func showAlert(completionAlertController: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: "Ошибка!",
                                                message: "Неверный логин или пароль. Повторите ввод ",
                                                preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "Ok", style: .default, handler:{ _ in
//            let  pathAndCamera = self.loadAndShowPreviousTrack()
//            completionDidTapOk(pathAndCamera.0, pathAndCamera.1)
        })
        alertController.addAction(buttonOk)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        completionAlertController(alertController)
    }  
}
