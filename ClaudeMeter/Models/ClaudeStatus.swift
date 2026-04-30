import Foundation

struct ClaudeIncident: Identifiable {
    enum Impact { case minor, major, critical, unknown }

    let id: String
    let name: String
    let status: String
    let impact: Impact
    let latestUpdate: String
    let shortlink: String?
}

struct ClaudeStatus {
    static let operational = ClaudeStatus(isOperational: true, incidents: [])

    let isOperational: Bool
    let incidents: [ClaudeIncident]
}

// MARK: - API Response Models

struct ClaudeStatusAPIResponse: Decodable {
    let status: StatusPageStatusObject
    let incidents: [StatusPageIncidentObject]

    func toClaudeStatus() -> ClaudeStatus {
        let isOperational = status.indicator == "none"
        let mapped = incidents.map { raw -> ClaudeIncident in
            let impact: ClaudeIncident.Impact = switch raw.impact {
            case "minor": .minor
            case "major": .major
            case "critical": .critical
            default: .unknown
            }
            return ClaudeIncident(
                id: raw.id,
                name: raw.name,
                status: raw.status,
                impact: impact,
                latestUpdate: raw.incidentUpdates.first?.body ?? "No details available.",
                shortlink: raw.shortlink
            )
        }
        return ClaudeStatus(isOperational: isOperational, incidents: mapped)
    }
}

struct StatusPageStatusObject: Decodable {
    let indicator: String
}

struct StatusPageIncidentObject: Decodable {
    let id: String
    let name: String
    let status: String
    let impact: String
    let shortlink: String?
    let incidentUpdates: [StatusPageIncidentUpdateObject]

    enum CodingKeys: String, CodingKey {
        case id, name, status, impact, shortlink
        case incidentUpdates = "incident_updates"
    }
}

struct StatusPageIncidentUpdateObject: Decodable {
    let body: String
}
