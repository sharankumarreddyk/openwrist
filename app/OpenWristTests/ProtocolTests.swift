import XCTest
@testable import OpenWrist

final class ProtocolTests: XCTestCase {

    // Same byte vectors as firmware/test/test_core.c and Packets.swift.
    func testStepDecode() {
        let s = StepUpdate.decode(Data([0x40, 0x0D, 0x03, 0x00, 0x1E, 0x00]))
        XCTAssertEqual(s, StepUpdate(steps: 200_000, activeMinutes: 30))
    }

    func testStatusDecode() {
        let s = StatusUpdate.decode(Data([72, 1, 0x01, 0x00]))
        XCTAssertEqual(s?.batteryPct, 72)
        XCTAssertTrue(s?.charging ?? false)
        XCTAssertEqual(s?.versionString, "0.1")
    }

    func testConfigEncodeClampsBrightness() {
        XCTAssertEqual(ConfigPacket(use24h: true, brightness: 200, watchFaceId: 2).encode(),
                       Data([1, 100, 2]))
    }

    func testWeatherEncodeSignedTemp() {
        XCTAssertEqual(WeatherPacket(tempCx10: -50, conditionCode: 2, humidityPct: 80).encode(),
                       Data([0xCE, 0xFF, 2, 80]))
    }

    // RFC 6238 Appendix B (SHA1, 8 digits, secret "12345678901234567890").
    func testTOTP_RFC6238() {
        let key = Data("12345678901234567890".utf8)
        let vectors: [(TimeInterval, String)] = [
            (59, "94287082"),
            (1111111109, "07081804"),
            (1111111111, "14050471"),
            (1234567890, "89005924"),
            (2000000000, "69279037"),
            (20000000000, "65353130"),
        ]
        for (t, expected) in vectors {
            let got = OWTOTP.code(secret: key, at: Date(timeIntervalSince1970: t),
                                  period: 30, digits: 8)
            XCTAssertEqual(got, expected, "T=\(t)")
        }
    }

    func testBase32Decode() {
        XCTAssertEqual(OWTOTP.base32Decode("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"),
                       Data("12345678901234567890".utf8))
        XCTAssertNil(OWTOTP.base32Decode("!!bad!!"))
    }

    func testOtpauthParse() {
        let a = TOTPAccount.parse(otpauth:
            "otpauth://totp/ACME:you@work.com?secret=GEZDGNBVGY3TQOJQ&issuer=ACME&digits=6&period=30")
        XCTAssertEqual(a?.issuer, "ACME")
        XCTAssertEqual(a?.digits, 6)
        XCTAssertNotNil(a?.secret)
        XCTAssertNil(TOTPAccount.parse(otpauth: "otpauth://totp/x?issuer=y")) // no secret
    }

    func testWMOMapping() {
        XCTAssertEqual(WeatherService.mapWMO(0), 0)   // clear
        XCTAssertEqual(WeatherService.mapWMO(3), 1)   // clouds
        XCTAssertEqual(WeatherService.mapWMO(48), 5)  // fog
        XCTAssertEqual(WeatherService.mapWMO(65), 2)  // rain
        XCTAssertEqual(WeatherService.mapWMO(75), 3)  // snow
        XCTAssertEqual(WeatherService.mapWMO(95), 4)  // thunder
    }
}
