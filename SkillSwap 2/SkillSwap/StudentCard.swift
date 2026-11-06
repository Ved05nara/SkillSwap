import SwiftUI

struct StudentCard: View {
    let student: Student

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            StudentAvatar(initials: student.initials)
            VStack(alignment: .leading, spacing: 6) {
                Text(student.name).font(.headline).foregroundStyle(.primary)
                Text("\(student.course) • \(student.year)")
                    .font(.caption).foregroundStyle(.secondary)
                Text("Teaches").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                FlexibleSkillTags(skills: student.skillsToTeach)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FlexibleSkillTags: View {
    let skills: [String]
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack { ForEach(skills.prefix(3), id: \.self) { SkillTag(title: $0) } }
            VStack(alignment: .leading) {
                ForEach(skills.prefix(3), id: \.self) { SkillTag(title: $0) }
            }
        }
    }
}
