//
//  WebSocket+Utils.swift
//  App
//
//  Created by Marco Calzana on 13.12.17.
//

import Vapor

extension WebSocket {
    func send(_ json: JSONRepresentable) throws {
        try send(json.makeJSON())
    }
}
