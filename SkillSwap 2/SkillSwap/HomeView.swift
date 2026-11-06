import FirebaseAuth
import SwiftUI

struct HomeView: View {

    @EnvironmentObject var appData: AppData
    @EnvironmentObject private var authService: AuthService

    private var otherStudents: [Student] {
        appData.students.filter {
            $0.id != authService.user?.uid
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Learn something.\nTeach something.")
                            .font(.largeTitle.bold())

                        Text("Your campus is full of people with skills to share.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        statCard(
                            title: "Students",
                            value: "\(otherStudents.count)",
                            icon: "person.2.fill"
                        )

                        statCard(
                            title: "Your requests",
                            value: "\(appData.requests.count)",
                            icon: "arrow.left.arrow.right"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Popular skills")
                            .font(.title2.bold())

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 10
                        ) {
                            ForEach(
                                ["SwiftUI", "Photography", "Figma",
                                 "Python", "Guitar", "Public Speaking"],
                                id: \.self
                            ) { skill in
                                NavigationLink(
                                    destination: ExploreView(initialSearch: skill)
                                ) {
                                    HStack {
                                        Image(systemName: "sparkles")
                                        Text(skill).fontWeight(.medium)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(AppTheme.card)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Students to meet")
                            .font(.title2.bold())

                        ForEach(otherStudents.prefix(3)) { student in
                            NavigationLink(
                                destination: StudentDetailView(student: student)
                            ) {
                                StudentCard(student: student)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationTitle("SkillSwap")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func statCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.accent)

            Text(value)
                .font(.title.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
