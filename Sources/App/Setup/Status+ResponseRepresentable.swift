//
//  File.swift
//  App
//
//  Created by Marco Calzana on 19.12.17.
//

import Vapor
import HTTP

extension Status: ResponseRepresentable {
    public func makeResponse() throws -> Response {
        return Response(status: self)
    }
}
