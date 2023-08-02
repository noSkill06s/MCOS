//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//
import CorePlot
import UIKit


class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate {
    
    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetcher = StockDataFetcher()
        fetcher.fetch { [weak self] result in
            switch result {
            case .success(let data):
                print("Data fetched successfully: \(data)") // Debug-Ausgabe
                self?.plotData = data
                DispatchQueue.main.async {
                    self?.initializeGraph()
                    self?.configurePlot() // Rufen Sie configurePlot() hier auf
                }
            case .failure(let error):
                print("Error fetching data: \(error)") // Debug-Ausgabe
            }
        }
    }
    
    func initializeGraph(){
        print("Configuring graph view")
        configureGraphView()
        //configurePlot()
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
        graph.paddingLeft = 40.0
        graph.paddingTop = 30.0
        graph.paddingRight = 15.0
        
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

        let yMinAdjusted = yMin - (yMin * 0.05)
        let yMaxAdjusted = yMax + (yMax * 0.05)

        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else { return }
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
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
        }

        if let y = axisSet.yAxis {
            print("Configuring y-axis")
            y.majorIntervalLength   = 5 // Dieser Wert hängt von dem Bereich Ihrer Schlusskurse ab und sollte entsprechend angepasst werden
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




