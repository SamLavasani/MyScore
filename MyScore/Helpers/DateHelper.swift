//
//  DateHelper.swift
//  MyScore
//
//  Created by Samuel on 2019-06-17.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation

struct DateHelper {
    
   static func getDateFromString(date: String) -> DateInfo {
        var dateInfo = DateInfo()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let newDate = formatter.date(from: date) {
            //print(date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            let date = formatter.string(from: newDate)
            formatter.dateFormat = "HH:mm"
            let time = formatter.string(from: newDate)
            dateInfo.date = date
            dateInfo.time = time
        }
        return dateInfo
    }
    
    static func getCurrentDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    static func getCurrentYear() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
}
