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
        logger.debug("💙\((file as NSString).lastPathComponent):\(line):\(function)) \(String(describing: message))")
    }
    
    func error(_ message: Any..., file: String = #file, function: String = #function, line: Int = #line) {
        logger.error("❤️\((file as NSString).lastPathComponent):\(line):\(function)) \(String(describing: message))")
    }
    
    func log(_ message: @autoclosure @escaping () -> String, type: String) {
        debug(message())
    }
    
    func error(_ message: @autoclosure @escaping () -> String, type: String) {
        error(message())
    }
}
