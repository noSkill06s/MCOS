//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.


import CorePlot
import UIKit

class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate, CPTAxisDelegate {
    
    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!
    var updateTimer: Timer?

    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        presentTimeFrameSelector(in: self) { timeFrame in
            self.loadChartData(with: timeFrame)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChartData(with: .fifteenMinutes)
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLastDataPoint), userInfo: nil, repeats: true)
    }

    func loadChartData(with timeFrame: TimeFrame) {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: timeFrame, fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                print("\(data.count)")
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
    
    @objc func updateLastDataPoint() {
        // Hier rufen wir die Daten für den letzten Datenpunkt ab und aktualisieren den Chart
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: .fifteenMinutes, fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                guard let lastDataPoint = data.last else { return }
                // Überprüfen, ob der letzte Datenpunkt im `plotData` Array aktualisiert werden muss oder ein neuer hinzugefügt werden muss
                if self?.plotData.last?.date == lastDataPoint.date {
                    self?.plotData[self!.plotData.count - 1] = lastDataPoint
                } else {
                    self?.plotData.append(lastDataPoint)
                    if let plotDataCount = self?.plotData.count, plotDataCount > 48 {
                        self?.plotData.remove(at: 0)
                    }
                }
                DispatchQueue.main.async {
                    self?.graphView.hostedGraph?.reloadData()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
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





