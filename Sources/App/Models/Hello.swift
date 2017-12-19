//
//  Hello.swift
//  App
//
//  Created by Marco Calzana on 23.11.17.
//

import Vapor
import FluentProvider
import HTTP

final class Hello: Model {
    
    let storage = Storage()
    
    enum Keys {
        static let message = "message"
    }
    
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.message, message)
        return row
    }
    
    init(row: Row) throws {
        message = try row.get(Keys.message)
    }
}

extension Hello: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.message)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Hello: JSONConvertible {
    func makeJSON() throws -> JSON {
        // return try JSON(makeRow())
        var json = JSON()
        try json.set(Keys.message, message)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            message: try json.get(Keys.message)
        )
    }

}

extension Hello: ResponseRepresentable {}
