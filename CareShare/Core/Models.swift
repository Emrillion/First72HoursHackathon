import Foundation

enum MemberRole: String, Codable, CaseIterable {
    case patient = "Patient", coordinator = "Coordinator", supporter = "Supporter"
}

struct Member: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var role: MemberRole
}

struct RecoveryPlan: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var patientName: String
    var discharge: Date
    var timeZone: String = TimeZone.current.identifier
    var location: String
    var hasDestination: Bool
    var budgetCents: Int
    var memberIDs: [UUID]
    var windowEnd: Date { discharge.addingTimeInterval(72 * 60 * 60) }
}

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case meals = "Meals & groceries", transportation = "Transportation"
    case household = "Household help", logistics = "Appointment logistics"
    case equipment = "Equipment delivery", relief = "Caregiver relief"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .meals: return "fork.knife"
        case .transportation: return "car"
        case .household: return "house"
        case .logistics: return "calendar"
        case .equipment: return "shippingbox"
        case .relief: return "heart"
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case needsHelp = "Needs help", claimed = "Claimed", arranged = "Arranged", completed = "Completed"
}

enum TaskVisibility: String, Codable, CaseIterable {
    case circle = "Care circle", coordinators = "Patient & coordinator"
}

struct CareTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var planID: UUID
    var title: String
    var category: TaskCategory
    var due: Date
    var isPriority: Bool = false
    var notes: String = ""
    var visibility: TaskVisibility = .circle
    var ownerID: UUID?
    var status: TaskStatus = .needsHelp
    var statusBeforeCompletion: TaskStatus?
    func isOverdue(at now: Date) -> Bool { status != .completed && due < now }
}

struct PriceLine: Codable, Equatable {
    var label: String
    var cents: Int
}

struct ServiceOption: Identifiable, Equatable {
    var id: String
    var provider: String
    var title: String
    var category: TaskCategory
    var scope: String
    var exclusions: String
    var lines: [PriceLine]
    var isReferral: Bool = false
    var totalCents: Int { lines.reduce(0) { $0 + $1.cents } }
    static let samples: [ServiceOption] = [
        .init(id: "meal", provider: "Kind Table · fictional provider", title: "Dinner, taken care of",
              category: .meals, scope: "One prepared dinner delivered at the task’s scheduled time in the fictional demo area.",
              exclusions: "Sample menu only. Dietary needs, allergens, and delivery access are not verified. No clinical nutrition advice.",
              lines: [.init(label: "Prepared meal", cents: 1800), .init(label: "Delivery", cents: 600)]),
        .init(id: "ride", provider: "Neighbor Ride · fictional provider", title: "A ride to your appointment",
              category: .transportation, scope: "One local, one-way ride at the task’s scheduled time in the fictional demo area.",
              exclusions: "Standard passenger vehicle. No wheelchair-accessible vehicle or transfer assistance in this fixture. Not emergency transport.",
              lines: [.init(label: "One-way ride", cents: 3000), .init(label: "Booking fee", cents: 0)]),
        .init(id: "community-meals", provider: "Community meal desk · sample resource", title: "Explore no-cost meal support",
              category: .meals, scope: "A sample resource for asking about prepared meals. Request hours, dietary suitability, eligibility, and delivery availability.",
              exclusions: "This demo does not contact a resource. No funding, place, or meal is reserved.", lines: [], isReferral: true),
        .init(id: "community-rides", provider: "Community ride desk · sample resource", title: "Explore no-cost transportation",
              category: .transportation, scope: "A sample resource for asking about ride assistance, accessible vehicles, eligibility, and lead times.",
              exclusions: "Availability and eligibility are unknown. This is information only; no ride is booked.", lines: [], isReferral: true)
    ]
}

enum ArrangementStatus: String, Codable { case confirmed, fulfilled, cancelled }
enum PaymentStatus: String, Codable { case approved, released }

struct Arrangement: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var taskID: UUID
    var serviceID: String
    var provider: String
    var payerID: UUID
    var requestedTime: Date
    var status: ArrangementStatus = .confirmed
    var isDemo: Bool = true
}

struct PaymentRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var arrangementID: UUID
    var payerID: UUID
    var amountCents: Int
    var currency: String = "USD"
    var status: PaymentStatus = .approved
    var receipt: String
    var createdAt: Date
}

struct Activity: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var taskID: UUID
    var actorID: UUID
    var event: String
    var timestamp: Date
}

enum CareError: LocalizedError, Equatable {
    case invalid(String)
    var errorDescription: String? { if case let .invalid(message) = self { return message }; return nil }
}

extension Int {
    var dollars: String { (Double(self) / 100).formatted(.currency(code: "USD")) }
}
