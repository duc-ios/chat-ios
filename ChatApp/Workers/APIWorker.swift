//
//  APIWorker.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation
import SwiftyJSON

class APIWorker {
    func buildUrl(path: String) -> URL {
        AppEnvironment.baseUrl.appending(path: path)
    }

    func buildRequest(method: String, path: String, queries: [String: String?]? = nil, body: [String: Any]? = nil) throws -> URLRequest {
        var components = URLComponents(url: buildUrl(path: path), resolvingAgainstBaseURL: true)
        components?.queryItems = queries?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        guard let requestUrl = components?.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: requestUrl)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jwt = ServiceLocator[UserSettings.self]?.me?.jwt {
            request.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = method
        if let body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return request
    }

    @discardableResult
    func request(method: String, path: String, queries: [String: String?]? = nil, body: [String: Any]? = nil) async throws -> JSON {
        let request = try buildRequest(method: method, path: path, queries: queries, body: body)
        logger.debug("\(method): \(request.url!.absoluteString)")
        if let headers = request.allHTTPHeaderFields {
            logger.debug("headers: \(headers)")
        }
        if let queries {
            logger.debug("queries: \(queries)")
        }
        if let body {
            logger.debug("body: \(body)")
        }
        let (data, response) = try await URLSession.shared.data(for: request)

        let json = JSON(data)
        logger.debug(json)

        guard let statusCode = (response as? HTTPURLResponse)?.statusCode
        else { throw AppError.unexpected }

        switch statusCode {
        case 200:
            return json
        case 201 ... 400:
            if let message = json["error"]["message"].string {
                throw AppError.message(code: statusCode, message: message)
            } else {
                throw AppError.unexpected
            }
        case 401:
            await ServiceLocator[UserSettings.self]?.logout()
            throw AppError.unauthorized
        default:
            throw AppError.server
        }
    }
}
