import CorePlot
import UIKit

class ChartController: UIViewController, CPTBarPlotDataSource, CALayerDelegate, CPTAxisDelegate {
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    var plotData: [(date: String, close: Double)] = []
    @IBOutlet var graphView: CPTGraphHostingView!
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    @IBAction func timeFrameButtonTapped(_ sender: UIButton) {
        presentTimeFrameSelector(in: self) { timeFrame in
            self.loadChartData(with: timeFrame)
        }
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        loadChartData(with: .fiveMinutes)
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    func loadChartData(with timeFrame: TimeFrame) {
        let fetcher = StockDataFetcher()
        loadChartDataGlobal(with: timeFrame, fetcher: fetcher) { [weak self] result in
            switch result {
            case .success(let data):
                self?.plotData = data
                DispatchQueue.main.async {
                    self?.initializeGraph()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
/*----------------------------------------------------------------------------------------------------------------------------------------*/
    func initializeGraph() {
        print("Configuring graph view")
        configureGraphView(for: graphView, plotData: plotData, delegate: self)
        configurePlot(for: graphView, dataSource: self, delegate: self)
    }
}
/*----------------------------------------------------------------------------------------------------------------------------------------*/
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





