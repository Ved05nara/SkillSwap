
import SwiftUI
import FirebaseAuth
import CoreLocation

struct ProfileView: View {

    @EnvironmentObject var appData: AppData
    @EnvironmentObject var authService: AuthService

    @State private var name = ""
    @State private var course = ""
    @State private var year = ""
    @State private var bio = ""

    @State private var teachingSkills: [String] = []
    @State private var learningSkills: [String] = []

    @State private var newTeachingSkill = ""
    @State private var newLearningSkill = ""

    @State private var preferredMeetingSpot = "Not selected"

    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isSaving = false

    // Campus meeting locations
    // Coordinates are approximate placeholders.
    private let meetingSpots: [String: CLLocationCoordinate2D] = [

        "Library": CLLocationCoordinate2D(
            latitude: 19.0733,
            longitude: 72.8995
        ),

        "College Cafeteria": CLLocationCoordinate2D(
            latitude: 19.0728,
            longitude: 72.9000
        ),

        "Student Activity Centre": CLLocationCoordinate2D(
            latitude: 19.0736,
            longitude: 72.9002
        ),

        "Main Building Lobby": CLLocationCoordinate2D(
            latitude: 19.0731,
            longitude: 72.8998
        ),

        "Open Courtyard": CLLocationCoordinate2D(
            latitude: 19.0726,
            longitude: 72.8994
        )
    ]

    private var meetingSpotNames: [String] {
        ["Not selected"] + meetingSpots.keys.sorted()
    }

    var body: some View {

        NavigationStack {

            Form {

                // Personal Details

                Section("Your details") {

                    TextField("Name", text: $name)

                    TextField("Course / department", text: $course)

                    TextField("Year", text: $year)

                    TextField("About you", text: $bio, axis: .vertical)
                        .lineLimit(3...5)
                }

                // Preferred Meeting Spot

                Section {
                    Picker(
                        "Meeting location",
                        selection: $preferredMeetingSpot
                    ) {
                        ForEach(meetingSpotNames, id: \.self) { spot in
                            Text(spot).tag(spot)
                        }
                    }

                    Text(
                        "Choose a campus location where other students can meet you for skill swaps."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                } header: {
                    Label(
                        "Preferred Meeting Spot",
                        systemImage: "mappin.and.ellipse"
                    )
                }

                // Teaching Skills

                Section("Skills I can teach") {

                    ForEach(teachingSkills, id: \.self) { skill in

                        HStack {
                            Text(skill)

                            Spacer()

                            Button(role: .destructive) {
                                teachingSkills.removeAll { $0 == skill }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                    }

                    HStack {

                        TextField(
                            "Add a teaching skill",
                            text: $newTeachingSkill
                        )

                        Button {
                            addSkill(newTeachingSkill, to: &teachingSkills)
                            newTeachingSkill = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(
                            newTeachingSkill.trimmingCharacters(
                                in: .whitespaces
                            ).isEmpty
                        )
                    }
                }

                // Learning Skills

                Section("Skills I want to learn") {

                    ForEach(learningSkills, id: \.self) { skill in

                        HStack {
                            Text(skill)

                            Spacer()

                            Button(role: .destructive) {
                                learningSkills.removeAll { $0 == skill }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                            }
                        }
                    }

                    HStack {

                        TextField(
                            "Add a learning skill",
                            text: $newLearningSkill
                        )

                        Button {
                            addSkill(newLearningSkill, to: &learningSkills)
                            newLearningSkill = ""
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(
                            newLearningSkill.trimmingCharacters(
                                in: .whitespaces
                            ).isEmpty
                        )
                    }
                }

                // Messages

                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundStyle(.green)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                // Save Profile

                Button {
                    saveProfile()
                } label: {

                    if isSaving {
                        ProgressView()
                    } else {
                        Label(
                            "Save Profile",
                            systemImage: "checkmark.circle.fill"
                        )
                    }
                }
                .disabled(isSaving)

                // Logout

                Section {

                    Button(role: .destructive) {

                        do {
                            try authService.logout()
                        } catch {
                            errorMessage = error.localizedDescription
                        }

                    } label: {
                        Label(
                            "Log Out",
                            systemImage: "rectangle.portrait.and.arrow.right"
                        )
                    }
                }
            }
            .navigationTitle("My Profile")
            .task {
                await appData.loadStudents()
                loadProfile()
            }
        }
    }

    // MARK: - Load Profile

    private func loadProfile() {

        guard let uid = authService.user?.uid else {
            return
        }

        guard let student = appData.students.first(
            where: { $0.id == uid }
        ) else {
            return
        }

        name = student.name
        course = student.course
        year = student.year
        bio = student.bio

        teachingSkills = student.skillsToTeach
        learningSkills = student.skillsToLearn

        preferredMeetingSpot = student.preferredMeetingSpot ?? "Not selected"
    }

    // MARK: - Add Skill

    private func addSkill(
        _ skill: String,
        to list: inout [String]
    ) {

        let cleaned = skill.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !cleaned.isEmpty,
              !list.contains(
                where: {
                    $0.caseInsensitiveCompare(cleaned) == .orderedSame
                }
              )
        else {
            return
        }

        list.append(cleaned)
    }

    // MARK: - Save Profile

    private func saveProfile() {

        guard let uid = authService.user?.uid else {
            errorMessage = "Please log in again."
            return
        }

        guard
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !course.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !year.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            errorMessage = "Please fill in your name, course and year."
            successMessage = ""
            return
        }

        errorMessage = ""
        successMessage = ""

        let initials = name.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
            .uppercased()

        let selectedCoordinate = meetingSpots[preferredMeetingSpot]

        let student = Student(
            id: uid,
            name: name,
            course: course,
            year: year,
            bio: bio,
            skillsToTeach: teachingSkills,
            skillsToLearn: learningSkills,
            initials: initials,
            preferredMeetingSpot: preferredMeetingSpot == "Not selected"
                ? nil
                : preferredMeetingSpot,
            preferredLatitude: selectedCoordinate?.latitude,
            preferredLongitude: selectedCoordinate?.longitude
        )

        isSaving = true

        Task {
            do {

                try await FirestoreService.shared.saveStudent(
                    student,
                    uid: uid
                )

                if let index = appData.students.firstIndex(
                    where: { $0.id == uid }
                ) {
                    appData.students[index] = student
                } else {
                    appData.students.append(student)
                }

                successMessage = "Profile saved successfully!"
                errorMessage = ""

            } catch {

                errorMessage = error.localizedDescription
                successMessage = ""

            }

            isSaving = false
        }
    }
}
