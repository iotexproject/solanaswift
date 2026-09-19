import Security
@testable import SolanaSwift
import XCTest

final class MnemonicTests: XCTestCase {
    func testRandomMnemonicRejectsInvalidStrengthBeforeRequestingEntropy() {
        for strength in [0, -32, 31, 129] {
            XCTAssertThrowsError(
                try Mnemonic(strength: strength) { _ in
                    XCTFail("Invalid strength must be rejected before requesting entropy")
                    return errSecSuccess
                }
            ) { error in
                guard case MnemonicError.invalidStrength = error else {
                    return XCTFail("Expected invalidStrength, got \(error)")
                }
            }
        }
    }

    func testRandomMnemonicFailsClosedWhenEntropySourceFails() {
        XCTAssertThrowsError(
            try Mnemonic(strength: 128) { _ in errSecNotAvailable }
        ) { error in
            guard case MnemonicError.entropyUnavailable = error else {
                return XCTFail("Expected entropyUnavailable, got \(error)")
            }
        }
    }

    func testRandomMnemonicUsesSuccessfulEntropy() throws {
        let mnemonic = try Mnemonic(strength: 128) { bytes in
            bytes = [UInt8](repeating: 0, count: bytes.count)
            return errSecSuccess
        }

        XCTAssertEqual(
            mnemonic.phrase,
            [
                "abandon", "abandon", "abandon", "abandon", "abandon", "abandon",
                "abandon", "abandon", "abandon", "abandon", "abandon", "about",
            ]
        )
    }

    func testRandomMnemonicRejectsUnexpectedEntropyLength() {
        XCTAssertThrowsError(
            try Mnemonic(strength: 128) { bytes in
                bytes.removeLast()
                return errSecSuccess
            }
        ) { error in
            guard case MnemonicError.entropyUnavailable = error else {
                return XCTFail("Expected entropyUnavailable, got \(error)")
            }
        }
    }
}
