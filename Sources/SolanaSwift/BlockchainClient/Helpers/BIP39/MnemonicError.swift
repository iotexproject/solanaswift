import Foundation

public enum MnemonicError: Error {
    case invalidMnemonic
    case invalidEntropy
    case invalidStrength
    case entropyUnavailable
}
