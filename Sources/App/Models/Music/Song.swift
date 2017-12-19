//
//  Song.swift
//  NearbyServerPackageDescription
//
//  Created by Marco Calzana on 10.12.17.
//

import Foundation
import Vapor
import FluentProvider
import AuthProvider
import HTTP


final class Song: Model{
    let name: String
    let storage = Storage()
    
    var album: Album = .defaultAlbum

    enum Keys {
        static let id = "id"
        static let name = "name"
        static let codeInit = "CODE-NOT_INIT"
        static let album = "album"
    }

    init(name: String = Keys.codeInit, album: Album = Album()){
        self.name = name
        self.album = album
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

extension Song: CustomStringConvertible {
    var description: String {
        return "Song: \(id ?? "NONE") "
    }
}


extension Song: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Song: JSONConvertible {
    
    //Do not include the hashedPassword!
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.album, album)
        return json
    }
    
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            album: try Album(json: json.get(Keys.album))
        )
    }
}





