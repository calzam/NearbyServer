//
//  UserController.swift
//  NearbyServerPackageDescription
//
//  Created by Marco Calzana on 23.11.17.
//

import Vapor
import HTTP
import FluentProvider
import Crypto
//How to add  encript password
//how to login after a user has been saved in db


final class LoginController {

    func loginUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        print("login - \(user)")
        let token = try Token.generate(for: user)
        try token.save()
        return token
    }

}
    
extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = try Crypto.Random.bytes(count: 32)
        return try Token(token: random.base64Encoded.makeString(), user: user)
    }
}


