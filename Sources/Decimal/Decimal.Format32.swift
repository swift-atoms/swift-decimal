extension Decimal {

    public struct Format32: Sendable, Hashable {

        public var bits: UInt32

        public init(bits: UInt32) {
            self.bits = bits
        }
    }
}

extension Decimal.Format32: Decimal.Layout {

    public static var precision: Decimal.Precision { .format32 }

    public static var maxExponent: Decimal.Exponent { .Format32.max }

    public static var minExponent: Decimal.Exponent { .Format32.min }

    public static var bias: Int { Decimal.Exponent.Format32.bias }
}

extension Decimal.Format32 {

    public static func zero(sign: FloatingPointSign = .plus) -> Self {
        let signBit: UInt32 = sign == .minus ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x3200_0000)
    }

    public static func infinity(sign: FloatingPointSign = .plus) -> Self {
        let signBit: UInt32 = sign == .minus ? 0x8000_0000 : 0
        return Self(bits: signBit | 0x7800_0000)
    }

    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        let base: UInt32 = kind == .signaling ? 0x7E00_0000 : 0x7C00_0000
        let payloadMask: UInt32 = 0x000F_FFFF
        return Self(bits: base | UInt32(truncatingIfNeeded: payload.value) & payloadMask)
    }
}

extension Decimal.Format32 {

    public var classification: Decimal.Class {
        let combination = (bits >> 26) & 0x1F

        if combination >= 0x18 {
            if combination == 0x1E {
                return .infinite
            }
            if combination >= 0x1F {
                let isSignaling = (bits & 0x0200_0000) != 0
                return isSignaling ? .signaling : .quiet
            }
        }

        return Decimal.Class.classifyFinite(
            coefficient: extractCoefficient(),
            exponent: extractExponent(),
            scientificMin: Decimal.Exponent.Format32.scientificMin
        )
    }

    public var sign: FloatingPointSign {
        (bits & 0x8000_0000) != 0 ? .minus : .plus
    }

    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000)
    }

    @inlinable
    public func extractExponent() -> Decimal.Exponent {

        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 28) & 0x1
            let g3 = (bits >> 27) & 0x1
            if g2 == 1, g3 == 1 {

                return Decimal.Exponent(0)
            }

            let biasedExponent = Int((bits >> 21) & 0xFF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        let biasedExponent = Int((bits >> 23) & 0xFF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    @inlinable
    public func extractCoefficient() -> UInt32 {
        let g0g1 = (bits >> 29) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 28) & 0x1
            let g3 = (bits >> 27) & 0x1
            if g2 == 1, g3 == 1 {

                return bits & 0x000F_FFFF
            }

            let lowBits = bits & 0x001F_FFFF
            return (8 << 20) | lowBits
        }

        return bits & 0x007F_FFFF
    }

    @inlinable
    public static func coefficientMax() -> UInt32 {

        9_999_999
    }

    @inlinable
    public static func encode(
        sign: FloatingPointSign,
        exponent: Decimal.Exponent,
        coefficient: UInt32
    ) -> Self {
        let signBit: UInt32 = sign == .minus ? 0x8000_0000 : 0
        let biasedExponent = UInt32(Int(exponent) + bias)

        guard coefficient < (1 << 23) else {

            let form2Marker: UInt32 = 0x6000_0000
            let lowCoeff = coefficient & 0x001F_FFFF
            return Self(bits: signBit | form2Marker | (biasedExponent << 21) | lowCoeff)
        }

        return Self(bits: signBit | (biasedExponent << 23) | coefficient)
    }

}

extension Decimal.Format32 {

    public init?(_ value: Int32) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: FloatingPointSign = value < 0 ? .minus : .plus
        var coefficient = value.magnitude
        var exponent = 0

        while coefficient > Self.coefficientMax() {
            guard coefficient % 10 == 0 else { return nil }
            coefficient /= 10
            exponent += 1
        }

        self = Self.encode(
            sign: sign,
            exponent: Decimal.Exponent(exponent),
            coefficient: coefficient
        )
    }

    public init?(_ value: UInt32) {
        if value == 0 {
            self = .zero()
            return
        }

        var coefficient = value
        var exponent = 0

        while coefficient > Self.coefficientMax() {
            guard coefficient % 10 == 0 else { return nil }
            coefficient /= 10
            exponent += 1
        }

        self = Self.encode(
            sign: .plus,
            exponent: Decimal.Exponent(exponent),
            coefficient: coefficient
        )
    }
}

extension Decimal.Format32 {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard !lhs.test.nan, !rhs.test.nan else {
            return false
        }
        guard !lhs.test.infinite, !rhs.test.infinite else {
            return lhs.test.infinite && rhs.test.infinite && lhs.sign == rhs.sign
        }
        let left = lhs.reduced
        let right = rhs.reduced
        guard left.coefficient != 0 || right.coefficient != 0 else {
            return true
        }
        return lhs.sign == rhs.sign && left.coefficient == right.coefficient && left.exponent == right.exponent
    }

    public func hash(into hasher: inout Hasher) {
        guard !test.nan else {
            hasher.combine(Decimal.Class.quiet)
            return
        }
        guard !test.infinite else {
            hasher.combine(Decimal.Class.infinite)
            hasher.combine(sign)
            return
        }
        let value = reduced
        guard value.coefficient != 0 else {
            hasher.combine(Decimal.Class.zero)
            return
        }
        hasher.combine(sign)
        hasher.combine(value.coefficient)
        hasher.combine(value.exponent)
    }

    @usableFromInline
    internal var reduced: (coefficient: UInt32, exponent: Int) {
        var coefficient = extractCoefficient()
        guard coefficient != 0, coefficient <= Self.coefficientMax() else {
            return (0, 0)
        }
        var exponent = Int(extractExponent())
        while coefficient % 10 == 0 {
            coefficient /= 10
            exponent += 1
        }
        return (coefficient, exponent)
    }
}
