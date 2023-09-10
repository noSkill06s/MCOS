//
//  ChartUpdateLastDataPoint.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 10.09.23.
//

import UIKit

class StockDataManager {
    
    weak var viewController: ChartController? // Referenz zum Haupt-ViewController

    init(controller: ChartController) {
        self.viewController = controller
    }

    @objc func updateLastDataPoint() {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: .fifteenMinutes, searchStock: viewController?.searchStock ?? "", fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                guard let lastDataPoint = data.last else { return }
                
                if self?.viewController?.plotData.last?.date == lastDataPoint.date {
                    self?.viewController?.plotData[self!.viewController!.plotData.count - 1] = lastDataPoint
                } else {
                    self?.viewController?.plotData.append(lastDataPoint)
                    if let plotDataCount = self?.viewController?.plotData.count, plotDataCount > 48 {
                        self?.viewController?.plotData.remove(at: 0)
                    }
                }
                
                DispatchQueue.main.async {
                    self?.viewController?.graphView.hostedGraph?.reloadData()
                    
                    if let lastDataPoint = self?.viewController?.plotData.last,
                       let firstDataPoint = self?.viewController?.plotData.first {
                        let range = "\(firstDataPoint.close) - \(lastDataPoint.close)"
                        self?.viewController?.stockProfileRange.text = "   " + range
                        
                        let change = lastDataPoint.close - firstDataPoint.close
                        self?.viewController?.stockProfileChanges.text = String(format: "%.2f", change)
                        self?.viewController?.stockCourse.text = "\(lastDataPoint.close)"
                    }
                }
                
            case .failure(let error):
                if let dataError = error as? DataError, dataError == .unchanged {
                    return
                } else {
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
}
