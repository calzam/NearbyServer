

import Foundation
import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class Album: Model {
    let name: String
    let artistId: Identifier
    let storage = Storage()
    //one to many
    
    var owner: Parent<Album, Artist> {
        return parent(id: artistId)
    }
    
    let artist: Artist
    
    
    
    enum Keys {
        static let id = "id"
        static let name = "name"
        static let artistId = "artistId"
        static let codeInit = "CODE-NOT_INIT"
        static let artist = "artist"
    }
    
    init(name:String = Keys.codeInit, artistId: Identifier = nil, artist: Artist = Artist()){
        self.name = name
        self.artistId = artistId
        self.artist = artist
//            try artist.assertExists()
    }
    
    //DATABASE
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.artistId, artistId)
        return row
    }
    
    init(row: Row) throws {
        name = try row.get(Keys.name)
        artistId = try row.get(Keys.artistId)
        artist = Artist(name: Keys.codeInit)
    }
    
    static var defaultAlbum: Album {
        return Album(name: Keys.codeInit, artistId: nil)
    }
}

extension Album: CustomStringConvertible {
    var description: String {
        return "Album: \(id ?? "NONE"), \(name)"
    }
}

extension Album: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.name, unique: true)
            builder.foreignId(for: Artist.self, foreignIdKey: Keys.artistId)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}



extension Album: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Keys.name),
            artist: try Artist.init(json: json.get(Keys.artist))
        )
    }
    
    
    //Do not include the hashedPassword!
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.name, name)
        try json.set(Keys.artist, artist)
        return json
    }
    
}










