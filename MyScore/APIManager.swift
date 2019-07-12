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
    
    func request(url: URL, onSuccess: @escaping(Data) -> Void, onFailure: @escaping(Error) -> Void){
        let tokenHeader : [String : String] = ["X-RapidAPI-Key" : ApiKey.apiKey]
        Alamofire.request(url, method: .get, parameters: [:], headers: tokenHeader).responseData { (response) in
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
