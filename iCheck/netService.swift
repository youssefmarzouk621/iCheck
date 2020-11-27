//
//  netService.swift
//  iCheck
//
//  Created by Youssef Marzouk on 27/11/2020.
//

import Foundation

enum MyResult<T,E:Error> {
    case success(T)
    case failure(E)
}
class netService {
    let baseUrl = "https://localhost/api"
    func request(endpoint:String,
                 parameters:[String:Any],
                 completion: @escaping (Result<Customer,Error>) -> Void) {
        guard let url = URL(string:baseUrl + endpoint) else {
            completion(.failure(netError.badUrl))
            return
        }
        var request = URLRequest(url:url)
        
        var components = URLComponents()
        
        var queryItems = [URLQueryItem]()
        
        for (key,value) in parameters {
            let queryItem = URLQueryItem(name:key,value:String(describing: value))
            queryItems.append(queryItem)
        }
        
        components.queryItems = queryItems
        
        let queryItemData = components.query?.data(using: .utf8)
        
        request.httpBody = queryItemData
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded",forHTTPHeaderField : "Content-Type")
        
        
        
        
        
    }

}
enum netError:Error {
    case badUrl
}
    
