//
//  NavigationBarProtocol.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 18/02/2023.
//

import Foundation
import UIKit

class BaseNavigationController: UIViewController {
    
    func setupNavigationBar(text: String) {
        setupTextField(text: text)
        setupLogoButton()
    }
    
    @objc func setupTextField(text: String) {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        textField.placeholder = "Search images, vectors and more"
        textField.borderStyle = .roundedRect
        textField.delegate = self as? UITextFieldDelegate
        textField.text = text
        self.navigationItem.titleView = textField
    }
    
    @objc func setupLogoButton() {
        let logoButton = UIBarButtonItem(image: UIImage(named: "logo.png"), style: .plain, target: self, action: #selector(logoButtonAction))
        self.navigationItem.leftBarButtonItem = logoButton
    }
    
    @objc func logoButtonAction() {
        navigationController?.popViewController(animated: true)
    }
}
