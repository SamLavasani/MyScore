//
//  APIManager.swift
//  MyScore
//
//  Created by Samuel on 2019-06-12.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Alamofire

class APIManager {
    
    static let shared = APIManager()
    
    func apiRequest(url: URL, onSuccess: @escaping(Data) -> Void, onFailure: @escaping(Error) -> Void){
        let tokenHeader = HTTPHeader(name: "X-Auth-Token", value: ApiKey.apiKey)
        let headers = HTTPHeaders([tokenHeader])
        AF.request(url, method: .get, parameters: [:], headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                onSuccess(data)
            case .failure(let error):
                print("No bueno \(error.localizedDescription)")
                onFailure(error)
            }
        }
    }
}
