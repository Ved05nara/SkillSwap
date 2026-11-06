
import Foundation
import FirebaseFirestore

final class FirestoreService {

    static let shared = FirestoreService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Save Student Profile

    func saveStudent(_ student: Student, uid: String) async throws {

        var data: [String: Any] = [
            "name": student.name,
            "course": student.course,
            "year": student.year,
            "bio": student.bio,
            "initials": student.initials,
            "skillsToTeach": student.skillsToTeach,
            "skillsToLearn": student.skillsToLearn
        ]

        if let spot = student.preferredMeetingSpot {
            data["preferredMeetingSpot"] = spot
        } else {
            data["preferredMeetingSpot"] = FieldValue.delete()
        }

        if let latitude = student.preferredLatitude,
           let longitude = student.preferredLongitude {

            data["preferredLatitude"] = latitude
            data["preferredLongitude"] = longitude

        } else {
            data["preferredLatitude"] = FieldValue.delete()
            data["preferredLongitude"] = FieldValue.delete()
        }

        try await db.collection("students")
            .document(uid)
            .setData(data, merge: true)
    }

    // MARK: - Fetch Registered Students

    func fetchStudents() async throws -> [Student] {

        let snapshot = try await db.collection("students").getDocuments()

        return snapshot.documents.compactMap {
            makeStudent(from: $0, isDemo: false)
        }
    }

    // MARK: - Fetch Demo Students

    func fetchDemoStudents() async throws -> [Student] {

        let snapshot = try await db.collection("demoStudents").getDocuments()

        return snapshot.documents.compactMap {
            makeStudent(from: $0, isDemo: true)
        }
    }

    // MARK: - Convert Firestore Document Into Student

    private func makeStudent(
        from document: QueryDocumentSnapshot,
        isDemo: Bool
    ) -> Student? {

        let data = document.data()

        guard
            let name = data["name"] as? String,
            let course = data["course"] as? String,
            let year = data["year"] as? String,
            let bio = data["bio"] as? String,
            let initials = data["initials"] as? String,
            let skillsToTeach = data["skillsToTeach"] as? [String],
            let skillsToLearn = data["skillsToLearn"] as? [String]
        else {
            return nil
        }

        return Student(
            id: isDemo ? "demo_\(document.documentID)" : document.documentID,
            name: name,
            course: course,
            year: year,
            bio: bio,
            skillsToTeach: skillsToTeach,
            skillsToLearn: skillsToLearn,
            initials: initials,
            isDemo: isDemo,
            preferredMeetingSpot: data["preferredMeetingSpot"] as? String,
            preferredLatitude: data["preferredLatitude"] as? Double,
            preferredLongitude: data["preferredLongitude"] as? Double
        )
    }

    // MARK: - Save Preferred Meeting Spot

    func savePreferredMeetingSpot(
        uid: String,
        spot: String,
        latitude: Double,
        longitude: Double
    ) async throws {

        guard (-90...90).contains(latitude),
              (-180...180).contains(longitude) else {

            throw NSError(
                domain: "SkillSwap",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid meeting location."
                ]
            )
        }

