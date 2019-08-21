//
//  LoginViewController.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import UIKit

// Конфигурация связки ключей
struct KeychainConfiguratio {
    static let serviceName = "TouchMeIn"
    static let accessGroup: String? = nil
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createInfoLabel: UILabel!
    @IBOutlet weak var touchIdButton: UIButton!
    
    
    
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButton = 0 // метка для кнопки создать
    let loginButtonTag = 1 //метка для кнопки вход
    let touchMe = TouchIdAuth()

    override func viewDidLoad() {
        super.viewDidLoad()
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        if hasLogin {
            loginButton.setTitle("Вход", for: .normal)
            loginButton.tag = loginButtonTag
            createInfoLabel.isHidden = true
        } else {
            loginButton.setTitle("Создать", for: .normal)
            loginButton.tag = createLoginButton
            createInfoLabel.isHidden = false
        }
        
        if let storedUserName = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUserName
        }
        
        touchIdButton.isHidden = !touchMe.canEvaluatePolicy() || !hasLogin
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else { return false}
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguratio.serviceName, account: username, accessGroup: KeychainConfiguratio.accessGroup)
            let KeychainPassword = try passwordItem.readPassword()
            return password == KeychainPassword
        } catch {
            fatalError("\(error)")
        }
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        guard
            let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty && !newPassword.isEmpty else {
                let alertView = UIAlertController(title: "Problema so vxodom", message: "Net imeni ili parola", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Eche raz", style: .default, handler: nil)
                alertView.addAction(okAction)
                present(alertView, animated: true, completion:  nil)
                
                return
    
    }
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        
        
        if sender.tag == createLoginButton {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey {
                UserDefaults.standard.setValue(usernameTextField.text, forKey: "username")
            }
            
            
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguratio.serviceName, account: newAccountName, accessGroup: KeychainConfiguratio.accessGroup)
                
                try passwordItem.savePassword(newPassword)
            } catch {
                fatalError("ошибка свзякт ключей\(error)")
            }
            UserDefaults.standard.set(true,forKey:  "hasLoginKey")
            loginButton.tag = loginButtonTag
            performSegue(withIdentifier: "DismissLogin", sender: self)
            
            
        } else if sender.tag == loginButtonTag {
            if checkLogin(username: usernameTextField.text!, password: passwordTextField.text!) {
                performSegue(withIdentifier: "DismissLogin", sender: self)
            } else {
                let allertView = UIAlertController(title: "Problem", message: "WRON LOGIN", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Eche raz", style: .default, handler: nil)
                allertView.addAction(okAction)
                present(allertView, animated: true, completion:  nil)
            }
            
            
        }
    }
    
    @IBAction func touchIdLoginAction(_ sender: UIButton) {
        touchMe.authenticateUser { message in
            
            if let message = message {
                // если сообщение не нил то указать оповешение
                
                let allertView = UIAlertController(title: "ошибка", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "xthl gj,thb", style: .default, handler: nil)
                allertView.addAction(okAction)
                self.present(allertView, animated: true, completion:  nil)
            } else {
                //нет сообщения значит аутетнтификация просшла успешно
                self.performSegue(withIdentifier: "DismissLogin", sender: self)
            }
            
        }
    }
    

}
