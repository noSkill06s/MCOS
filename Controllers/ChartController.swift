//
//  ChartController.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//

import UIKit
import CorePlot

import UIKit
import CorePlot

class ChartController: UIViewController {
    
    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetcher = StockDataFetcher()
        fetcher.fetch { [weak self] result in
            switch result {
            case .success(let data):
                self?.plotData = data
                DispatchQueue.main.async {
                    self?.initializeGraph()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func initializeGraph(){
        configureGraphView()
    }
       
    func configureGraphView(){
        graphView.allowPinchScaling = false
                
        // Rest des Codes bleibt gleich...
        
        //Configure graph
        let graph = CPTXYGraph(frame: graphView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        graphView.hostedGraph = graph
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
    }
}

extension ChartController: CPTScatterPlotDataSource, CPTScatterPlotDelegate {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any? {
       switch CPTScatterPlotField(rawValue: Int(field))! {
            case .X:
                // Hier verwenden wir einfach den Index des Datums im Array als X-Wert.
                return NSNumber(value: Int(record))
            case .Y:
                return self.plotData[Int(record)].close as NSNumber
            default:
                return 0
        }
    }
}


