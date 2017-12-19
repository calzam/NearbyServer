import Vapor
import AuthProvider
import Foundation

extension Droplet {
    func setupRoutes() throws {
        setUpUserRoutes()
        setUpLoginRoutes()
        setupTokenProtectedRoutes()
    }
    

    private func setUpUserRoutes(){
        let userController = UserController()
        get("user", User.parameter,  handler: userController.get)
        post("user", handler: userController.post)
    }

    private func setUpLoginRoutes(){
        let loginMiddleware = grouped([PasswordAuthenticationMiddleware(User.self)])
        let loginController = LoginController()
        loginMiddleware.post("login", handler: loginController.loginUser)
    }

    private func setupTokenProtectedRoutes() {
        let userController = UserController()
        let tokenMiddleware = grouped([TokenAuthenticationMiddleware(User.self)])
        tokenMiddleware.get("me") { req in
            return try req.user()
        }
        tokenMiddleware.post("user", "picture", handler: userController.postPicture)
    }
}



extension Droplet {
    public func setupRoom() throws {
        let socketController = WSLocationController()
        socket("location_web_socket", User.parameter, handler: socketController.locationSocket)
    }
}

/*

 
 {
 "message":"ciaone"
 }
 
 */
