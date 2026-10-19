extension Decimal.Format128 {

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
    internal var reduced: (coefficient: UInt128, exponent: Int) {
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
