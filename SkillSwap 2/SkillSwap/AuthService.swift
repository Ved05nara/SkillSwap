
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AuthService: ObservableObject {

    @Published var user: User?
    @Published var isAuthenticated = false

    init() {
        user = Auth.auth().currentUser
        isAuthenticated = user != nil
    }

    func register(
        email: String,
        password: String
    ) async throws -> String {

        let result = try await Auth.auth().createUser(
            withEmail: email,
            password: password
        )

        user = result.user
        isAuthenticated = true

        return result.user.uid
    }

    func login(
        email: String,
        password: String
    ) async throws {

        let result = try await Auth.auth().signIn(
            withEmail: email,
            password: password
        )

        user = result.user
        isAuthenticated = true
    }

    func logout() throws {
        try Auth.auth().signOut()
        user = nil
        isAuthenticated = false
    }
}
