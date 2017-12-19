//
//  MusicTest.swift
//  NearbyServerPackageDescription
//
//  Created by Marco Calzana on 11.12.17.
//
import XCTest
import Foundation
import Testing
import HTTP
import JSON
@testable import Vapor
@testable import App
import FluentProvider
import SQLite



class CoordinateTest: TestCase {

    
    
    override func setUp() {
        super.setUp()
        try! Droplet.testable()   //init the Droplet before each test: Server up. it also reset the memory database.
    }
    
    
    func testCoordinateCreation() throws {
        let lat: Double = 45.0
        let lng: Double = 35.0
        let cord1 = try Coordinate(latitude: lat, longitude: lng)
        assert(cord1.latitude == lat)
        assert(cord1.longitude == lng)
     
    }
    
    func testCoordinateCreationOutofRangeLat() throws {
        let lat: Double = 181.0
        let lng: Double = 35.0
        XCTAssertThrowsError(try Coordinate(latitude: lat, longitude: lng))
    }
    
    func testCoordinateCreationOutofRangeLng() throws {
        let lat: Double = 45.0
        let lng: Double = 200.9
        XCTAssertThrowsError(try Coordinate(latitude: lat, longitude: lng))
    }
    
    func testDistanceBetweenTwoPoints() throws{
        let expectedDistance = 5859.2709
        let amsterdam = try Coordinate(latitude: 52.3702, longitude: 4.8952)
        let newYork = try Coordinate(latitude: 40.7128, longitude: -74.0059)
        let kmDistanceAN = (amsterdam -- newYork)/1000
        let kmDistanceNA = (newYork -- amsterdam)/1000
        
//        the same
        XCTAssertEqual(kmDistanceAN, expectedDistance, accuracy: 0.1)
        XCTAssertEqual(kmDistanceNA, expectedDistance, accuracy: 0.1)
    }
    
    
    
}

