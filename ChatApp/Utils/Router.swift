//
//  Router.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Foundation

enum Route: Hashable {
    case login, friends, conversations, conversation(ConversationModel)
}

class Router: ObservableObject {
    @Published var path = [Route]()

    func show(_ route: Route) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func pop(to route: Route) {
        if let idx = path.firstIndex(where: { $0 == route }) {
            path = Array(path[0 ... idx])
        } else if !path.isEmpty {
            path[path.count - 1] = route
        } else {
            path = [route]
        }
    }

    func popToRoot() {
        path.removeLast(path.count)
    }
}
