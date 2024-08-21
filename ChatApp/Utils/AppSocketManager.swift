//
//  AppSocketManager.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import Foundation
import SocketIO

struct AppSocketManager {
    static let `default` = AppSocketManager()

    private let manager = SocketManager(
        socketURL: AppEnvironment.baseUrl,
        config: [
            .logger(logger),
            .compress,
            .reconnects(true)
        ])

    var socket: SocketIOClient { manager.defaultSocket }

    func connect() {
        guard let me = UserSettings.me,
              let jwt = me.jwt
        else {
            logger.error(AppError.unauthenticated)
            return
        }

        socket.on("statusChange") { data, emitter in
            logger.debug(data)
            logger.debug(emitter)
            if let status = data.first as? SocketIOStatus {
                switch status {
                case .connected:
                    UserSettings.me?.socketId = socket.manager?.engine?.sid
                case .disconnected:
                    UserSettings.me?.socketId = nil
                default:
                    break
                }
            }
        }

        socket.connect(withPayload: [
            "socketId": me.socketId as Any,
            "token": jwt
        ])
    }

    func disconnect() {
        socket.off("message:create")
        socket.disconnect()
    }

    func on(_ event: String, _ callback: @escaping NormalCallback) {
        socket.on(event, callback: callback)
    }

    func off(_ event: String) {
        socket.off(event)
    }
}
