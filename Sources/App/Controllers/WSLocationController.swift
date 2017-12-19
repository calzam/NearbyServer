//
//  SocketController.swift
//  App
//
//  Created by Marco Calzana on 13.12.17.
//

import Vapor
import Foundation

class WSLocationController {
    
    func locationSocket(request: Request, socket: WebSocket) throws {
        
        let user: User = try request.parameters.next()
        print("New WebSocket connected, user:   \(user.userName)")
        LocationRoom.shared.addWebSocket(socket, for: user)
//        try socket.send("Hello, \(user.userName)!")
        let pingTimer = keepSocketAlive(socket)
        
        
        socket.onText = { webSocket, message in
            let json = try JSON(bytes: message.makeBytes())
            let locationJSON = try json.get("location") as JSON
            let musicJSON = try json.get("music") as JSON
            
            let location = try Coordinate(json: locationJSON)
            let song = try Song(json: musicJSON)
            
            print("New location from: \(user.userName), current song: \(song.name)")
            LocationRoom.shared.register(location, fromUser: user, listening: song)
            print("")
        }
        
        socket.onClose = { webSocket, _, _, _ in
            print("\(user.userName) socket closed.")
            LocationRoom.shared.close(forUser: user)
            self.killTimer(pingTimer)
        }
    }
    
    func keepSocketAlive(_ socket: WebSocket) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now(), repeating: .seconds(10))
        timer.setEventHandler {
            try? socket.ping()
        }
        timer.resume()
        return timer
    }
    
    func killTimer(_ timer: DispatchSourceTimer) {
        timer.cancel()
    }
}

