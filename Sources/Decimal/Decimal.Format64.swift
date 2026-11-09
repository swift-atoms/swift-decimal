extension Decimal {

    public struct Format64: Sendable, Hashable {

        public var bits: UInt64

        public init(bits: UInt64) {
            self.bits = bits
        }
    }
}

extension Decimal.Format64: Decimal.Layout {

    public static var precision: Decimal.Precision { .format64 }

    public static var maxExponent: Decimal.Exponent { .Format64.max }

    public static var minExponent: Decimal.Exponent { .Format64.min }

    public static var bias: Int { Decimal.Exponent.Format64.bias }
}

extension Decimal.Format64 {
    @usableFromInline
    internal static func canonical(zero sign: FloatingPointSign) -> Self {

        let signBit: UInt64 = sign == .minus ? 0x8000_0000_0000_0000 : 0
        return Self(bits: signBit | 0x31C0_0000_0000_0000)
    }

    @usableFromInline
    internal static func canonical(infinity sign: FloatingPointSign) -> Self {

        let signBit: UInt64 = sign == .minus ? 0x8000_0000_0000_0000 : 0
        return Self(bits: signBit | 0x7800_0000_0000_0000)
    }

    @usableFromInline
    internal static func canonical(nan kind: Decimal.NaN, payload: Decimal.Payload) -> Self {

        let base: UInt64 = kind == .signaling ? 0x7E00_0000_0000_0000 : 0x7C00_0000_0000_0000
        let payloadMask: UInt64 = 0x0000_FFFF_FFFF_FFFF
        return Self(bits: base | (payload.value & payloadMask))
    }

    public static func zero(sign: FloatingPointSign = .plus) -> Self {
        canonical(zero: sign)
    }

    public static func infinity(sign: FloatingPointSign = .plus) -> Self {
        canonical(infinity: sign)
    }

    public static func nan(kind: Decimal.NaN = .quiet, payload: Decimal.Payload = .none) -> Self {
        canonical(nan: kind, payload: payload)
    }
}

extension Decimal.Format64 {

    public var classification: Decimal.Class {

        let combination = (bits >> 58) & 0x1F

        if combination >= 0x18 {

            if combination == 0x1E {
                return .infinite
            }
            if combination >= 0x1F {

                let isSignaling = (bits & 0x0200_0000_0000_0000) != 0
                return isSignaling ? .signaling : .quiet
            }
        }

        let coefficient = extractCoefficient()
        return Decimal.Class.classifyFinite(
            coefficient: coefficient <= Self.coefficientMax() ? coefficient : 0,
            exponent: extractExponent(),
            scientificMin: Decimal.Exponent.Format64.scientificMin
        )
    }

    public var sign: FloatingPointSign {
        (bits & 0x8000_0000_0000_0000) != 0 ? .minus : .plus
    }

    public var negated: Self {
        Self(bits: bits ^ 0x8000_0000_0000_0000)
    }

    @inlinable
    public func extractExponent() -> Decimal.Exponent {

        let g0g1 = (bits >> 61) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 60) & 0x1
            let g3 = (bits >> 59) & 0x1
            if g2 == 1, g3 == 1 {

                return Decimal.Exponent(0)
            }

            let biasedExponent = Int((bits >> 51) & 0x3FF)
            return Decimal.Exponent(biasedExponent - Self.bias)
        }

        let biasedExponent = Int((bits >> 53) & 0x3FF)
        return Decimal.Exponent(biasedExponent - Self.bias)
    }

    @inlinable
    public func extractCoefficient() -> UInt64 {
        let g0g1 = (bits >> 61) & 0x3
        if g0g1 == 0x3 {

            let g2 = (bits >> 60) & 0x1
            let g3 = (bits >> 59) & 0x1
            if g2 == 1, g3 == 1 {

                return bits & 0x0003_FFFF_FFFF_FFFF
            }

            let lowBits = bits & 0x0007_FFFF_FFFF_FFFF
            return (8 << 50) | lowBits
        }

        return bits & 0x001F_FFFF_FFFF_FFFF
    }

    @inlinable
    public static func coefficientMax() -> UInt64 {

        9_999_999_999_999_999
    }

    @inlinable
    public static func encode(
        sign: FloatingPointSign,
        exponent: Decimal.Exponent,
        coefficient: UInt64
    ) -> Self {
        let signBit: UInt64 = sign == .minus ? 0x8000_0000_0000_0000 : 0
        let biasedExponent = UInt64(Int(exponent) + bias)

        guard coefficient < (1 << 53) else {

            let form2Marker: UInt64 = 0x6000_0000_0000_0000
            let lowCoeff = coefficient & 0x0007_FFFF_FFFF_FFFF
            return Self(bits: signBit | form2Marker | (biasedExponent << 51) | lowCoeff)
        }

        return Self(bits: signBit | (biasedExponent << 53) | coefficient)
    }

    @inlinable
    public static func normalize(
        coefficient: UInt64,
        exponent: Decimal.Exponent
    ) -> (coefficient: UInt64, exponent: Decimal.Exponent) {
        guard coefficient != 0 else {
            return (0, exponent)
        }

        var c = coefficient
        var e = exponent

        while c % 10 == 0, e < maxExponent {
            c /= 10
            e += 1
        }

        return (c, e)
    }

}

extension Decimal.Format64 {

    public init?(_ value: Int64) {
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

    public init?(_ value: UInt64) {
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

extension Decimal.Format64 {

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
    internal var reduced: (coefficient: UInt64, exponent: Int) {
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
