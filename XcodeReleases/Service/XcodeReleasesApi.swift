//
//  XcodeReleasesApi.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/5/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import Foundation
import XcodeReleasesKit



struct XcodeReleasesApi: NeedsEnvironment {
    
    static let log = false
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    
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
    
    var xcodeReleasesLoader: XcodeReleasesLoader = try! XcodeReleasesLoader(url: "\(Self.environment().apiUrl)/release")
    
    private enum ApiCommand {
        case postDevice
        case getDevice(String)
        case deleteDevice(String)
    }
    
    private enum HttpMethod: String {
        case post = "POST"
        case delete = "DELETE"
    }
    
    private func url(command: ApiCommand) -> String {
        switch command {
        case .getDevice(let id), .deleteDevice(let id):
            return "\(Self.environment().apiUrl)/device/\(id)"
        case .postDevice:
            return "\(Self.environment().apiUrl)/device"
        }
    }
    
    func postDevice(device: Device, completion: @escaping (Result<Device, Swift.Error>) -> Void) {
        let urlString = url(command: .postDevice)
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.post.rawValue
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(device)
            let requestString = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print("POST Device Request Data: \(requestString)")
            urlRequest.httpBody = data
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            Self.session.dataTask(with: urlRequest) { (data, response, error) in
                do {
                    let device = try self.parseAndHandleResponse(data: data, response: response, error: error, type: Device.self)
                    completion(.success(device))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    func getDevice(id: String, completion: @escaping (Result<Device, Swift.Error>) -> Void) {
        let urlString = url(command: .getDevice(id))
        let url = URL(string: urlString)!
        Self.session.dataTask(with: url) { (data, response, error) in
            do {
                let device = try self.parseAndHandleResponse(data: data, response: response, error: error, type: Device.self)
                completion(.success(device))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func deleteDevice(id: String, completion: @escaping (Result<(),Swift.Error>) -> Void) {
        let urlString = url(command: .deleteDevice(id))
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.delete.rawValue
        Self.session.dataTask(with: urlRequest) { (data, response, error) in
            self.handleResponse(data: data, response: response, error: error, completion: completion)
        }.resume()
    }
    
    // MARK: - Private
    
    private func parseAndHandleResponse<T>(data: Data?, response: URLResponse?, error: Swift.Error?, type: T.Type) throws -> T where T: Decodable {
        log(data: data, response: response, error: error)
        if let error = error {
            print("Error: \(error)")
            throw error
        } else if let response = response,
            let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode != 200 {
            throw XcodeReleasesApi.Error.serverError(urlResponse.statusCode)
        } else if let data = data {
            print(data)
            do {
                let decoder = JSONDecoder()
                let decoded: T = try decoder.decode(type, from: data)
                return decoded
            } catch {
                let responseString = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print("Error Parsing Response: \(error)")
                print("Response Data: \(responseString)")
                throw error
            }
        } else {
            throw XcodeReleasesApi.Error.unknown
        }
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Swift.Error?, completion: @escaping (Result<(), Swift.Error>) -> Void) {
        log(data: data, response: response, error: error)
        if let error = error {
            print("Error: \(error)")
            completion(.failure(error))
        } else if let response = response,
            let urlResponse = response as? HTTPURLResponse,
            urlResponse.statusCode == 200 {
            completion(.success(()))
        } else {
            completion(.failure(XcodeReleasesApi.Error.unknown))
        }
        
    }
    
    private func log(data: Data?, response: URLResponse?, error: Swift.Error?) {
        guard Self.log else {
            return
        }
        
        if let data = data {
            print(data)
        }
        if let response = response {
            print(response)
        }
        if let error = error {
            print(error)
        }
    }
    
}
