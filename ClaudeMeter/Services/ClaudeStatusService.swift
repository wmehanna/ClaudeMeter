import Foundation
import os

actor ClaudeStatusService: ClaudeStatusServiceProtocol {
    private static let logger = Logger(subsystem: "com.claudemeter", category: "ClaudeStatusService")
    private static let endpoint = "https://status.claude.com/api/v2/summary.json"

    private let session: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10
        self.session = URLSession(configuration: config)
    }

    func fetchStatus() async -> ClaudeStatus {
        guard let url = URL(string: Self.endpoint) else { return .operational }
        do {
            let (data, _) = try await session.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(ClaudeStatusAPIResponse.self, from: data)
            return response.toClaudeStatus()
        } catch {
            Self.logger.error("Failed to fetch Claude status: \(error.localizedDescription)")
            return .operational
        }
    }
}
