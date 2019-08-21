//
//  TouchIdAuth.swift
//  Restaurants
//
//  Created by Елизавета Салтыкова on 04/08/2019.
//  Copyright © 2019 Елизавета Салтыкова. All rights reserved.
//

import Foundation
import LocalAuthentication


class TouchIdAuth {
    let context = LAContext()
    
    //проверка доступности id
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        //в пораметре передается обработчик которые выполница после завершения аутотенфикации
        
        // проверм доступность тач ид
        
        guard canEvaluatePolicy() else {
            completion("BFx atqc bl yt yfcnhjty" )
            return}
        
        let biometry = context.biometryType == .faceID ? " Fase ID" : "Touch ID"
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Вход с помощью \(biometry)") { (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completion(nil)
                }
            } else {
                //обработка ошибок
                let message: String
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "Не удалось распознать личность"
                case LAError.userCancel?:
                    message = "Вы нажали отмену"
                case LAError.userFallback?:
                    message = "Вы нажали ввод пароля"
                    
                default:
                    message = "\(biometry) биометрки не нарстреон "
                }
                
                completion(message)
            }
        }
    }
}

