import SwiftUI
import FirebaseAuth

struct ExploreView: View {

    @EnvironmentObject private var appData: AppData
    @EnvironmentObject private var authService: AuthService

    @State private var searchText: String
    @State private var selectedCategory = "All"

    private let categories = [
        "All", "Technology", "Design", "Creative", "Communication"
    ]

    init(initialSearch: String = "") {
        _searchText = State(initialValue: initialSearch)
    }

    private var filteredStudents: [Student] {
        appData.students.filter { student in

            guard student.id != authService.user?.uid else {
                return false
            }

            let matchesSearch = searchText.isEmpty ||
                student.name.localizedCaseInsensitiveContains(searchText) ||
                student.skillsToTeach.contains {
                    $0.localizedCaseInsensitiveContains(searchText)
                } ||
                student.skillsToLearn.contains {
                    $0.localizedCaseInsensitiveContains(searchText)
                }

            let matchesCategory: Bool

            switch selectedCategory {
            case "Technology":
                matchesCategory = student.skillsToTeach.contains {
                    ["SwiftUI", "Swift", "Python", "HTML", "CSS"].contains($0)
                }

            case "Design":
                matchesCategory = student.skillsToTeach.contains {
                    ["Figma", "Graphic Design", "UI Design", "Canva"].contains($0)
                }

            case "Creative":
                matchesCategory = student.skillsToTeach.contains {
                    ["Photography", "Guitar", "Video Editing", "French"].contains($0)
                }

            case "Communication":
                matchesCategory = student.skillsToTeach.contains {
                    ["Public Speaking", "Presentation Skills"].contains($0)
                }

            default:
                matchesCategory = true
            }

            return matchesSearch && matchesCategory
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        "Search students or skills",
                        text: $searchText
                    )
                }
                .padding(12)
                .background(AppTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Button(category) {
                                selectedCategory = category
                            }
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category
                                ? AppTheme.accent
                                : AppTheme.card
                            )
                            .foregroundStyle(
                                selectedCategory == category
                                ? .white
                                : .primary
                            )
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal)
                }

                if filteredStudents.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredStudents) { student in
                        NavigationLink(
                            destination: StudentDetailView(student: student)
                        ) {
                            StudentCard(student: student)
                                .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppTheme.background)
            .navigationTitle("Explore")
        }
    }
}
