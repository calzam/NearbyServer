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



class MusicTest: TestCase {
    
    let defAlbumName = "Albumciaone"
    let defArtistName = "CiaoneArtista"
    let defSongname = "Ciaone"
    
    
    override func setUp() {
        super.setUp()
        try! Droplet.testable()   //init the Droplet before each test: Server up. it also reset the memory database.
    }
    

    func testArtistAlbumCreation() throws {
        let myArtist = Artist(name: defArtistName)
        assert(myArtist.name == defArtistName)
        try myArtist.save();
        let savedArtist = try Artist.find(myArtist.id)
        assert(savedArtist?.id == 1)
        let myAlbum = try Album(name: defAlbumName, artistId: myArtist.id!)
        try myAlbum.save()
        let savedAlbum = try Album.find(myAlbum.id)
        assert(savedAlbum?.name == defAlbumName)
        let albums = try myArtist.albums.all()
        assert(albums.count == 1)
    }

}
