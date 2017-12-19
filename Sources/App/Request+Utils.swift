//
//  Request+Utils.swift
//  App
//
//  Created by Marco Calzana on 23.11.17.
//

import Vapor

extension Request {
    func assertJson() throws -> JSON {
        if let unwrappedJson = json {
            return unwrappedJson
        }
        throw Abort(.badRequest, reason: "Json not found")
    }
}
