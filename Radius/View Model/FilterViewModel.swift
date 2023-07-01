//
//  FilterViewModel.swift
//  Radius
//
//  Created by Admin on 29/06/23.
//

import Foundation

class MyViewModel {
    private var myModel: APIResponse?
    
    func fetchData(completion: @escaping (Error?) -> Void) {
        let url = URL(string: "https://my-json-server.typicode.com/iranjith4/ad-assignment/db")!
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIResponse.self, from: data)
                self?.myModel = result
                completion(nil)
            } catch {
                completion(error)
            }
        }
        task.resume()
    }
}
