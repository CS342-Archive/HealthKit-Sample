//
//  HealthKit_SampleApp.swift
//
//  Created by Santiago Gutierrez on 2/13/21.
//

import SwiftUI
import Firebase
import FirebaseAuth
import Granola

@main
struct HealthKit_SampleApp: App {
    
    init() {
        
        // Configure our Firebase instance & sign-in anonymously
        // Your application must have a valid GoogleService-Info.plist config file from Firebase.
        // NOTE: you must enable anonymous auth by:
        //  (1) open https://console.firebase.google.com/
        //  (2) open the Auth section
        //  (3) On the Sign-in Methods page, enable the Anonymous sign-in method.
        
        FirebaseApp.configure()
        Auth.auth().signInAnonymously()
        
        /* **************************************************************
        *  See this function for an example for how-to enable background
        *  data delivery. You will need to merge this code with Firestore.
        **************************************************************/
        // HealthKitController.shared.enableBackgroundDelivery()
        
        sendHealthKitDataOnLaunch()
    }
    
    fileprivate func sendHealthKitDataOnLaunch() {
        /* **************************************************************
        *  Querying for a type on-launch and processing results
        **************************************************************/
        HealthKitController.shared.query(quantityTypeIdentifier: .stepCount) { (results, error) in
            
            for item in results {
                var mappedItem = [String:Any]()
                mappedItem["startDate"] = item.startDate.iso8601withFractionalSeconds
                mappedItem["endDate"] = item.endDate.iso8601withFractionalSeconds
                mappedItem["count"] = item.count
                mappedItem["quantityType"] = item.quantityType.identifier
                mappedItem["source"] = "\(item.sourceRevision.productType ?? "Unknown")-\(item.sourceRevision.source.bundleIdentifier)"
                mappedItem["quantity"] = item.quantity.doubleValue(for: .count())
                
                /* **************************************************************
                *  Units have mathematical modifiers -- e.g. BPM
                **************************************************************/
                // let unit: HKUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                
                CKSendHelper.sendToFirestore(json: mappedItem, collection: "healthKit", withIdentifier: item.uuid.uuidString)
            }
            
            /* **************************************************************
            *  If you are sending large amounts of data very frequently,
            *  try to make a single database request with all information.
            **************************************************************/
            // var dataMap = [[String:Any]]()
            // for each result, per mappedItem:
                // dataMap.append(mappedItem)
            // CKSendHelper.sendToFirestore(json: ["payload": dataMap], collection: "healthKit")
            
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
