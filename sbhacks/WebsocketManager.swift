//
//  WebsocketManager.swift
//  sbhacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//
//
//  WebSocketManager.swift
//  AR Planes
//
//  Created by Cal Stephens on 9/28/17.
//  Copyright © 2017 Hack the North. All rights reserved.
//

import Starscream

// MARK: - WebSocketManager

class WebSocketManager {
    
    // MARK: Static Constants
    
    static let serverPollingInterval = TimeInterval(5)
    static let webSocketURL = URL(string: "ws://server.calstephens.tech:777")!
    
    // MARK: Setup
    
    private let socket = WebSocket(url: WebSocketManager.webSocketURL)
    
    public var dataType: String?
    
    init() {
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: Interface with server
    
//    static func processJsonTextFromServer(_ jsonText: String) {
//        guard let messageType = jsonText.toJson() as? [[String: Any]] else {
//            return
//        }
//    }
    
}

// MARK: - WebSocketDelegate

extension WebSocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocketClient) {
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
//        let dataType = WebSocketManager.processJsonTextFromServer(text)
        dataType = text
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        return
    }
    
}


// MARK: - Standard Library Extensions

extension String {
    func toJson() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { (keyvalue) in keyvalue.value == val }.map { $0.0 }
    }
}

