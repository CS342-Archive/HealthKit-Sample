//
//  CKSendHelper.swift
//  CardinalKit_Example
//
//  Created by Santiago Gutierrez on 12/22/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Firebase

enum CKError: Error {
    case unknownError
    case unauthorized
}

class CKSendHelper {
    
    /**
     Given a JSON dictionary, use the Firebase SDK to store it in Firestore.
    */
    static func sendToFirestore(json: [String:Any], collection: String, withIdentifier identifier: String? = nil, onCompletion: ((Bool, Error?) -> Void)? = nil) {
        guard let authCollection = CKStudyUser.shared.authCollection/*,
              let userId = CKStudyUser.shared.currentUser?.uid*/ else {
            onCompletion?(false, CKError.unauthorized)
            return
        }
        
        let db = Firestore.firestore()
        db.collection(authCollection + "\(collection)")
            .document(identifier ?? UUID().uuidString)
            .setData(json) { err in
            
            if let err = err {
                print("[CKSendHelper] sendToFirestore() - error writing document: \(err)")
                onCompletion?(false, err)
            } else {
                print("[CKSendHelper] sendToFirestore() - document successfully written!")
                onCompletion?(true, nil)
            }
        }
    }
    
}
