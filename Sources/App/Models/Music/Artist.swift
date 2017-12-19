//
//  Artist.swift
//  NearbyServerPackageDescription
//
//  Created by Marco Calzana on 10.12.17.
//

import Foundation
import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class Artist: Model{
    let name: String
    let storage = Storage()
    
    var albums: Children<Artist, Album> {
        return children()
    }
    
    enum Keys {
        static let id = "id"
        static let name = "name"
        static let albums = "albums"
        static let codeInit = "CODE-NOT_INIT"
    }
    
    init(name:String = Keys.codeInit){
         self.name = name
    }
    
    //DATABASE
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        return row
    }
    
    init(row: Row) throws {
        name = try row.get(Keys.name)
    }
}

extension Artist: CustomStringConvertible {
    var description: String {
        return "Artist: \(id ?? "NONE"), \(name)"
    }
}

extension Artist: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name, unique: true)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Artist: JSONConvertible {
    
    //Do not include the hashedPassword!
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name)
        )
    }
}

extension Artist: StringInitializable {
    convenience init?(_ string: String) throws {
        let json = try JSON(bytes: string.makeBytes())
        try self.init(json: json)
    }
}
