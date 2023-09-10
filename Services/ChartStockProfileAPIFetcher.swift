//
//  ChartStockProfileAPIFetcher.swift
//  ChartViewController
//
//  Created by Burhan Cankurt on 09.09.23.
//

import Foundation

class StockProfileFetcher {
    func fetchProfile(for symbol: String, completion: @escaping (Result<StockProfile, Error>) -> Void) {
        let apiKey = "87508d18defb2ad368deda0763edaaab"
        let url = URL(string: "https://financialmodelingprep.com/api/v3/profile/\(symbol)?apikey=\(apiKey)")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let stockProfile = try decoder.decode([StockProfile].self, from: data)
                    guard let profile = stockProfile.first else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                        return
                    }
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}