        try await db.collection("students")
            .document(uid)
            .setData([
                "preferredMeetingSpot": spot,
                "preferredLatitude": latitude,
                "preferredLongitude": longitude
            ], merge: true)
    }

    // MARK: - Update Live Location

    func updateLiveLocation(
        uid: String,
        latitude: Double,
        longitude: Double
    ) async throws {

        guard (-90...90).contains(latitude),
              (-180...180).contains(longitude) else {

            throw NSError(
                domain: "SkillSwap",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid live location."
                ]
            )
        }

        let expiry = Date().addingTimeInterval(30 * 60)

        try await db.collection("liveLocations")
            .document(uid)
            .setData([
                "isSharing": true,
                "latitude": latitude,
                "longitude": longitude,
                "expiresAt": Timestamp(date: expiry)
            ], merge: true)
    }

    // MARK: - Stop Live Location Sharing

    func stopLiveLocationSharing(uid: String) async throws {

        try await db.collection("liveLocations")
            .document(uid)
            .setData([
                "isSharing": false,
                "latitude": FieldValue.delete(),
                "longitude": FieldValue.delete(),
                "expiresAt": FieldValue.delete()
            ], merge: true)
    }

    // MARK: - Check Existing Pending Request

    func hasPendingRequest(
        senderId: String,
        receiverId: String,
        offering: String,
        requesting: String
    ) async throws -> Bool {

        let snapshot = try await db.collection("swapRequests")
            .whereField("senderId", isEqualTo: senderId)
            .getDocuments()

        return snapshot.documents.contains { document in

            let data = document.data()

            return
                (data["receiverId"] as? String) == receiverId &&
                (data["offeredSkill"] as? String) == offering &&
                (data["requestedSkill"] as? String) == requesting &&
                (data["status"] as? String) == "Pending"
        }
    }

    // MARK: - Send Swap Request

    func sendRequest(_ request: SwapRequest) async throws {

        let data: [String: Any] = [

            "senderId": request.senderId,
            "receiverId": request.receiverId,

            "studentId": request.student.id,
            "studentName": request.student.name,
            "studentCourse": request.student.course,
            "studentYear": request.student.year,
            "studentBio": request.student.bio,
            "studentInitials": request.student.initials,

            "studentSkillsToTeach": request.student.skillsToTeach,
            "studentSkillsToLearn": request.student.skillsToLearn,

            "offeredSkill": request.offeredSkill,
            "requestedSkill": request.requestedSkill,

            "status": request.status.rawValue,
            "createdAt": Timestamp(date: request.createdAt)
        ]

        try await db.collection("swapRequests")
            .document(request.id)
            .setData(data)
    }

    // MARK: - Fetch Swap Requests

    func fetchRequests(for uid: String) async throws -> [SwapRequest] {

        let sent = try await db.collection("swapRequests")
            .whereField("senderId", isEqualTo: uid)
            .getDocuments()

        let received = try await db.collection("swapRequests")
            .whereField("receiverId", isEqualTo: uid)
            .getDocuments()

        let documents = Dictionary(
            (sent.documents + received.documents).map {
                ($0.documentID, $0)
            },
            uniquingKeysWith: { first, _ in first }
        )

        return documents.values.compactMap { document in

            let data = document.data()

            guard
                let senderId = data["senderId"] as? String,
                let receiverId = data["receiverId"] as? String,

                let studentId = data["studentId"] as? String,
                let studentName = data["studentName"] as? String,
                let studentCourse = data["studentCourse"] as? String,
                let studentYear = data["studentYear"] as? String,
                let studentBio = data["studentBio"] as? String,
                let studentInitials = data["studentInitials"] as? String,

                let studentSkillsToTeach = data["studentSkillsToTeach"] as? [String],
                let studentSkillsToLearn = data["studentSkillsToLearn"] as? [String],

                let offeredSkill = data["offeredSkill"] as? String,
                let requestedSkill = data["requestedSkill"] as? String,

                let statusString = data["status"] as? String,
                let status = RequestStatus(rawValue: statusString)

            else {
                return nil
            }

            let student = Student(
                id: studentId,
                name: studentName,
                course: studentCourse,
                year: studentYear,
                bio: studentBio,
                skillsToTeach: studentSkillsToTeach,
                skillsToLearn: studentSkillsToLearn,
                initials: studentInitials
            )

            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

            return SwapRequest(
                id: document.documentID,
                student: student,
                offeredSkill: offeredSkill,
                requestedSkill: requestedSkill,
                status: status,
                createdAt: createdAt,
                senderId: senderId,
                receiverId: receiverId
            )
        }
    }

    // MARK: - Update Request Status

    func updateRequest(
        id: String,
        status: RequestStatus
    ) async throws {

        guard status != .pending else {
            throw NSError(
                domain: "SkillSwap",
                code: 3,
                userInfo: [
                    NSLocalizedDescriptionKey: "Invalid request status."
                ]
            )
        }

        try await db.collection("swapRequests")
            .document(id)
            .updateData([
                "status": status.rawValue
            ])
    }
}
