//
//  HealthKitController.swift
//  HealthKit Sample
//
//  Created by Santiago Gutierrez on 3/1/21.
//

import Foundation
import HealthKit

enum HealthKitError : Error {
    case notAvailable
}

class HealthKitController {
    
    static let shared = HealthKitController()
    
    var healthStore: HKHealthStore = HKHealthStore()
    
    //global config
    var defaultPredicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, end: Date(), options: .strictStartDate)
    let defaultSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
    let defaultQueryLimit = Int(HKObjectQueryNoLimit)
    
    let hkTypesToRead: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
        HKObjectType.activitySummaryType(), //NEW
        HKObjectType.clinicalType(forIdentifier: .allergyRecord)!
    ]
    
    let hkTypesToWrite: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]
    
    var hkTypesToReadInBackground: Set<HKQuantityType> {
        return Set<HKQuantityType>(hkTypesToRead.compactMap { (type) -> HKQuantityType? in
            return (type as? HKQuantityType)
        })
    }
    
    func getHealthAuthorization(completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthKitError.notAvailable)
            return
        }
        
        let healthStore = HKHealthStore()
        healthStore.requestAuthorization(toShare: hkTypesToWrite, read: hkTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
}

extension HealthKitController {
    
    func querySumStats(quantityType: HKQuantityType, predicate: NSPredicate? = nil, unit: HKUnit = .count(), completion: @escaping (Double?, Error?) -> Void) {
        
        let predicate = predicate ?? defaultPredicate
        
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, stats, error) in
            
            var total = 0.0
            if let quantity = stats?.sumQuantity() {
                total = quantity.doubleValue(for: unit)
                completion(total, nil)
            } else {
                completion(total, error)
            }
            
        }
        
        healthStore.execute(query)
    }
    
    func querySumStats(quantityTypeIdentifier: HKQuantityTypeIdentifier, predicate: NSPredicate? = nil, unit: HKUnit = .count(), completion: @escaping (Double?, Error?) -> Void) {
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            fatalError("***should never fail when using built-in type identifiers***")
        }
        
        querySumStats(quantityType: sampleType, predicate: predicate, unit: unit, completion: completion)
    }

    
    func query(quantityType: HKQuantityType, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, limit: Int = Int(HKObjectQueryNoLimit), completion: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        let predicate = predicate ?? defaultPredicate
        let sortDescriptor = sortDescriptor ?? defaultSortDescriptor
        
        let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            
            guard let samples = samples as? [HKQuantitySample] else {
                completion([HKQuantitySample](), error)
                return
            }
            
            completion(samples, error)
        }
        
        healthStore.execute(query)
    }
    
    func query(quantityTypeIdentifier: HKQuantityTypeIdentifier, predicate: NSPredicate? = nil, sortDescriptor: NSSortDescriptor? = nil, limit: Int = Int(HKObjectQueryNoLimit), completion: @escaping ([HKQuantitySample], Error?) -> Void) {
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier) else {
            fatalError("***should never fail when using built-in type identifiers***")
        }
        
        query(quantityType: sampleType, predicate: predicate, sortDescriptor: sortDescriptor, limit: limit, completion: completion)
    }
    
}
