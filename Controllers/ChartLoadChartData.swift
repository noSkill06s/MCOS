//
//  ChartLoadChartData.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import Foundation

func loadChartDataGlobal(with timeFrame: TimeFrame, searchStock: String,fetcher: StockDataFetcher, completion: @escaping (Result<[StockDataPoint], Error>) -> Void) {
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

    let url = URL(string: "https://financialmodelingprep.com/api/v3/historical-chart/\(timeFrameParameter)/\(searchStock)?apikey=87508d18defb2ad368deda0763edaaab")!


    // Rufe die Daten von der API ab und aktualisiere den Plot
    fetcher.fetch(url: url) { result in
        switch result {
        case .success(let data):
            completion(.success(data))
        case .failure(let error):
            completion(.failure(error)) // Debug-Ausgabe
        }
    }
}

