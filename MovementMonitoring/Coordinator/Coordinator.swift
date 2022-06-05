//
//  Coordinator.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit

protocol Coordinator{
    var navigationController: UINavigationController {get}
    func start()
    func goToLoginViewController()
    func goToMapViewController()
    func goToRegisterViewController()
}
