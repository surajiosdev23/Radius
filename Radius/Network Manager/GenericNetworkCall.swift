import Foundation

public enum Result<Value> {
    case success(Value)
    case failure(Error)
}
struct CommonError : Codable{
    var error: String?
    var message: String?
}
enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    var localizedDescription: String {
        switch self {
        case .requestFailed: return "Request Failed"
        case .invalidData: return "Invalid Data"
        case .responseUnsuccessful: return "Response Unsuccessful"
        case .jsonParsingFailure: return "JSON Parsing Failure"
        case .jsonConversionFailure: return "JSON Conversion Failure"
        }
    }
}
//SURAJ: GenericNetworkCall FOR MANAGING API CALLS BY PASSING URL, METHOD TYPE, PARAMETERS AND RESPONSE CLASS
class GenericNetworkCall {
    func fetchData<T: Decodable>(url: String, method: String, params:[String:Any], responseClass: T.Type , completion:@escaping (Swift.Result<T?, ErrorPOJO>) -> Void) {
        print("URL : \(url)")
        print("params : \(params)")
        guard let url = URL(string: url) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    
                    print(error.localizedDescription)
                    completion(.failure(ErrorPOJO(message: error.localizedDescription)))
                    
                } else if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 200 {
                        
                        let mappedModel = try? JSONDecoder().decode(T.self, from: data!)
                        
                        if mappedModel != nil {
                            
                            completion(.success(mappedModel))
                            
                        } else {
                            completion(.failure(ErrorPOJO(message: error?.localizedDescription)))
                        }
                    } else {
                        completion(.failure(ErrorPOJO(message: "Something went wrong")))
                    }
                }
            }
        })
        task.resume()
    }
    
    
    struct ErrorPOJO: Error, Codable {
        var message: String?
    }
}

