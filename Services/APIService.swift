//
//  APIService.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//

import Foundation

// Neuer Fehler für unveränderte Daten
enum DataError: Error {
    case unchanged
}

class StockDataFetcher {
    // Neue Eigenschaft, um die zuletzt abgerufenen Daten zu speichern
    private var lastFetchedData: [StockDataPoint]?
    
    func fetch(url: URL, completion: @escaping (Result<[StockDataPoint], Error>) -> Void) {

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let stockData = try decoder.decode([MyData].self, from: data)
                    let reversedStockData = Array(stockData.reversed())
                    
                    var resultArray: [StockDataPoint] = []
                    for data in reversedStockData {
                        resultArray.append(StockDataPoint(date: data.date, close: data.close))
                    }
                    
                    // Überprüfen, ob die neuen Daten mit den zuletzt abgerufenen Daten übereinstimmen
                    if self.lastFetchedData == resultArray {
                        completion(.failure(DataError.unchanged))
                    } else {
                        self.lastFetchedData = resultArray // Aktualisieren Sie lastFetchedData
                        completion(.success(resultArray))
                    }
                } catch {
                    print("Error during JSON serialization: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}







