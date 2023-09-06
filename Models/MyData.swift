//
//  MyData.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 01.08.23.
//

import Foundation

struct MyData: Decodable {
    let date: String
    let close: Double
}

struct StockDataPoint: Equatable {
    let date: String
    let close: Double
}
