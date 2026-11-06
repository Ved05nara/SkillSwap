
import SwiftUI

struct RequestsView: View {

    @EnvironmentObject private var appData: AppData

    var body: some View {
        NavigationStack {
            Group {
                if appData.requests.isEmpty {
                    ContentUnavailableView(
                        "No requests yet",
                        systemImage: "arrow.left.arrow.right",
                        description: Text(
                            "When you send a skill-swap request, it will appear here."
                        )
                    )
                } else {
                    List {
                        ForEach(appData.requests) { request in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    StudentAvatar(
                                        initials: request.student.initials
                                    )

                                    VStack(alignment: .leading) {
                                        Text(request.student.name)
                                            .font(.headline)

                                        Text(request.status.rawValue)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(
                                                request.status == .accepted
                                                ? .green
                                                : .secondary
                                            )
                                    }

                                    Spacer()

                                    Text(request.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text("You teach: \(request.offeredSkill)")
                                Text("You learn: \(request.requestedSkill)")

                                if request.status == .pending {
                                    HStack {
                                        Button("Accept") {
                                            appData.updateRequest(
                                                request,
                                                to: .accepted
                                            )
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(
                                            appData.updatingRequestIDs
                                                .contains(request.id)
                                        )

                                        Button("Decline", role: .destructive) {
                                            appData.updateRequest(
                                                request,
                                                to: .declined
                                            )
                                        }
                                        .buttonStyle(.bordered)
                                        .disabled(
                                            appData.updatingRequestIDs
                                                .contains(request.id)
                                        )

                                        if appData.updatingRequestIDs
                                            .contains(request.id) {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("Requests")
            .task {
                await appData.loadRequests()
            }
            .alert(
                "Request Error",
                isPresented: Binding(
                    get: { appData.errorMessage != nil },
                    set: {
                        if !$0 {
                            appData.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK") {
                    appData.errorMessage = nil
                }
            } message: {
                Text(appData.errorMessage ?? "")
            }
        }
    }
}
