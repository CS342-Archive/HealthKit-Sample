//
//  ContentView.swift
//  CareKit Sample
//
//  Created by Santiago Gutierrez on 2/13/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var authorizedHealthKit: Bool = false
    @State var stepCount: Double = 0.0
    @State var distance: Double = 0.0
    
    func populateViewData() {
        HealthKitController.shared.querySumStats(quantityTypeIdentifier: .stepCount) { (count, error) in
            if let count = count {
                self.stepCount = count
            }
        }
        HealthKitController.shared.querySumStats(quantityTypeIdentifier: .distanceWalkingRunning, unit: .mile()) { (distance, error) in
            if let distance = distance {
                self.distance = distance
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("HealthKit Authorized: \(authorizedHealthKit ? "true!" : "nope :(")")
                .padding(10)
            Text("Here is some data from the last 24 hours!")
                .bold()
                .padding(5)
            List {
                Text("Step Count: \(stepCount)")
                Text("Distance (mi): \(distance)")
            }
        }.onAppear {
            HealthKitController.shared.getHealthAuthorization() { success, error in
                print("getHealthAuthorization() \(success) with error \(String(describing: error))")
                self.authorizedHealthKit = success
                self.populateViewData()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
