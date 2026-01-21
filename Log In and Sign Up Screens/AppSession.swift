import Foundation
import Combine

final class AppSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
}
