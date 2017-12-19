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
    
    func postPicture(req: Request) throws  -> ResponseRepresentable {
        //        let url = URL(fileURLWithPath: "/Users/marco/")
        //        let bytes = try! Data(contentsOf: url)
        //
        //        let content = try! String(contentsOf: url)
        //
        guard let filebytes = req.formData?["image"]?.part.body else {
            throw Abort(.badRequest, metadata: "No file in request")
        }
        //
        //        let datafilebytes = Data(bytes: filebytes)
        //        try datafilebytes.write(to: url)
        
        return "Status.ok"
        
    }
}

extension Request {
    func newUser() throws -> User {
        let json = try assertJson()
        return try User(json: json)
        
    }
}
