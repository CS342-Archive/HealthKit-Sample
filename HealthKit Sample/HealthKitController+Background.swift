//
//  HealthKitController+Background.swift
//  HealthKit Sample
//
//  Created by Santiago Gutierrez on 3/1/21.
//

import HealthKit

extension HealthKitController {
    
    func enableBackgroundDelivery() {
        getHealthAuthorization { (success, _) in
            if success {
                self.setUpBackgroundDelivery(forTypes: self.hkTypesToReadInBackground)
            }
        }
    }
    
    fileprivate func setUpBackgroundDelivery(forTypes types: Set<HKQuantityType>) {
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil, updateHandler: { (query, completionHandler, error) in
                
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                self.query(quantityType: type, completion: { result, error in
                    if (error == nil) {
                        //TODO: send result
                        print("background query for \(type.identifier) with \(result.count) result(s)")
                    }
                    dispatchGroup.leave()
                })
                
                dispatchGroup.notify(queue: .main, execute: {
                    completionHandler()
                })
            })
            
            healthStore.execute(query)
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate, withCompletion: { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
    }
    
}
