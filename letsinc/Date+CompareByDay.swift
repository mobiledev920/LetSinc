//
//  Date+CompareByDay.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 07/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
extension Date {
    func compareByDay(date: Date) -> Int {
        
        let order = Calendar.current.compare(self, to: date, toGranularity: .day)
        switch order {
        case .orderedSame:
            return 0
        case .orderedAscending:
            return -1
        case .orderedDescending:
            return 1
        }
    }
    
    func isBetweeen(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
    
    func isBetweeenIninclusive(date date1: Date, andDate date2: Date) -> Bool {
        let fallsBetween = (date1.withoutTime()...date2.withoutTime()).contains(self.withoutTime())
        print("Between \(fallsBetween)")
        return fallsBetween
//        return date1.withoutTime().compare(self.withoutTime()).rawValue == self.withoutTime().compare(date2.withoutTime()).rawValue
//        return date1.withoutTime().compare(self.withoutTime()).rawValue * self.withoutTime().compare(date2.withoutTime()).rawValue > 0
    }
    
    func isContain(date date1: Date, andDate date2: Date, containDate: Date) -> Bool {
        let fallsContain = (date1.withoutTime()...date2.withoutTime()).contains(containDate)
        return fallsContain
    }
    
    func withoutTime() -> Date {
        let timeInterval = floor(self.timeIntervalSinceReferenceDate / 86400) * 86400
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }
    
    func dayFromDate() -> Int {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "dd"
        let dayString = formatter.string(from: self)
        let dayInt = Int(dayString)
        
        return dayInt!
    }
    
    func monthFromDate() -> Int {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "MM"
        let monthString = formatter.string(from: self)
        let monthInt = Int(monthString)
        return monthInt!
    }
    
    func yearFromDate() -> Int {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.dateFormat = "yyyy"
        let yearString = formatter.string(from: self)
        let yearInt = Int(yearString)
        return yearInt!
    }
    
}

