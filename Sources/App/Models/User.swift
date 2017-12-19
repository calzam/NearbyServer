//
// Created by Marco Calzana on 23.11.17.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class User: Model {
    
    var currentSong: Song = Song()
    let storage = Storage()

    enum Keys {
        static let id = "id"
        static let userName = "userName"
        static let email = "email"
        static let password = "password"
        static let hashedPassword = "hashedPassword"
        static let location = "location"
        static let currentSong = "music"
    }

    let userName: String
    let email: String
    let hashedPassword: String?
    var followers: Set<User> = []
    var location = try! Coordinate(latitude: 0.0, longitude: 0.0)
//    var currentSong = Song(name: Keys.baseSongTitle)
    
    init(userName: String, email: String, hashedPassword: String? = nil){
        self.userName = userName
        self.email = email
        self.hashedPassword = hashedPassword
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.userName, userName)
        try row.set(Keys.email, email)
        try row.set(Keys.hashedPassword, hashedPassword)
        return row
    }

     init(row: Row) throws {
        userName = try row.get(Keys.userName)
        email = try row.get(Keys.email)
        hashedPassword = try row.get(Keys.hashedPassword)
    }
    
    func disconnect( with u2: User) {
        self.followers.remove(u2)
    }


}

extension User: CustomStringConvertible {
    
    var description: String {
        return " User \(try! id?.get() ?? "NONE") : \(userName), \(hashedPassword ?? "NONE"), \(email)"
    }
    
}

extension User: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Keys.userName, unique: true)
            builder.string(Keys.email, unique: true)
            builder.string(Keys.hashedPassword)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    
    //Do not include the hashedPassword!
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.userName, userName)
        try json.set(Keys.email, email)
        return json
    }
    
    func makeResponseWithLocationAndSong(isConnected: Bool) throws -> JSON{
        var json = JSON()
        try json.set("isConnected", isConnected)
        try json.set(Keys.id, id)
        try json.set(Keys.userName, userName)
        try json.set(Keys.email, email)
        try json.set(Keys.location, location)
        try json.set(Keys.currentSong, currentSong)
        return json
    }

    convenience init(json: JSON) throws {
        let clearPassword: String = try json.get(Keys.password)
        let hashedPassword = try drop.hash.make(clearPassword).makeString()

            self.init(
                userName: try json.get(Keys.userName),
                email: try json.get(Keys.email),
                hashedPassword: hashedPassword
            )
    }
    
}


extension User: TokenAuthenticatable {
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = Token
}

extension User: PasswordAuthenticatable {
    
    public static var passwordVerifier: PasswordVerifier? {
        get {
            return _userPasswordVerifier
        }
        set {
            _userPasswordVerifier = newValue
        }
    }

}

private var _userPasswordVerifier : PasswordVerifier? = nil

extension User: ResponseRepresentable {}

extension User: Hashable {
    var hashValue: Int {
        return "\(userName)\(email)".hashValue
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.userName == rhs.userName &&
                lhs.email == rhs.email
    }
}
