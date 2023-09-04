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
    // Da wir immer nur die letzten 48 Datenpunkte wollen, schneiden wir das Array entsprechend ab.
    let last48DataPoints = data.suffix(48)
    return Array(last48DataPoints)
}

