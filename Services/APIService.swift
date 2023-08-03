//
//  APIService.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 31.07.23.
//

import Foundation

class StockDataFetcher {
    func fetch(completion: @escaping (Result<[(date: String, close: Double)], Error>) -> Void) {
        // Definiere die URL, die du abrufen möchtest.
        let url = URL(string: "https://financialmodelingprep.com/api/v3/historical-chart/5min/META?apikey=87508d18defb2ad368deda0763edaaab")!

        // Erstelle eine "Task", die die eigentliche Netzwerkanfrage durchführt.
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // Dieser Block wird ausgeführt, wenn die Netzwerkanfrage abgeschlossen ist.
            
            // Überprüfe zuerst, ob bei der Anfrage ein Fehler aufgetreten ist.
            if let error = error {
                // Wenn ein Fehler aufgetreten ist, drucke eine Fehlermeldung und verlasse den Block.
                print("Error: \(error)")
                completion(.failure(error))
            }
            // Wenn kein Fehler aufgetreten ist, überprüfe, ob Daten zurückgegeben wurden.
            else if let data = data {
                // Versuche, die zurückgegebenen Daten in Swift-Objekte umzuwandeln.
                do {
                    let decoder = JSONDecoder()
                    let stockData = try decoder.decode([MyData].self, from: data)
                    let reversedStockData = Array(stockData.reversed())
                    // Erstelle ein leeres Array, um die Ergebnisse zu speichern.
                    var resultArray: [(date: String, close: Double)] = []
                    // Durchlaufe jedes Element in reversedStockData.
                    for data in reversedStockData {
                        resultArray.append((date: data.date, close: data.close))
                    }
                    // Nachdem du alle Elemente durchlaufen hast, rufe den Completion Handler mit dem Ergebnis-Array auf.
                    completion(.success(resultArray))
                }
                // Wenn beim Versuch, die Daten in Swift-Objekte umzuwandeln, ein Fehler auftritt, fange diesen Fehler und rufe den Completion Handler mit dem Fehler auf.
                catch {
                    print("Error during JSON serialization: \(error)")
                    completion(.failure(error))
                }
            }
        }
        // Sage der Task, dass sie starten soll.
        task.resume()
    }
}






