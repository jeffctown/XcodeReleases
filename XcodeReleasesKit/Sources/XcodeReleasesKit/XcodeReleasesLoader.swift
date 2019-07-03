//
//  XcodeReleasesLoader.swift
//  
//
//  Created by Jeff Lett on 7/3/19.
//

import Foundation

public struct XcodeReleasesLoader {
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    public static let xcodeReleasesURLString = "https://xcodereleases.com/data.json"
    
    public enum Error: Swift.Error, LocalizedError {
        case invalidURL(String)
        case networkingError(Swift.Error)
        case serverError(Int)
        case parsingError(Swift.Error)
        case unknown
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL(let u):
                return "URL Creation Error: \(u)"
            case .networkingError(let e):
                return "Networking Error: \(e)"
            case .serverError(let statusCode):
                return "Server Error: \(statusCode)"
            case .parsingError(let e):
                return "Parsing Error: \(e)"
            case .unknown:
                return "Unknown Error"
            }
        }
    }
    
    public init() {}
    
    public func releases(urlString: String = Self.xcodeReleasesURLString, completion: @escaping (Result<[XcodeRelease], Error>) -> Void) throws {
        guard let url = URL(string: urlString) else {
            throw Error.invalidURL(urlString)
        }
        
        Self.session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(Error.networkingError(error)))
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                let decoder = JSONDecoder()
                do {
                    let xcodeReleases = try decoder.decode([XcodeRelease].self, from: data)
                    completion(.success(xcodeReleases))
                } catch {
                    completion(.failure(.parsingError(error)))
                }
            } else if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                completion(.failure(.serverError(response.statusCode)))
            } else {
                completion(.failure(.unknown))
            }
        }.resume()
    }
    
}
