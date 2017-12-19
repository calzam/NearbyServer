import Vapor

class LocationRoom {
    
    private var maxDistance = 5000.0
    private var connections: [User: WebSocket]
    static let shared = LocationRoom()
    
    private init() {
        connections = [:]
    }
    
    func addWebSocket(_ ws: WebSocket, for user: User) {
        connections[user] = ws
    }
    
    func register(_ location: Coordinate, fromUser user: User, listening song: Song){
        user.location = location
        user.currentSong = song
        forwardLocation(location, fromUser: user)
    }
    
    func close(forUser: User) {
        connections.removeValue(forKey: forUser)
        forUser.followers.forEach { (user) in
            try? disconnect(user, forUser)
        }
    }
    
    private func disconnect(_ u1: User, _ u2: User) throws{
        u1.disconnect(with: u2)
        try? connections[u1]?.send(u2.makeResponseWithLocationAndSong(isConnected: false))
    }
    
   
    
    private func forwardLocation(_ location: Coordinate, fromUser: User){
        connections.keys.forEach { (user) in
            if(user.id != fromUser.id){
                do{
                    if isInRange(fromUser.location, user.location) {
                        try notify(fromUser: fromUser, toUser: user)
                    }else{
                        if(fromUser.followers.contains(user)){
                            try? disconnect(fromUser, user)
                            try? disconnect(user, fromUser)
                        }
                    }
                }catch {
                    print("WB: <LOCATION> somthing wrong between user \(fromUser), \(user)")
                }
            }
        }
    }
    
    private func isInRange(_ l1 : Coordinate, _ l2: Coordinate) -> Bool{
        return (l1--l2) < maxDistance
    }
    
    private func notify(fromUser: User, toUser: User) throws{
        try connections[toUser]?.send(fromUser.makeResponseWithLocationAndSong(isConnected: true))
        
        if !fromUser.followers.contains(toUser) {
            try connections[fromUser]?.send(toUser.makeResponseWithLocationAndSong(isConnected: true))
            fromUser.followers.insert(toUser)
            toUser.followers.insert(fromUser)
            print("Nearby \(fromUser.userName) : \(toUser.userName)")
        }
    }
    
}

extension WebSocket {
    func send(_ json: JSON) throws {
        let js = try json.makeBytes()
        try send(js.makeString())
    }
}

