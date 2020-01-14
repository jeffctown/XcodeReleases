//
//  XcodeReleasesApi.swift
//  XcodeReleases
//
//  Created by Jeff Lett on 7/5/19.
//  Copyright © 2019 Jeff Lett. All rights reserved.
//

import APNS
import Combine
import Foundation
import XcodeReleasesKit

class XcodeReleasesApi: NSObject, NeedsEnvironment, URLSessionDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
    }
    
    let log = false
    var session: URLSession?
    let operationQueue = OperationQueue()
    
    #if os(watchOS)
    init(session: URLSession? = nil) {
        super.init()
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.jefflett.XcodeReleases")
        configuration.sessionSendsLaunchEvents = true
        self.session = session ?? URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
    }
    #else
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        super.init()
        self.session = session
    }
    #endif
    
    public enum ApiError: Error, LocalizedError {
        case invalidURL(String)
        case encode(EncodingError)
        case request(URLError)
        case decode(DecodingError)
        case serverError(Int)
        case unknown
        
        public var errorDescription: String? {
            switch self {
            case .invalidURL(let u):
                return "URL Creation Error: \(u)"
            case .request(let e):
                return "Request Error: \(e)"
            case .serverError(let statusCode):
                return "Server Error: \(statusCode)"
            case .encode(let e):
                return "Encoding Error: \(e)"
            case .decode(let e):
                return "Decoding Error: \(e)"
            case .unknown:
                return "Unknown Error"
            }
        }
    }
    
    var xcodeReleasesLoader: XcodeReleasesLoader = try! XcodeReleasesLoader(url: "\(XcodeReleasesApi.environment().apiUrl)/release")
    
    func postDevice(device: Device) -> AnyPublisher<Device, XcodeReleasesApi.ApiError> {
        Just(device)
            .encode(encoder: JSONEncoder())
            .mapError { self.processErrors($0) }
            .tryMap { try self.mapToPostURLRequest(data: $0, url: self.url(command: .postDevice)) }
            .mapError { self.processErrors($0) }
            .flatMap {
                self.session!.dataTaskPublisher(for: $0)
                    .mapError { self.processErrors($0) }
                    .map(\.data)
                    .decode(type: Device.self, decoder: JSONDecoder())
                    .mapError { self.processErrors($0) }
            }.eraseToAnyPublisher()
    }
        
    
    func deleteDevice(id: String) -> AnyPublisher<Bool, XcodeReleasesApi.ApiError> {
        Just(id)
            .tryMap { try self.mapToDeleteURLRequest(url: self.url(command: .deleteDevice($0))) }
            .mapError { self.processErrors($0) }
            .flatMap {
                self.session!.dataTaskPublisher(for: $0)
                    .mapError(XcodeReleasesApi.ApiError.request)
                    .map(\.response)
                    .map { response -> Bool in (response as? HTTPURLResponse)?.statusCode == 200 }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    private enum ApiCommand {
        case postDevice
        case getDevice(String)
        case deleteDevice(String)
    }
    
    private enum HttpMethod: String {
        case post = "POST"
        case delete = "DELETE"
    }
    
    // MARK: - Private Methods
    
    private func url(command: ApiCommand) -> String {
        switch command {
        case .getDevice(let id), .deleteDevice(let id):
            return "\(Self.environment().apiUrl)/device/\(id)"
        case .postDevice:
            return "\(Self.environment().apiUrl)/device"
        }
    }
 
    private func processErrors(_ error: Swift.Error) -> XcodeReleasesApi.ApiError {
        if let decodingError = error as? DecodingError {
            return .decode(decodingError)
        } else if let encodingError = error as? EncodingError {
            return .encode(encodingError)
        } else if let urlError = error as? URLError {
            return .request(urlError)
        } else if let apiError = error as? XcodeReleasesApi.ApiError {
            return apiError
        } else {
            return .unknown
        }
    }
    
    private func mapToPostURLRequest(data: Data, url urlString: String) throws -> URLRequest {
        var urlRequest = try self.urlRequest(url: urlString)
        urlRequest.httpMethod = HttpMethod.post.rawValue
        urlRequest.httpBody = data
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    private func mapToDeleteURLRequest(url urlString: String) throws -> URLRequest {
        var urlRequest = try self.urlRequest(url: urlString)
        urlRequest.httpMethod = HttpMethod.delete.rawValue
        return urlRequest
    }
    
    private func urlRequest(url urlString: String) throws -> URLRequest {
        guard let url = URL(string: urlString) else {
            throw XcodeReleasesApi.ApiError.invalidURL(urlString)
        }
        return URLRequest(url: url)
    }
}
