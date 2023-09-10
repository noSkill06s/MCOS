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

struct StockProfile: Decodable {
    let symbol: String
    let range: String
    let changes: Double
    let companyName: String
    let currency: String
    let image: String
}
