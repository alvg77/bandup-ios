import Foundation
import Combine
import SwiftUI

enum TextFieldState: Equatable {
    case neutral
    case valid
    case invalid(errorMessage: String)
}

class CredentialsViewModel: ObservableObject, RegisterStepViewModel {
    private let emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    private let passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[^\w\s])[A-Za-z\d^\W_]{8,}$/
    
    @Published var errorMessage = ""
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    
    @Published var usernameState: TextFieldState = .neutral
    @Published var emailState: TextFieldState = .neutral
    @Published var passwordState: TextFieldState = .neutral
        
    @Published var emailAvailable = true
    @Published var usernameAvailable = true
    
    private var registerService: RegisterService
    
    var validateStep: Bool {
        usernameState == .valid &&
        emailState == .valid &&
        passwordState == .valid
    }
    
    var credentialsAvailable: Bool {
        emailAvailable &&
        usernameAvailable &&
        errorMessage.isEmpty
    }
    
    var cancellables = Set<AnyCancellable>()
    
    init(registerService: RegisterService) {
        self.registerService = registerService
        validateUsername.store(in: &cancellables)
        validateEmail.store(in: &cancellables)
        validatePassword.store(in: &cancellables)
    }
        
    var validateUsername: AnyCancellable {
        $username
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] username in
                guard (self?.usernameState) != nil else {
                    return
                }
                if username.count < 4 {
                    withAnimation {
                        self?.usernameState = .invalid(errorMessage: "Username must be at least 4 characters long.")
                    }
                    return
                }
                self?.usernameState = .valid
            }
    }
    
    var validateEmail: AnyCancellable {
        $email
            .dropFirst()
            .debounce(for: 0.8, scheduler: DispatchQueue.main)
            .sink { [weak self] email in
                guard (self?.emailState) != nil else {
                    return
                }
                if (try? self?.emailRegex.wholeMatch(in: email)) == nil {
                    withAnimation {
                        self?.emailState = .invalid(errorMessage: "Please provide a valid email.")
                    }
                    return
                }
                self?.emailState = .valid
            }
    }
    
    var validatePassword: AnyCancellable {
        $password
            .dropFirst()
            .debounce(for: 0.4, scheduler: DispatchQueue.main)
            .sink { [weak self] password in
                guard (self?.passwordState) != nil else {
                    return
                }
                if password.count < 8 {
                    withAnimation {
                        self?.passwordState = .invalid(errorMessage: "Password must be at least 8 characters long")
                    }
                    return
                }
                self?.passwordState = .valid
            }
    }
    
    func checkEmailAvailability() {
        registerService.checkEmailAvailability(email: email) { [weak self] completion in
            DispatchQueue.main.sync {
                withAnimation {
                    switch completion {
                    case .success(let available):
                        self?.emailAvailable = available
                    case .failure(let error):
                        self?.errorMessage = error.errorDescription
                    }
                }
            }
        }
    }
    
    func checkUsernameAvailability() {
        registerService.checkUsernameAvailabilty(username: username) { [weak self] completion in
            DispatchQueue.main.sync {
                withAnimation {
                    switch completion {
                    case .success(let available):
                        self?.usernameAvailable = available
                    case .failure(let error):
                        self?.errorMessage = error.errorDescription
                    }
                }
            }
        }
    }
}
