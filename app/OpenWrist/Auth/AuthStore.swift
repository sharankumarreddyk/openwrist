import Foundation

struct TOTPAccount: Identifiable, Codable, Equatable {
    var id = UUID()
    var issuer: String
    var label: String
    var secretBase32: String
    var digits: Int = 6
    var period: Int = 30

    var secret: Data? { OWTOTP.base32Decode(secretBase32) }

    func code(at t: Date = Date()) -> String {
        guard let s = secret else { return "------" }
        return OWTOTP.code(secret: s, at: t, period: period, digits: digits)
    }

    // Parse an otpauth://totp/Label?secret=...&issuer=...&digits=...&period=... URI.
    static func parse(otpauth uri: String) -> TOTPAccount? {
        guard let c = URLComponents(string: uri),
              c.scheme == "otpauth", c.host == "totp",
              let items = c.queryItems,
              let secret = items.first(where: { $0.name == "secret" })?.value,
              OWTOTP.base32Decode(secret) != nil
        else { return nil }
        let label = c.path.hasPrefix("/") ? String(c.path.dropFirst()) : c.path
        let issuer = items.first(where: { $0.name == "issuer" })?.value ?? ""
        let digits = Int(items.first(where: { $0.name == "digits" })?.value ?? "") ?? 6
        let period = Int(items.first(where: { $0.name == "period" })?.value ?? "") ?? 30
        return TOTPAccount(issuer: issuer.isEmpty ? label : issuer,
                           label: label, secretBase32: secret,
                           digits: digits, period: period)
    }
}

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var accounts: [TOTPAccount] = []
    private let key = "openwrist.totp.accounts"

    init() { load() }

    func add(_ account: TOTPAccount) { accounts.append(account); persist() }
    func remove(at offsets: IndexSet) { accounts.remove(atOffsets: offsets); persist() }

    private func load() {
        guard let data = Keychain.load(key),
              let decoded = try? JSONDecoder().decode([TOTPAccount].self, from: data)
        else { return }
        accounts = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(accounts) else { return }
        Keychain.save(data, for: key)
    }
}
