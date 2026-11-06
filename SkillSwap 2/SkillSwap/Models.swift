
import Foundation

// MARK: - Student Model

struct Student: Identifiable, Hashable {

    var id: String
    var name: String
    var course: String
    var year: String
    var bio: String
    var skillsToTeach: [String]
    var skillsToLearn: [String]
    var initials: String
    var isDemo: Bool

    // MARK: - Preferred Meeting Location

    var preferredMeetingSpot: String?
    var preferredLatitude: Double?
    var preferredLongitude: Double?

    // MARK: - Optional Live Location

    var isLiveLocationSharingEnabled: Bool
    var liveLatitude: Double?
    var liveLongitude: Double?
    var liveLocationExpiresAt: Date?

    init(
        id: String = UUID().uuidString,
        name: String,
        course: String,
        year: String,
        bio: String,
        skillsToTeach: [String],
        skillsToLearn: [String],
        initials: String,
        isDemo: Bool = false,
        preferredMeetingSpot: String? = nil,
        preferredLatitude: Double? = nil,
        preferredLongitude: Double? = nil,
        isLiveLocationSharingEnabled: Bool = false,
        liveLatitude: Double? = nil,
        liveLongitude: Double? = nil,
        liveLocationExpiresAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.course = course
        self.year = year
        self.bio = bio
        self.skillsToTeach = skillsToTeach
        self.skillsToLearn = skillsToLearn
        self.initials = initials
        self.isDemo = isDemo

        self.preferredMeetingSpot = preferredMeetingSpot
        self.preferredLatitude = preferredLatitude
        self.preferredLongitude = preferredLongitude

        self.isLiveLocationSharingEnabled = isLiveLocationSharingEnabled
        self.liveLatitude = liveLatitude
        self.liveLongitude = liveLongitude
        self.liveLocationExpiresAt = liveLocationExpiresAt
    }

    // MARK: - Active Live Location Check

    var hasActiveLiveLocation: Bool {
        guard isLiveLocationSharingEnabled,
              let expiry = liveLocationExpiresAt,
              let latitude = liveLatitude,
              let longitude = liveLongitude else {
            return false
        }

        return expiry > Date()
            && (-90...90).contains(latitude)
            && (-180...180).contains(longitude)
    }
}

// MARK: - Request Status

enum RequestStatus: String, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
}

// MARK: - Swap Request Model

struct SwapRequest: Identifiable {

    var id: String
    var student: Student
    var offeredSkill: String
    var requestedSkill: String
    var status: RequestStatus
    var createdAt: Date
    var senderId: String
    var receiverId: String

    init(
        id: String = UUID().uuidString,
        student: Student,
        offeredSkill: String,
        requestedSkill: String,
        status: RequestStatus = .pending,
        createdAt: Date = Date(),
        senderId: String = "",
        receiverId: String = ""
    ) {
        self.id = id
        self.student = student
        self.offeredSkill = offeredSkill
        self.requestedSkill = requestedSkill
        self.status = status
        self.createdAt = createdAt
        self.senderId = senderId
        self.receiverId = receiverId
    }
}
