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
        unauthenticated,
        message(String),
        error(Error)

    var errorDescription: String? { "Error!" }

    var message: String {
        switch self {
        case .unexpected:
            return "Something went wrong. Try again later!"
        case .unauthenticated:
            return "Unauthenticated"
        case .message(let string):
            return string
        case .error(let error):
            if let error = error as? AppError {
                return error.message
            } else {
                return error.localizedDescription
            }
        }
    }
}
