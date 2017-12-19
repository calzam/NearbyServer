import Foundation

infix operator --

struct Coordinate {
    
    enum CoordinateType {
        case latitude
        case longitude
    }
    
    enum CoordinateError: Error {
        case invalidCoordinate(CoordinateType, Double)
    }
    
    enum Keys{
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    let latitude: Double
    let longitude: Double
    static let maxLatitude = 90.0
    static let maxLongitude = 180.0
    
    init(latitude: Double, longitude: Double) throws {
        self.latitude = latitude
        self.longitude = longitude
        
        guard isValid(longitude, boundedBy: Coordinate.maxLongitude) else {
            throw CoordinateError.invalidCoordinate(.longitude, longitude)
        }
        guard isValid(latitude, boundedBy: Coordinate.maxLatitude) else {
            throw CoordinateError.invalidCoordinate(.latitude, latitude)
        }
    }
    
    private func isValid(_ value: Double, boundedBy bound: Double) -> Bool {
        return (-bound...bound).contains(value)
    }
    
    //Express in meters
    static func --(lhs: Coordinate, rhs: Coordinate) -> Double {
        let radius = 6367444.7
        
        let lat1 = lhs.latitude.toRadians
        let lon1 = lhs.longitude.toRadians
        let lat2 = rhs.latitude.toRadians
        let lon2 = rhs.longitude.toRadians
        
        return radius * ((lat2 - lat1).haversin + cos(lat1) * cos(lat2) * (lon2 - lon1).haversin).ahaversin
    }
}

extension Double {
    var toRadians: Double {
        return (self / 360) * 2 * Double.pi
    }
    
    var haversin: Double {
        return (1 - cos(self))/2
    }
    
    var ahaversin: Double {
        return 2*asin(sqrt(self))
    }
}

extension Coordinate: JSONConvertible {
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.latitude, latitude)
        try json.set(Keys.longitude, longitude)
        return json
    }
    
    init(json: JSON) throws {
        try self.init(
            latitude: try json.get(Keys.latitude),
            longitude: try json.get(Keys.longitude)
        )
    }
}

extension Coordinate: StringInitializable {
    init?(_ string: String) throws {
        let json = try JSON(bytes: string.makeBytes())
        try self.init(json: json)
    }
}

