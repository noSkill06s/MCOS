//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//
import CorePlot
import UIKit
//TEST

class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate {
    
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
        let now = Date()
        var dateToCompare: Date

        switch timeFrame {
        case.oneMinutes:
            dateToCompare = now.addingTimeInterval(-1 * 60)
        case .fiveMinutes:
            dateToCompare = now.addingTimeInterval(-5 * 60)
        case .fifteenMinutes:
            dateToCompare = now.addingTimeInterval(-15 * 60)
        case .thirtyMinutes:
            dateToCompare = now.addingTimeInterval(-30 * 60)
        case .oneHour:
            dateToCompare = now.addingTimeInterval(-60 * 60)
        case .fourHours:
            dateToCompare = now.addingTimeInterval(-4 * 60 * 60)
        case .oneDay:
            dateToCompare = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return data.filter { dataPoint in
            if let date = dateFormatter.date(from: dataPoint.date) {
                return date >= dateToCompare
            }
            return false
        }
    }

    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!
 

    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Time Frame", message: nil, preferredStyle: .actionSheet)
        
        let timeFrames: [TimeFrame] = [.oneMinutes, .fiveMinutes, .fifteenMinutes, .thirtyMinutes, .oneHour, .fourHours, .oneDay]
        for timeFrame in timeFrames {
            let actionTitle: String
            switch timeFrame {
            case .oneMinutes: actionTitle = "1 Minutes"
            case .fiveMinutes: actionTitle = "5 Minutes"
            case .fifteenMinutes: actionTitle = "15 Minutes"
            case .thirtyMinutes: actionTitle = "30 Minutes"
            case .oneHour: actionTitle = "1 Hour"
            case .fourHours: actionTitle = "4 Hours"
            case .oneDay: actionTitle = "1 Day"
            }
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                self.loadChartData(with: timeFrame)
            }
            actionSheet.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Lade Daten für den Standardzeitrahmen (1 Tag) beim Start
        loadChartData(with: .fiveMinutes)

    }

    func loadChartData(with timeFrame: TimeFrame) {
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
        let fetcher = StockDataFetcher()
        fetcher.fetch(url: url) { [weak self] result in
            switch result {
            case .success(let data):
                // Finde den letzten Zeitpunkt, an dem Handelsdaten verfügbar sind
                guard let lastTradingDate = data.last?.date else { return }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                guard let lastTradingDateTime = dateFormatter.date(from: lastTradingDate) else { return }
                
                // Filter the data to only include the last 4 trading hours
                let fourHoursBeforeLastTrade = lastTradingDateTime.addingTimeInterval(-4 * 60 * 60)
                
                self?.plotData = data.filter { dataPoint in
                    if let date = dateFormatter.date(from: dataPoint.date) {
                        return date >= fourHoursBeforeLastTrade
                    }
                    return false
                }

                DispatchQueue.main.async {
                    self?.initializeGraph()
                }
            case .failure(let error):
                print("Error fetching data: \(error)") // Debug-Ausgabe
            }
        }
    }
    
    
    func initializeGraph(){
        print("Configuring graph view")
        configureGraphView()
        configurePlot() // Hey ChatGPT hier das meine ich und dann rufen wir sie hier wieder auf ist das okay?
    }
       
    func configureGraphView(){
        print("Inside configureGraphView")
        graphView.allowPinchScaling = false
                
        //Configure graph
        let graph = CPTXYGraph(frame: graphView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        graphView.hostedGraph = graph
        print("graphView.hostedGraph: \(String(describing: graphView.hostedGraph))") // Debug-Ausgabe
        graph.backgroundColor = UIColor.black.cgColor
        graph.paddingBottom = 40.0
        graph.paddingLeft = 50.0 // ursprünglich 40
        graph.paddingTop = 30.0
        graph.paddingRight = 5.0 // ursprünglich 15
        
        //Style for graph title
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.white()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 20.0
        titleStyle.textAlignment = .center
        graph.titleTextStyle = titleStyle

        //Set graph title
        let title = "CorePlot"
        graph.title = title
        graph.titlePlotAreaFrameAnchor = .top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 0.0)

        // Set plot space
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let xMin = dateFormatter.date(from: plotData.first?.date ?? "")?.timeIntervalSince1970 ?? 0
        let xMax = dateFormatter.date(from: plotData.last?.date ?? "")?.timeIntervalSince1970 ?? 0

        let yMin = plotData.min(by: { $0.close < $1.close })?.close ?? 0
        let yMax = plotData.max(by: { $0.close < $1.close })?.close ?? 0

        let yRange = yMax - yMin
        let paddingPercentage = 0.05 // 5% Padding

        let yMinAdjusted = yMin - (yRange * paddingPercentage)
        let yMaxAdjusted = yMax + (yRange * paddingPercentage)
        let adjustedRange = yMaxAdjusted - yMinAdjusted
        let majorInterval = adjustedRange / 10.0 // Teilt den Bereich in 10 Intervalle

        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin)) // Set xRange
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMinAdjusted), lengthDecimal: CPTDecimalFromDouble(yMaxAdjusted - yMinAdjusted))

        // Configure axes
        let axisSet = graph.axisSet as! CPTXYAxisSet
        
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.white()
        axisTextStyle.fontName = "HelveticaNeue-Bold"
        axisTextStyle.fontSize = 10.0
        axisTextStyle.textAlignment = .center
        let lineStyle = CPTMutableLineStyle()
        lineStyle.lineColor = CPTColor.white()
        lineStyle.lineWidth = 5
        let gridLineStyle = CPTMutableLineStyle()
        gridLineStyle.lineColor = CPTColor.gray()
        gridLineStyle.lineWidth = 0.5

        if let x = axisSet.xAxis {
            print("Configuring x-axis")
            x.majorIntervalLength   = 1
            x.minorTicksPerInterval = 0
            x.labelTextStyle = axisTextStyle
            x.minorGridLineStyle = gridLineStyle
            x.axisLineStyle = lineStyle
            x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            x.delegate = self

            // Set the x-axis to display dates
            x.labelingPolicy = .none

            // Create custom labels for each data point
            var customLabels = Set<CPTAxisLabel>()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Use the full format to extract the date
            let labelFormatter = DateFormatter()
            labelFormatter.dateFormat = "HH:mm" // Use the short format for the label
            for dataPoint in plotData {
                let date = dateFormatter.date(from: dataPoint.date) ?? Date()
                let calendar = Calendar.current
                if calendar.component(.minute, from: date) == 0 { // Only add label for full hours
                    let labelTextStyle = CPTMutableTextStyle()
                    labelTextStyle.color = CPTColor.white()
                    labelTextStyle.fontSize = 10.0
                    let label = CPTAxisLabel(text: labelFormatter.string(from: date), textStyle: labelTextStyle) // Use the short format here
                    label.tickLocation = NSNumber(value: date.timeIntervalSince1970)
                    label.offset = 3.0
                    customLabels.insert(label)
                }
            }
            x.axisLabels = customLabels
        }

        if let y = axisSet.yAxis {
            print("Configuring y-axis")
            y.majorIntervalLength = NSNumber(value: majorInterval) // Setzen Sie den berechneten Wert hier
            y.minorTicksPerInterval = 5 // Dieser Wert hängt von dem Bereich Ihrer Schlusskurse ab und sollte entsprechend angepasst werden
            y.minorGridLineStyle = gridLineStyle
            y.labelTextStyle = axisTextStyle
            y.alternatingBandFills = [CPTFill(color: CPTColor.init(componentRed: 255, green: 255, blue: 255, alpha: 0.03)),CPTFill(color: CPTColor.black())]
            y.axisLineStyle = lineStyle
            y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
            y.delegate = self
        }
    }
    
    func configurePlot() {
        print("Inside configurePlot") // Debug-Ausgabe
        let plot = CPTScatterPlot()
        let plotLineStile = CPTMutableLineStyle()
        plotLineStile.lineJoin = .round
        plotLineStile.lineCap = .round
        plotLineStile.lineWidth = 2
        plotLineStile.lineColor = CPTColor.white()
        plot.dataLineStyle = plotLineStile
        plot.curvedInterpolationOption = .catmullCustomAlpha
        plot.interpolation = .curved
        plot.identifier = "coreplot-graph" as NSCoding & NSCopying & NSObjectProtocol
        guard let graph = graphView.hostedGraph else { return }
        plot.dataSource = self
        plot.delegate = self
        graph.add(plot, to: graph.defaultPlotSpace)
    }
}

extension ChartController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        let count = UInt(self.plotData.count)
        print("numberOfRecords called, returning \(count)")
        return count
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            print("number(for:field:record:) called for X field, record \(record)")
            let date = dateFormatter.date(from: plotData[Int(record)].date) ?? Date()
            return NSNumber(value: date.timeIntervalSince1970)
        case .Y:
            let yValue = self.plotData[Int(record)].close
            print("number(for:field:record:) called for Y field, record \(record), returning \(yValue)")
            return yValue as NSNumber
        default:
            print("number(for:field:record:) called for unexpected field")
            return 0
        }
    }
}




