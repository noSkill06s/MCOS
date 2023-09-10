//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 08.08.23.
//

import CorePlot
import UIKit

class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate, CPTAxisDelegate {
    
    var searchStock = "META" //Hier kommt der Input dann vom SearchController aktuell pseudo AAPL
    
    var plotData: [StockDataPoint] = []
    var chartStockProfileArray: [StockProfile] = []
    
    @IBOutlet var graphView: CPTGraphHostingView!
    
    @IBOutlet var stockProfileSymbol: UILabel!
    @IBOutlet var stockProfileRange: UILabel! // aktualisieren bei jedem Datenpunkt
    @IBOutlet var stockProfileChanges: UILabel! // aktualisieren bei jedem Datenpunkt
    @IBOutlet var stockProfileCompanyName: UILabel!
    @IBOutlet var stockProfileCurrency: UILabel!
    @IBOutlet var stockProfileImage: UIImageView!
    
    var updateTimer: Timer?
    var pulsingTimer: Timer?
    var lastPointSymbolSize: CGSize = CGSize(width: 13.0, height: 13.0)

    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        presentTimeFrameSelector(in: self) { timeFrame in
            self.loadChartData(with: timeFrame)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadChartData(with: .fifteenMinutes)
        loadStockProfile()
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLastDataPoint), userInfo: nil, repeats: true)
        pulsingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(startPulsingLastPoint), userInfo: nil, repeats: true)
    }

    func loadChartData(with timeFrame: TimeFrame) {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: timeFrame, searchStock: self.searchStock, fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
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

    func loadStockProfile() {
        let profileFetcher = StockProfileFetcher()
        profileFetcher.fetchProfile(for: searchStock) { [weak self] result in // "AAPL" ist hier nur ein Beispiel
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self?.stockProfileSymbol.text = profile.symbol
                    self?.stockProfileCompanyName.text = "   "+profile.companyName
                    self?.stockProfileCurrency.text = profile.currency
                    
                    // Bild von URL laden
                    if let url = URL(string: profile.image) {
                        print("profile.image: \(url)")
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    self?.stockProfileImage.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
            }
        }
    }

    func initializeGraph() {
        configureGraphView(for: graphView, plotData: plotData, delegate: self)
        configurePlot(for: graphView, dataSource: self, delegate: self)
    }
    
    @objc func updateLastDataPoint() {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: .fifteenMinutes, searchStock: searchStock,fetcher: fetcher) { [weak self] result in
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
                    
                    // Aktualisieren des Bereichs (Range) und der Änderungen (Changes)
                    if let lastDataPoint = self?.plotData.last {
                        if let firstDataPoint = self?.plotData.first {
                            let range = "\(firstDataPoint.close) - \(lastDataPoint.close)"
                            self?.stockProfileRange.text = "   "+range
                            
                            let change = lastDataPoint.close - firstDataPoint.close
                            self?.stockProfileChanges.text = String(format: "%.2f", change)
                        }
                    }
                }
            case .failure(let error):
                if let dataError = error as? DataError, dataError == .unchanged {
                    // Wenn die Daten unverändert sind, tun wir nichts.
                    return
                } else {
                    print("Error fetching data: \(error)")
                }
            }
        }
    }

    
    @objc func startPulsingLastPoint() {
        let stepSize = CGFloat(10.0)
        // Verwenden Sie eine Bedingung, um zwischen den Größen zu wechseln
        if lastPointSymbolSize.width > 10.0 {
            lastPointSymbolSize = CGSize(width: lastPointSymbolSize.width - stepSize, height: lastPointSymbolSize.height - stepSize)
        } else {
            lastPointSymbolSize = CGSize(width: lastPointSymbolSize.width + stepSize, height: lastPointSymbolSize.height + stepSize)
        }
        
        DispatchQueue.main.async {
            self.graphView.hostedGraph?.reloadData()
        }
    }



    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateTimer?.invalidate()
        updateTimer = nil
        pulsingTimer?.invalidate()
        pulsingTimer = nil
    }
}

extension ChartController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if plot.identifier as? String == "last-point-plot" {
            return 1 // Nur ein Punkt für den speziellen Plot
        }
        return UInt(self.plotData.count)
    }
    
    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        if plot.identifier as? String == "last-point-plot" {
            guard let lastDataPoint = self.plotData.last else { return nil }
            switch CPTScatterPlotField(rawValue: Int(field))! {
            case .X:
                return NSNumber(value: self.plotData.count - 1)
            case .Y:
                return NSNumber(value: lastDataPoint.close)
            default:
                return nil
            }
        }
        
        // Der restliche Code für den Hauptplot
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            return NSNumber(value: Int(record))
        case .Y:
            let yValue = self.plotData[Int(record)].close
            return yValue as NSNumber
        default:
            return nil
        }
    }

    func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
        if idx == self.plotData.count - 1 {  // Überprüfen, ob es der letzte Datenpunkt ist
            let plotSymbol = CPTPlotSymbol.ellipse()
            plotSymbol.fill = CPTFill(color: CPTColor.orange())
            plotSymbol.size = lastPointSymbolSize  // Verwenden Sie die Instanzvariable
            return plotSymbol
        }
        return nil  // Für andere Datenpunkte kein spezielles Symbol
    }
}






