//
//  UserController.swift
//  NearbyServer
//
//  Created by Marco Calzana on 24.11.17.
//

import Vapor
import SQLite
import FluentProvider
import HTTP

final class UserController{
    
    func get(req: Request) throws -> ResponseRepresentable {
        let fethchedUser = try req.parameters.next(User.self)
        
        return fethchedUser
    }
    
    func post(req: Request) throws -> ResponseRepresentable {
        let newUser = try req.newUser()
        do {
            try newUser.save()
        } catch {
            throw Abort(.conflict, reason: error.localizedDescription)
        }
        return newUser
    }
}

extension Request {
    func newUser() throws -> User {
        let json = try assertJson()
        return try User(json: json)
        
    }
}
