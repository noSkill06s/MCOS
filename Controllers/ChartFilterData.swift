//
//  ChartFilterData.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 07.08.23.
//

import Foundation

enum TimeFrame {
    case oneMinutes
    case fiveMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case fourHours
    case oneDay
}

func filterData(for timeFrame: TimeFrame, data: [(date: String, close: Double)]) -> [(date: String, close: Double)] {
    let now = Date()
    var dateToCompare: Date

    switch timeFrame {
    case.oneMinutes:
        dateToCompare = now.addingTimeInterval(-1 * 60)
    case .fiveMinutes:
        dateToCompare = now.addingTimeInterval(-5 * 60)
    case .fifteenMinutes:
        dateToCompare = now.addingTimeInterval(-15 * 60)
    case .thirtyMinutes:
        dateToCompare = now.addingTimeInterval(-30 * 60)
    case .oneHour:
        dateToCompare = now.addingTimeInterval(-60 * 60)
    case .fourHours:
        dateToCompare = now.addingTimeInterval(-4 * 60 * 60)
    case .oneDay:
        dateToCompare = Calendar.current.date(byAdding: .day, value: -1, to: now)!
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    return data.filter { dataPoint in
        if let date = dateFormatter.date(from: dataPoint.date) {
            return date >= dateToCompare
        }
        return false
    }
}
