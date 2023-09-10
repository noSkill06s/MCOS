//
//  ChartLoadChartDataManager.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 11.09.23.
//

import Foundation

class ChartDataManager {
    
    weak var viewController: ChartController? // Referenz zum Haupt-ViewController
    
    init(controller: ChartController) {
        self.viewController = controller
    }
    
    func loadChartData(with timeFrame: TimeFrame) {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: timeFrame, searchStock: viewController?.searchStock ?? "", fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                // Reduzieren Sie die Daten auf die letzten 48 Datenpunkte
                self?.viewController?.plotData = Array(data.suffix(48))
                DispatchQueue.main.async {
                    self?.viewController?.initializeGraph()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}
