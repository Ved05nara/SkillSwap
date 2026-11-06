
import SwiftUI
import FirebaseAuth

struct StudentDetailView: View {

    @EnvironmentObject private var appData: AppData

    let student: Student

    @State private var offeredSkill = ""
    @State private var requestedSkill = ""
    @State private var showConfirmation = false
    @State private var isSendingRequest = false

    // Find the currently logged-in student's profile
    private var myStudent: Student? {
        guard let uid = Auth.auth().currentUser?.uid else {
            return nil
        }

        return appData.students.first {
            $0.id == uid
        }
    }

    // Skills YOU can teach
    private var myTeachingSkills: [String] {
        myStudent?.skillsToTeach ?? []
    }

    // Skills the OTHER student can teach
    private var theirTeachingSkills: [String] {
        student.skillsToTeach
    }

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                // Student information
                HStack(spacing: 16) {

                    StudentAvatar(initials: student.initials)
                        .frame(width: 70, height: 70)

                    VStack(alignment: .leading, spacing: 5) {

                        Text(student.name)
                            .font(.title2.bold())

                        Text("\(student.course) • \(student.year)")
                            .foregroundStyle(.secondary)
                    }
                }

                Text(student.bio)
                    .font(.body)

                // Their skills
                skillSection(
                    title: "Skills they can teach",
                    skills: student.skillsToTeach
                )

                skillSection(
                    title: "Skills they want to learn",
                    skills: student.skillsToLearn
                )

                // Swap request section
                VStack(alignment: .leading, spacing: 12) {

                    Text("Propose a skill swap")
                        .font(.title2.bold())

                    Text("Choose what you can teach and what you'd like to learn.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // YOUR teaching skills
                    VStack(alignment: .leading, spacing: 8) {

                        Text("I can teach")
                            .font(.headline)

                        if myTeachingSkills.isEmpty {

                            Text("Add skills to your profile before sending a request.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        } else {

                            Picker(
                                "I can teach",
                                selection: $offeredSkill
                            ) {

                                Text("Choose a skill")
                                    .tag("")

                                ForEach(myTeachingSkills, id: \.self) { skill in
                                    Text(skill).tag(skill)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // THEIR teaching skills
                    VStack(alignment: .leading, spacing: 8) {

                        Text("I want to learn")
                            .font(.headline)

                        if theirTeachingSkills.isEmpty {

                            Text("This student hasn't added any teaching skills yet.")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        } else {

                            Picker(
                                "I want to learn",
                                selection: $requestedSkill
                            ) {

                                Text("Choose a skill")
                                    .tag("")

                                ForEach(theirTeachingSkills, id: \.self) { skill in
                                    Text(skill).tag(skill)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(AppTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    // Send request
                    Button {

                        Task {

                            isSendingRequest = true

                            let success = await appData.sendRequest(
                                to: student,
                                offering: offeredSkill,
                                requesting: requestedSkill
                            )

                            isSendingRequest = false
                            showConfirmation = success
                        }

                    } label: {

                        if isSendingRequest {

                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()

                        } else {

                            Label(
                                "Send Skill Swap Request",
                                systemImage: "paperplane.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(
                        offeredSkill.isEmpty ||
                        requestedSkill.isEmpty ||
                        isSendingRequest ||
                        myTeachingSkills.isEmpty ||
                        theirTeachingSkills.isEmpty
                    )
                }
                .padding()
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding()
        }
        .background(AppTheme.background)
        .navigationTitle("Student Profile")
        .navigationBarTitleDisplayMode(.inline)

        .onAppear {

            if !myTeachingSkills.contains(offeredSkill) {
                offeredSkill = ""
            }

            if !theirTeachingSkills.contains(requestedSkill) {
                requestedSkill = ""
            }
        }

        .alert("Request sent!", isPresented: $showConfirmation) {

            Button("Great", role: .cancel) { }

        } message: {

            Text("Your request to \(student.name) has been added to Requests.")
        }
    }

    // Skill display section
    private func skillSection(
        title: String,
        skills: [String]
    ) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            Text(title)
                .font(.headline)

            FlexibleSkillTags(skills: skills)
        }
    }
}
