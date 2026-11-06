
import SwiftUI
import MapKit

struct CampusMapView: View {

    @EnvironmentObject private var appData: AppData

    private let campusCoordinate = CLLocationCoordinate2D(
        latitude: 19.0731,
        longitude: 72.8998
    )

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedStudent: Student?

    init() {
        let coordinate = CLLocationCoordinate2D(
            latitude: 19.0731,
            longitude: 72.8998
        )

        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.004,
                        longitudeDelta: 0.004
                    )
                )
            )
        )
    }

    private var studentsWithMeetingSpots: [Student] {
        appData.students.filter { student in
            !student.isDemo &&
            student.preferredMeetingSpot != nil &&
            student.preferredLatitude != nil &&
            student.preferredLongitude != nil
        }
    }

    var body: some View {

        NavigationStack {

            ZStack(alignment: .bottom) {

                // MARK: - Campus Map

                Map(position: $cameraPosition) {

                    // Permanent campus marker
                    Marker(
                        "K. J. Somaiya Campus",
                        coordinate: campusCoordinate
                    )
                    .tint(.indigo)

                    // Student meeting spot pins
                    ForEach(studentsWithMeetingSpots) { student in

                        if let latitude = student.preferredLatitude,
                           let longitude = student.preferredLongitude {

                            Annotation(
                                student.name,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: latitude,
                                    longitude: longitude
                                ),
                                anchor: .bottom
                            ) {

                                Button {
                                    selectedStudent = student
                                } label: {

                                    StudentMapPin(
                                        student: student,
                                        isSelected: selectedStudent?.id == student.id
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .ignoresSafeArea(edges: .bottom)

                // MARK: - Bottom Information Card

                VStack(spacing: 14) {

                    // Campus information
                    HStack(spacing: 12) {

                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.indigo)

                        VStack(alignment: .leading, spacing: 4) {

                            Text("K. J. Somaiya Campus")
                                .font(.headline)

                            Text("Vidyavihar, Mumbai")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            recenterMap()
                        } label: {

                            Image(systemName: "location.north.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(.indigo, in: Circle())
                        }
                        .accessibilityLabel("Recenter campus map")
                    }

                    Divider()

                    // Student count
                    HStack(spacing: 8) {

                        Image(systemName: "person.2.fill")
                            .foregroundStyle(.indigo)

                        Text("\(studentsWithMeetingSpots.count) students")
                            .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text("MEETING SPOTS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(.secondary)
                    }

                    // Instructions
                    HStack(alignment: .top, spacing: 8) {

                        Image(systemName: "hand.tap.fill")
                            .foregroundStyle(.indigo)

                        Text("Tap a student pin to explore their profile and propose a skill swap.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer(minLength: 0)
                    }
                }
                .padding(18)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
                .padding()
            }

            .navigationTitle("Campus Map")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - Student Profile Sheet

            .sheet(item: $selectedStudent) { student in

                NavigationStack {

                    VStack(spacing: 0) {

                        HStack {

                            VStack(alignment: .leading, spacing: 5) {

                                Text(student.preferredMeetingSpot ?? "Meeting spot")
                                    .font(.headline)

                                Text(student.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                selectedStudent = nil
                            } label: {

                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()

                        Divider()

                        StudentDetailView(student: student)
                    }
                    .toolbar(.hidden, for: .navigationBar)
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }

        .task {
            await appData.loadStudents()
        }
    }

    // MARK: - Recenter Map

    private func recenterMap() {

        withAnimation(.easeInOut(duration: 0.5)) {

            cameraPosition = .region(
                MKCoordinateRegion(
                    center: campusCoordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.004,
                        longitudeDelta: 0.004
                    )
                )
            )
        }
    }
}

// MARK: - Custom Student Map Pin

private struct StudentMapPin: View {

    let student: Student
    let isSelected: Bool

    var body: some View {

        VStack(spacing: 5) {

            // Student initials
            StudentAvatar(initials: student.initials)
                .frame(width: 44, height: 44)
                .background(.white, in: Circle())
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(
                            isSelected ? Color.indigo : Color.white,
                            lineWidth: isSelected ? 4 : 3
                        )
                }
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            // Meeting spot label
            Text(student.preferredMeetingSpot ?? "Meeting spot")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(.regularMaterial, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.12), radius: 3, y: 2)
        }
        .scaleEffect(isSelected ? 1.12 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}
