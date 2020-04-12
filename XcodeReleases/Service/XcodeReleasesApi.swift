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
import XCModel

struct XcodeReleasesApi: NeedsEnvironment {

    let log = false
    var session: URLSession?

    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }

    public enum ApiError: Error, LocalizedError {
        case invalidURL(String)
        case encode(EncodingError)
        case request(URLError)
        case decode(DecodingError)
        case serverError(Int)
        case unknown

        public var errorDescription: String? {
            switch self {
            case .invalidURL(let url):
                return "URL Creation Error: \(url)"
            case .request(let error):
                return "Network Error: \(error.localizedDescription)"
            case .serverError(let statusCode):
                return "Server Error: \(statusCode)"
            case .encode(let error):
                return "Encoding Error: \(error.localizedDescription)"
            case .decode(let error):
                return "Decoding Error: \(error.localizedDescription)"
            case .unknown:
                return "Unknown Error"
            }
        }
    }

    // MARK: - Devices

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

    // MARK: - Links

    func getLinks() -> AnyPublisher<[Link], XcodeReleasesApi.ApiError> {
        //swiftlint:disable:next force_try
        return self.session!.dataTaskPublisher(for: try! urlRequest(url: url(command: .getLinks)))
            .mapError(XcodeReleasesApi.ApiError.request)
            .map(\.data)
            .decode(type: [Link].self, decoder: JSONDecoder())
            .mapError { self.processErrors($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - Xcodes

    func getXcodes() -> AnyPublisher<[Xcode], XcodeReleasesApi.ApiError> {
        //swiftlint:disable:next force_try
        return self.session!.dataTaskPublisher(for: try! urlRequest(url: url(command: .getXcodes)))
            .mapError(XcodeReleasesApi.ApiError.request)
            .map(\.data)
            .decode(type: [Xcode].self, decoder: JSONDecoder())
            .mapError { self.processErrors($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private enum ApiCommand {
        case postDevice
        case getDevice(String)
        case deleteDevice(String)
        case getLinks
        case getXcodes
    }

    private enum HttpMethod: String {
        case post = "POST"
        case delete = "DELETE"
    }

    // MARK: - Private Methods

    private func url(command: ApiCommand) -> String {
        switch command {
        case .getDevice(let identifier), .deleteDevice(let identifier):
            return "\(Self.environment().apiUrl)/device/\(identifier)"
        case .postDevice:
            return "\(Self.environment().apiUrl)/device"
        case .getLinks:
            return "\(Self.environment().apiUrl)/link"
        case .getXcodes:
            return "\(Self.environment().apiUrl)/release"
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
