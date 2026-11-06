
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class AppData: ObservableObject {

    @Published var students: [Student] = []
    @Published var requests: [SwapRequest] = []
    @Published var errorMessage: String?
    @Published var updatingRequestIDs: Set<String> = []

    private let firestore = FirestoreService.shared

    // MARK: - Load Students

    func loadStudents() async {
        do {
            async let realStudents = firestore.fetchStudents()
            async let demoStudents = firestore.fetchDemoStudents()

            let (real, demo) = try await (realStudents, demoStudents)

            students = real + demo

        } catch {
            errorMessage = "Unable to load students: \(error.localizedDescription)"
        }
    }

    // MARK: - Save Profile

    func saveProfile(_ student: Student) async {

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Please log in first."
            return
        }

        do {
            var profile = student
            profile.id = uid
            profile.isDemo = false

            try await firestore.saveStudent(profile, uid: uid)

            if let index = students.firstIndex(where: { $0.id == uid }) {
                students[index] = profile
            } else {
                students.insert(profile, at: 0)
            }

            errorMessage = nil

        } catch {
            errorMessage = "Unable to save profile: \(error.localizedDescription)"
        }
    }

    // MARK: - Send Swap Request

    @discardableResult
    func sendRequest(
        to student: Student,
        offering: String,
        requesting: String
    ) async -> Bool {

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Please log in before sending a request."
            return false
        }

        // Prevent sending a request to yourself.
        guard uid != student.id else {
            errorMessage = "You cannot send a request to yourself."
            return false
        }

        // Find the current student's profile.
        guard let myProfile = students.first(where: { $0.id == uid }) else {
            errorMessage = "Please complete your profile before sending a request."
            return false
        }

        // Clean up selected skill names.
        let cleanOffering = offering.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanRequesting = requesting.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanOffering.isEmpty && !cleanRequesting.isEmpty else {
            errorMessage = "Please select both skills."
            return false
        }

        // Ensure the offered skill belongs to the current student.
        guard myProfile.skillsToTeach.contains(cleanOffering) else {
            errorMessage = "You can only offer skills listed in your profile."
            return false
        }

        // Ensure the requested skill belongs to the other student.
        guard student.skillsToTeach.contains(cleanRequesting) else {
            errorMessage = "You can only request skills this student can teach."
            return false
        }

        // Check for an existing pending request locally.
        let localDuplicate = requests.contains {
            $0.senderId == uid &&
            $0.receiverId == student.id &&
            $0.offeredSkill == cleanOffering &&
            $0.requestedSkill == cleanRequesting &&
            $0.status == .pending
        }

        guard !localDuplicate else {
            errorMessage = "You already have this pending request."
            return false
        }

        do {
            // Check Firestore for an existing pending request.
            let duplicateExists = try await firestore.hasPendingRequest(
                senderId: uid,
                receiverId: student.id,
                offering: cleanOffering,
                requesting: cleanRequesting
            )

            guard !duplicateExists else {
                errorMessage = "You already have this pending request."
                return false
            }

            let request = SwapRequest(
                student: student,
                offeredSkill: cleanOffering,
                requestedSkill: cleanRequesting,
                senderId: uid,
                receiverId: student.id
            )

            try await firestore.sendRequest(request)

            requests.insert(request, at: 0)

            errorMessage = nil
            return true

        } catch {
            errorMessage = "Unable to send request: \(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Load Requests

    func loadRequests() async {

        guard let uid = Auth.auth().currentUser?.uid else {
            requests = []
            return
        }

        do {
            requests = try await firestore.fetchRequests(for: uid)
            errorMessage = nil

        } catch {
            errorMessage = "Unable to load requests: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Request

    func updateRequest(_ request: SwapRequest, to status: RequestStatus) {

        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Please log in first."
            return
        }

        // Only the receiver can respond.
        guard request.receiverId == uid else {
            errorMessage = "Only the receiving student can respond."
            return
        }

        // Only pending requests can be updated.
        guard request.status == .pending else {
            errorMessage = "This request has already been responded to."
            return
        }

        // A request cannot be changed back to pending.
        guard status != .pending else {
            errorMessage = "A request cannot be changed back to pending."
            return
        }

        // Prevent multiple simultaneous updates.
        guard !updatingRequestIDs.contains(request.id) else {
            return
        }

        updatingRequestIDs.insert(request.id)

        Task {
            defer {
                updatingRequestIDs.remove(request.id)
            }

            do {
                try await firestore.updateRequest(
                    id: request.id,
                    status: status
                )

                if let index = requests.firstIndex(where: {
                    $0.id == request.id
                }) {
                    requests[index].status = status
                }

                errorMessage = nil

            } catch {
                errorMessage = "Unable to update request: \(error.localizedDescription)"
            }
        }
    }
}
