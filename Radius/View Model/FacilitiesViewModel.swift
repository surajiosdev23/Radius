
import Foundation

class FacilitiesViewModel {
    let network = GenericNetworkCall()
    func getResponseData(url : String,completion: @escaping
                         (Swift.Result<APIResponse?, GenericNetworkCall.ErrorPOJO>) -> Void) {
        network.fetchData(url: url, method: "get", params: [String : Any](), responseClass: APIResponse.self) { (response) in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let err):
                print("ERROR \(err)")
                completion(.failure(err))
            }
        }
    }
}
