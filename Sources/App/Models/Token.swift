//
// Created by Marco Calzana on 23.11.17.
//

import Vapor
import FluentProvider

final class Token: Model{
    let storage = Storage()
    let token: String
    let userId: Identifier

    enum Keys {
        static let token = "token"
        static let userId = "userId"
    }

    //one to one relation
    var user: Parent<Token, User> {
        return parent(id: userId)
    }

    init(token: String, user: User) throws {
        self.token = token
        self.userId = try user.assertExists()
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.token, token)
        try row.set(Keys.userId, userId)
        return row
    }

    init(row: Row) throws {
        token = try row.get(Keys.token)
        userId = try row.get(Keys.userId)
    }
}

extension Token: Preparation{
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self)
            builder.string(Keys.token)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Token: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON();
        try json.set(Keys.token, token)
        return json
    }
}

extension Token: ResponseRepresentable {}



