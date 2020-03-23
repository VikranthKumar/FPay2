//
//  APIService.swift
//  FPay2
//
//  Created by Vikranth Kumar on 22/03/20.
//  Copyright © 2020 VikranthKumar. All rights reserved.
//

import Foundation
import Combine

// MARK:- Protocol
protocol APIRequestType {
    associatedtype Response: Decodable
    
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

protocol APIServiceType {
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType
}

// MARK:- Error
enum APIServiceError: Error {
    case responseError
    case parseError(Error)
    
    var message: String {
        switch self {
        // TODO: More Exhaustive Cases
        case .responseError: return "Network Error"
        case .parseError: return "Parse Error"
        }
    }
}

// MARK:- Service
final class APIService: APIServiceType {
    
    func response<Request>(from request: Request) -> AnyPublisher<Request.Response, APIServiceError> where Request: APIRequestType {
        
        let pathURL = URL(string: AppConstants.baseUrl + request.path)!
        
        var urlComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = request.queryItems
        
        let request = URLRequest(url: urlComponents.url!)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { data, urlResponse in data }
            .mapError { _ in APIServiceError.responseError }
            .decode(type: Request.Response.self, decoder: JSONDecoder())
            .mapError(APIServiceError.parseError)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK:- Requests
struct SearchRepoRequest: APIRequestType {
    typealias Response = RepoList
    
    var path: String { return "search/repositories" }
    var queryItems: [URLQueryItem] = []
    
    init(query: String, sort: String, order: String, page: Int) {
        self.queryItems.append(URLQueryItem(name: "q", value: query))
        if !sort.isEmpty {
            self.queryItems.append(URLQueryItem(name: "sort", value: sort))
        }
        if !order.isEmpty {
            self.queryItems.append(URLQueryItem(name: "order", value: order))
        }
        self.queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
    }
}

struct RepoDetailsRequest: APIRequestType {
    
    typealias Response = RepoDetails
    
    let path: String
    var queryItems: [URLQueryItem] = []
    
    init(pathEnd: String) {
        self.path = "repos/\(pathEnd)"
    }
}
