//
//  AppError.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Foundation

enum AppError: LocalizedError {
    case
        unexpected,
        unauthorized,
        server,
        message(code: Int, message: String),
        error(Error)

    var errorDescription: String? { "Error!" }

    var message: String {
        switch self {
        case .unexpected:
            return "Something went wrong. Try again later!"
        case .unauthorized:
            return "Unauthorized"
        case .server:
            return "Service Unavailable"
        case let .message(code, message):
            return "\(code): \(message)"
        case let .error(error):
            if let error = error as? AppError {
                return error.message
            } else {
                return error.localizedDescription
            }
        }
    }
}
