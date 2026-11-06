
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var appData: AppData

    @State private var isRegistering = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var course = ""
    @State private var year = "1st Year"
    @State private var teachSkills = ""
    @State private var learnSkills = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let years = [
        "1st Year", "2nd Year", "3rd Year", "4th Year", "Postgraduate"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.indigo)
                        .padding(.top, 25)

                    Text("SkillSwap")
                        .font(.largeTitle.bold())

                    Text("Learn something. Teach something. Grow together.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    if isRegistering {
                        Group {
                            TextField("Full name", text: $name)
                            TextField("Course (e.g. Computer Science)", text: $course)

                            Picker("Year of study", selection: $year) {
                                ForEach(years, id: \.self) { item in
                                    Text(item).tag(item)
                                }
                            }

                            TextField("Skills you can teach (comma separated)", text: $teachSkills)
                            TextField("Skills you want to learn (comma separated)", text: $learnSkills)
                        }
                        .textFieldStyle(.roundedBorder)
                    }

                    TextField("Email address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password (minimum 6 characters)", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        authenticate()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(isRegistering ? "Create Account" : "Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)

                    Button(isRegistering
                           ? "Already have an account? Log in"
                           : "New to SkillSwap? Create an account") {
                        isRegistering.toggle()
                        errorMessage = ""
                    }
                    .font(.footnote)
                    .padding(.bottom, 25)
                }
                .padding(24)
            }
        }
    }

    private func authenticate() {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must contain at least 6 characters."
            return
        }

        if isRegistering {
            guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
                  !course.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please enter your name and course."
                return
            }
        }

        isLoading = true
        errorMessage = ""

        Task {
            do {
                if isRegistering {
                    let uid = try await authService.register(
                        email: cleanEmail,
                        password: password
                    )

                    let student = Student(
                        id: uid,
                        name: name.trimmingCharacters(in: .whitespaces),
                        course: course.trimmingCharacters(in: .whitespaces),
                        year: year,
                        bio: "",
                        skillsToTeach: parseSkills(teachSkills),
                        skillsToLearn: parseSkills(learnSkills),
                        initials: makeInitials(name)
                    )

                    try await FirestoreService.shared.saveStudent(
                        student,
                        uid: uid
                    )

                    appData.students.removeAll { $0.id == uid }
                    appData.students.append(student)
                } else {
                    try await authService.login(
                        email: cleanEmail,
                        password: password
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    private func parseSkills(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func makeInitials(_ name: String) -> String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()
    }
}
