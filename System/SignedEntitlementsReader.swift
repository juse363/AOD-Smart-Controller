import Foundation

/// Reads only this app executable's embedded code-signature entitlements.
/// This is a diagnostic parser; it does not grant or manufacture entitlements.
enum SignedEntitlementsReader {
    enum ReadError: LocalizedError {
        case executableUnavailable
        case unreadableExecutable
        case unsupportedMachO
        case missingCodeSignature
        case malformedSignature
        case missingEntitlements

        var errorDescription: String? {
            switch self {
            case .executableUnavailable: return "无法定位当前 App 的可执行文件"
            case .unreadableExecutable: return "无法读取当前 App 的可执行文件"
            case .unsupportedMachO: return "当前可执行文件格式暂不支持"
            case .missingCodeSignature: return "可执行文件中没有可读取的代码签名"
            case .malformedSignature: return "代码签名结构不完整或无法解析"
            case .missingEntitlements: return "签名中没有 XML App Entitlements"
            }
        }
    }

    private static let lcCodeSignature: UInt32 = 0x1d
    private static let embeddedSignatureMagic: UInt32 = 0xfade0cc0
    private static let entitlementsMagic: UInt32 = 0xfade7171
    private static let appGroupsKey = "com.apple.security.application-groups"

    static func readAppGroups() throws -> [String] {
        guard let executableURL = Bundle.main.executableURL else {
            throw ReadError.executableUnavailable
        }
        guard let data = try? Data(contentsOf: executableURL, options: .mappedIfSafe) else {
            throw ReadError.unreadableExecutable
        }
        let entitlements = try readEntitlements(from: data)
        guard let rawGroups = entitlements[appGroupsKey] as? [String] else {
            return []
        }
        return Array(Set(rawGroups.filter { $0.hasPrefix("group.") && !$0.isEmpty })).sorted()
    }

    private static func readEntitlements(from data: Data) throws -> [String: Any] {
        guard data.count >= 32 else { throw ReadError.unsupportedMachO }
        let magic = readLE32(data, 0)
        let headerSize: Int
        switch magic {
        case 0xfeedfacf: headerSize = 32 // MH_MAGIC_64
        case 0xfeedface: headerSize = 28 // MH_MAGIC
        default: throw ReadError.unsupportedMachO
        }

        let commandCount = Int(readLE32(data, 16))
        let commandBytes = Int(readLE32(data, 20))
        guard headerSize <= data.count, commandBytes <= data.count - headerSize else {
            throw ReadError.malformedSignature
        }

        var cursor = headerSize
        let commandEnd = headerSize + commandBytes
        var signatureRange: Range<Int>?

        for _ in 0..<commandCount {
            guard cursor <= commandEnd - 8 else { throw ReadError.malformedSignature }
            let command = readLE32(data, cursor)
            let commandSize = Int(readLE32(data, cursor + 4))
            guard commandSize >= 8, cursor <= commandEnd - commandSize else {
                throw ReadError.malformedSignature
            }
            if command == lcCodeSignature {
                guard commandSize >= 16 else { throw ReadError.malformedSignature }
                let offset = Int(readLE32(data, cursor + 8))
                let size = Int(readLE32(data, cursor + 12))
                guard offset >= 0, size >= 12, offset <= data.count, size <= data.count - offset else {
                    throw ReadError.malformedSignature
                }
                signatureRange = offset..<(offset + size)
                break
            }
            cursor += commandSize
        }

        guard let range = signatureRange else { throw ReadError.missingCodeSignature }
        let signature = data.subdata(in: range)
        guard readBE32(signature, 0) == embeddedSignatureMagic else {
            throw ReadError.malformedSignature
        }
        let totalLength = Int(readBE32(signature, 4))
        let count = Int(readBE32(signature, 8))
        guard totalLength >= 12, totalLength <= signature.count,
              count <= (totalLength - 12) / 8 else {
            throw ReadError.malformedSignature
        }

        for index in 0..<count {
            let entryOffset = 12 + index * 8
            let slot = readBE32(signature, entryOffset)
            let blobOffset = Int(readBE32(signature, entryOffset + 4))
            guard blobOffset >= 0, blobOffset <= totalLength - 8 else { continue }
            let blobMagic = readBE32(signature, blobOffset)
            let blobLength = Int(readBE32(signature, blobOffset + 4))
            guard blobLength >= 8, blobLength <= totalLength - blobOffset else { continue }
            if slot == 5 || blobMagic == entitlementsMagic {
                guard blobMagic == entitlementsMagic, blobLength > 8 else { continue }
                let plistData = signature.subdata(in: (blobOffset + 8)..<(blobOffset + blobLength))
                if let object = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil),
                   let dictionary = object as? [String: Any] {
                    return dictionary
                }
            }
        }
        throw ReadError.missingEntitlements
    }

    private static func readLE32(_ data: Data, _ offset: Int) -> UInt32 {
        UInt32(data[offset]) |
        (UInt32(data[offset + 1]) << 8) |
        (UInt32(data[offset + 2]) << 16) |
        (UInt32(data[offset + 3]) << 24)
    }

    private static func readBE32(_ data: Data, _ offset: Int) -> UInt32 {
        (UInt32(data[offset]) << 24) |
        (UInt32(data[offset + 1]) << 16) |
        (UInt32(data[offset + 2]) << 8) |
        UInt32(data[offset + 3])
    }
}
