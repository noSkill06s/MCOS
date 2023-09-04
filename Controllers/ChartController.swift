//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
// Aleynadfdddffdfddf

import CorePlot
import UIKit

class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate, CPTAxisDelegate {
    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!

    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        presentTimeFrameSelector(in: self) { timeFrame in
            self.loadChartData(with: timeFrame)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChartData(with: .fifteenMinutes)
    }

    func loadChartData(with timeFrame: TimeFrame) {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: timeFrame, fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data)")
                // Reduzieren Sie die Daten auf die letzten 48 Datenpunkte
                self?.plotData = Array(data.suffix(48))
                DispatchQueue.main.async {
                    self?.initializeGraph()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }

    func initializeGraph() {
        configureGraphView(for: graphView, plotData: plotData, delegate: self)
        configurePlot(for: graphView, dataSource: self, delegate: self)
    }
}

extension ChartController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        let count = UInt(self.plotData.count)
        return count
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            return NSNumber(value: Int(record)) // Ändern Sie dies, um den Index zu verwenden
        case .Y:
            let yValue = self.plotData[Int(record)].close
            return yValue as NSNumber
        default:
            return 0
        }
    }
}





