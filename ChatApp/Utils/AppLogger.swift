//
//  AppLogger.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//
import Foundation
import os
import SocketIO

let logger = AppLogger()

class AppLogger: SocketLogger {
    private let logger = Logger()

    var log: Bool = true

    func debug(_ message: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
            logger.debug("💙\((file as NSString).lastPathComponent):\(line):\(function)) \(message)")
        #endif
    }

    func error(_ message: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        logger.error("❤️\((file as NSString).lastPathComponent):\(line):\(function)) \(message)")
    }

    func log(_ message: @autoclosure @escaping () -> String, type _: String) {
        debug(message())
    }

    func error(_ message: @autoclosure @escaping () -> String, type _: String) {
        error(message())
    }
}
