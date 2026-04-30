import Foundation

protocol ClaudeStatusServiceProtocol: Sendable {
    func fetchStatus() async -> ClaudeStatus
}
