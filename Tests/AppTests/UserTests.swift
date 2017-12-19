import XCTest
import Foundation
import Testing
import HTTP
import JSON
@testable import Vapor
@testable import App
import FluentProvider

// This file shows an example of testing
// routes through the Droplet.


class RouteTests: TestCase {

    let defPassword = "password"
    let defUsername = "leo"
    let defEmail = "Leo@An.it"

    override func setUp() {
        super.setUp()
        try! Droplet.testable()   //init the Droplet before each test: Server up. it also reset the memory database.
//        try! User.all().forEach { try $0.delete() }
//        try! Token.all().forEach { try $0.delete() }
    }
    func testUserCreation() throws {
        var requestBody = JSON()
        try requestBody.set("userName", defUsername)
        try requestBody.set("email", defEmail)
        try requestBody.set("password", defPassword)

        try drop
                .testResponse(to: .post, at: "user", headers: [HeaderKey.contentType: "application/json"], body: requestBody)
                .assertStatus(is: .ok)
                .assertJSON("userName", equals: defUsername)
                .assertJSON("email", equals: defEmail)
                .assertJSON("id", equals: 1)
    }

    func testUserCreationSameUserNameEmail() throws {
        try testUserCreation()
        var requestBody = JSON()
        try requestBody.set("userName", defUsername)
        try requestBody.set("email", "ciao@An.it")
        try requestBody.set("password", defPassword)

        try drop
                .testResponse(to: .post, at: "user", headers: [HeaderKey.contentType: "application/json"], body: requestBody)
                .assertStatus(is: .conflict)

        try requestBody.set("userName", "Ciao")
        try requestBody.set("email", defEmail)
        try drop
                .testResponse(to: .post, at: "user", headers: [HeaderKey.contentType: "application/json"], body: requestBody)
                .assertStatus(is: .conflict)
    }

    func testLogIn() throws {
        try testUserCreation()
        let basicToken = "\(defEmail):\(defPassword)".makeBytes().base64Encoded.makeString()
        let response = try drop
                .testResponse(to: .post, at: "login", headers: [HeaderKey.authorization: "Basic \(basicToken)"])

        response.assertStatus(is: .ok)

        let token: String = try response.json!.get("token")

        try drop
                .testResponse(to: .get, at: "me", headers: [HeaderKey.authorization: "Bearer \(token)"])
                .assertStatus(is: .ok)

        try drop
                .testResponse(to: .get, at: "me", headers: [HeaderKey.authorization: "Bearer aWrongToken"])
                .assertStatus(is: .unauthorized)
    }
}



// MARK: Manifest

//extension RouteTests {
//    /// This is a requirement for XCTest on Linux
//    /// to function properly.
//    /// See ./Tests/LinuxMain.swift for examples
//    static let allTests = [
//        ("testuserCreation", testuserCreation),
//        ("testInfo", testInfo),
//    ]
//}

