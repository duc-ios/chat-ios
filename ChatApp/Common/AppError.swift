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

extension AppError: Hashable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        lhs.errorDescription == rhs.errorDescription && lhs.message == rhs.message
    }
    
    func hash(into hasher: inout Hasher) {
        for item in [errorDescription, message] {
            hasher.combine(item)
        }
    }
}
