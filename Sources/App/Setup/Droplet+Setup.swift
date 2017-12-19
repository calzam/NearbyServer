@_exported import Vapor
import AuthProvider

var drop: Droplet!

extension Droplet {
    public func setup() throws {
        drop = self
        try setupRoutes()
        try setupPasswordVerifier()
        try setupRoom()
        // Do any additional droplet setup
    }

    private func setupPasswordVerifier() throws {
        guard let verifier = hash as? PasswordVerifier else {
            throw Abort(.internalServerError, reason: "\(type(of: hash)) must conform to PasswordVerifier.")
        }

        User.passwordVerifier = verifier
    }
}
