import Foundation
import CryptoKit

// TOTP (RFC 6238) / HOTP over HMAC-SHA1 — the app-side authenticator, matching
// firmware/core/totp.c byte-for-byte. Verified against RFC 6238 vectors in tests.
enum OWTOTP {
    static func base32Decode(_ str: String) -> Data? {
        var bits = 0, value = 0
        var out = [UInt8]()
        for ch in str.uppercased() where ch != "=" && ch != " " {
            guard let a = ch.asciiValue else { return nil }
            let v: Int
            if a >= 65 && a <= 90 { v = Int(a - 65) }        // A–Z
            else if a >= 50 && a <= 55 { v = Int(a - 50) + 26 } // 2–7
            else { return nil }
            value = (value << 5) | v
            bits += 5
            if bits >= 8 { bits -= 8; out.append(UInt8((value >> bits) & 0xFF)) }
        }
        return Data(out)
    }

    static func hotp(secret: Data, counter: UInt64, digits: Int = 6) -> String {
        var be = counter.bigEndian
        let msg = withUnsafeBytes(of: &be) { Data($0) }
        let mac = Data(HMAC<Insecure.SHA1>.authenticationCode(
            for: msg, using: SymmetricKey(data: secret)))
        let off = Int(mac[19] & 0x0F)
        let bin = (UInt32(mac[off] & 0x7F) << 24) | (UInt32(mac[off + 1]) << 16)
                | (UInt32(mac[off + 2]) << 8) | UInt32(mac[off + 3])
        var mod: UInt32 = 1
        for _ in 0..<digits { mod *= 10 }
        return String(format: "%0\(digits)u", bin % mod)
    }

    static func code(secret: Data, at time: Date = Date(),
                     period: Int = 30, digits: Int = 6) -> String {
        let counter = UInt64(time.timeIntervalSince1970) / UInt64(period)
        return hotp(secret: secret, counter: counter, digits: digits)
    }

    static func secondsRemaining(at time: Date = Date(), period: Int = 30) -> Int {
        period - Int(time.timeIntervalSince1970) % period
    }
}
