import Foundation
import SortedCollections

struct CBORMapValue: Equatable {
    let key: CBOR
    let value: CBOR
}

struct CBORMapKey: Comparable {
    let keyData: Data
    
    init(_ keyData: Data) {
        self.keyData = keyData
    }
    
    static func < (lhs: CBORMapKey, rhs: CBORMapKey) -> Bool {
        lhs.keyData.lexicographicallyPrecedes(rhs.keyData)
    }
}

extension CBORMapKey: CustomDebugStringConvertible {
    var debugDescription: String {
        "0x" + keyData.hex
    }
}

public struct CBORMap: Equatable {
    var dict: SortedDictionary<CBORMapKey, CBORMapValue>
    
    public init() {
        self.dict = .init()
    }
    
    public mutating func insert<K, V>(_ key: K, _ value: V) where K: IntoCBOR & EncodeCBOR, V: IntoCBOR {
        dict[CBORMapKey(key.encodeCBOR())] = CBORMapValue(key: key.intoCBOR(), value: value.intoCBOR())
    }
}

extension CBORMap: EncodeCBOR {
    public func encodeCBOR() -> Data {
        let pairs = self.dict.map { (key: CBORMapKey, value: CBORMapValue) in
            (key, value.value.encodeCBOR())
        }
        var buf = pairs.count.encodeVarInt(.Map)
        for pair in pairs {
            buf += pair.0.keyData
            buf += pair.1
        }
        return buf
    }
}

extension CBORMap: IntoCBOR {
    public func intoCBOR() -> CBOR {
        .Map(self)
    }
}

extension CBORMap: CustomDebugStringConvertible {
    public var debugDescription: String {
        dict.map { (k, v) in
            "\(k.debugDescription): (\(v.key.debugDescription), \(v.value.debugDescription))"
        }.joined(separator: ", ")
            .flanked("{", "}")
    }
}

extension CBORMap: CustomStringConvertible {
    public var description: String {
        dict.map { (k, v) in
            "\(v.key): \(v.value)"
        }.joined(separator: ", ")
            .flanked("{", "}")
    }
}