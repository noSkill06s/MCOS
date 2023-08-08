//
//  ChartLoadChartData.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import Foundation

func loadChartDataGlobal(with timeFrame: TimeFrame, fetcher: StockDataFetcher, completion: @escaping (Result<[(date: String, close: Double)], Error>) -> Void) {
    // Ändere die URL basierend auf dem ausgewählten Zeitrahmen
    let timeFrameParameter: String
    switch timeFrame {
    case .oneMinutes: timeFrameParameter = "1min"
    case .fiveMinutes: timeFrameParameter = "5min"
    case .fifteenMinutes: timeFrameParameter = "15min"
    case .thirtyMinutes: timeFrameParameter = "30min"
    case .oneHour: timeFrameParameter = "1hour"
    case .fourHours: timeFrameParameter = "4hour"
    case .oneDay: timeFrameParameter = "1day"
    }

    let url = URL(string: "https://financialmodelingprep.com/api/v3/historical-chart/\(timeFrameParameter)/META?apikey=87508d18defb2ad368deda0763edaaab")!

    // Rufe die Daten von der API ab und aktualisiere den Plot
    fetcher.fetch(url: url) { result in
        switch result {
        case .success(let data):
            // Finde den letzten Zeitpunkt, an dem Handelsdaten verfügbar sind
            guard let lastTradingDate = data.last?.date else {
                completion(.failure(NSError(domain: "DateError", code: 1001, userInfo: nil)))
                return
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let lastTradingDateTime = dateFormatter.date(from: lastTradingDate) else {
                completion(.failure(NSError(domain: "DateError", code: 1002, userInfo: nil)))
                return
            }
            
            // Filter the data to only include the last 4 trading hours
            let fourHoursBeforeLastTrade = lastTradingDateTime.addingTimeInterval(-4 * 60 * 60)
            
            let filteredData = data.filter { dataPoint in
                if let date = dateFormatter.date(from: dataPoint.date) {
                    return date >= fourHoursBeforeLastTrade
                }
                return false
            }

            completion(.success(filteredData))
        case .failure(let error):
            completion(.failure(error)) // Debug-Ausgabe
        }
    }
}
