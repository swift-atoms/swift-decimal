import Rounding


extension Decimals {

    struct Wide: Sendable, Hashable {

        var high: UInt128

        var low: UInt128
    }
}

extension Decimals.Wide {

    init(_ value: UInt128) {
        self.init(high: 0, low: value)
    }
}

extension Decimals.Wide: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.high != rhs.high { return lhs.high < rhs.high }
        return lhs.low < rhs.low
    }
}

extension Decimals.Wide {
    var isZero: Bool { high == 0 && low == 0 }
}

extension Decimals.Wide {

    func multipliedBy10() -> Self {
        let (carry, newLow) = low.multipliedFullWidth(by: 10)
        let (highTimesTen, highOverflow) = high.multipliedReportingOverflow(by: 10)
        let (newHigh, carryOverflow) = highTimesTen.addingReportingOverflow(carry)
        precondition(
            !highOverflow && !carryOverflow,
            "Decimals.Wide multiplication overflowed 256 bits"
        )
        return Self(high: newHigh, low: newLow)
    }

    static func multiplied(_ value: Self, byPowerOf10 count: Int) -> Self {
        var result = value
        for _ in 0..<count {
            result = result.multipliedBy10()
        }
        return result
    }

    func adding(_ other: Self) -> Self {
        let (lowSum, lowCarry) = low.addingReportingOverflow(other.low)
        let (highSum, highOverflow) = high.addingReportingOverflow(other.high)
        let (highSum2, carryOverflow) = highSum.addingReportingOverflow(lowCarry ? 1 : 0)
        precondition(!highOverflow && !carryOverflow, "Decimals.Wide addition overflowed 256 bits")
        return Self(high: highSum2, low: lowSum)
    }

    func subtracting(_ other: Self) -> Self {
        precondition(self >= other, "Decimals.Wide subtraction requires self >= other")
        let (lowDiff, lowBorrow) = low.subtractingReportingOverflow(other.low)
        let (highDiff, _) = high.subtractingReportingOverflow(other.high)

        let (highDiff2, _) = highDiff.subtractingReportingOverflow(lowBorrow ? 1 : 0)
        return Self(high: highDiff2, low: lowDiff)
    }

    func dividedBy10() -> (quotient: Self, remainder: UInt128) {
        let (highQuotient, highRemainder) = high.quotientAndRemainder(dividingBy: 10)

        let (lowQuotient, lowRemainder) = UInt128(10).dividingFullWidth(
            (high: highRemainder, low: low)
        )
        return (Self(high: highQuotient, low: lowQuotient), lowRemainder)
    }

    func divided(by divisor: UInt128) -> (quotient: Self, remainder: UInt128) {
        let (highQuotient, highRemainder) = high.quotientAndRemainder(dividingBy: divisor)
        let (lowQuotient, remainder) = divisor.dividingFullWidth((high: highRemainder, low: low))
        return (Self(high: highQuotient, low: lowQuotient), remainder)
    }

    func reduced(
        toFitBelowOrEqual limit: UInt128
    ) -> (coefficient: UInt128, shift: Int, sticky: Bool) {
        var value = self
        var shift = 0
        var sticky = false
        while value.high != 0 || value.low > limit {
            let (quotient, remainder) = value.dividedBy10()
            if remainder != 0 { sticky = true }
            value = quotient
            shift += 1
        }
        return (value.low, shift, sticky)
    }

    func reducedToFitUInt128() -> (coefficient: UInt128, shift: Int, sticky: Bool) {
        reduced(toFitBelowOrEqual: .max)
    }
}

extension Decimals.Wide {

    func squareRoot() -> UInt128 {
        guard !isZero else {
            return 0
        }
        let estimate = (Double(high) * 0x1p128 + Double(low)).squareRoot() * (1 + 0x1p-30)
        var root = estimate < 0x1p127 ? UInt128(estimate) + 1 : UInt128.max
        while true {
            let quotient = root.dividingFullWidth((high: high, low: low)).quotient
            let next = root / 2 + quotient / 2 + (root & quotient & 1)
            guard next < root else {
                break
            }
            root = next
        }
        while Self(root.multipliedFullWidth(by: root)) > self {
            root -= 1
        }
        while Self((root + 1).multipliedFullWidth(by: root + 1)) <= self {
            root += 1
        }
        return root
    }
}

extension Decimals.Wide {

    init(_ product: (high: UInt128, low: UInt128)) {
        self.init(high: product.high, low: product.low)
    }
}

extension Decimals.Wide {

    var digitCount: Int {
        var digits = 0
        var value = self
        while !value.isZero {
            value = value.dividedBy10().quotient
            digits += 1
        }
        return digits
    }

    /// Drops the lowest `count` decimal digits, reporting how the dropped part compares to half a unit of the
    /// last kept digit (`nil` when nothing nonzero was dropped). `sticky` marks a nonzero part below this value.
    func droppingDigits(
        _ count: Int,
        sticky: Bool
    ) -> (quotient: Self, fractionComparedToHalf: Order.Comparison?) {
        guard count > 0 else {
            return (self, sticky ? .less : nil)
        }
        var value = self
        var leading: UInt128 = 0
        var rest = sticky
        for _ in 0..<count {
            if value.isZero {
                rest = rest || leading != 0
                leading = 0
                continue
            }
            let (quotient, remainder) = value.dividedBy10()
            rest = rest || leading != 0
            leading = remainder
            value = quotient
        }
        let comparison: Order.Comparison? =
            if leading > 5 || (leading == 5 && rest) {
                .greater
            } else if leading == 5 {
                .equal
            } else if leading != 0 || rest {
                .less
            } else {
                nil
            }
        return (value, comparison)
    }
}

extension Decimals.Wide {

    /// The sum of two signed values `coefficient × 10^exponent`, exact or with a sticky part.
    ///
    /// When the exponents are too far apart for the aligned sum to fit, the operand with the smaller exponent is
    /// truncated and `sticky` marks the dropped part. The returned coefficient then has at least 75 digits, so
    /// rounding it to any decimal precision drops a digit and the sticky part only breaks ties. A subtraction
    /// with a sticky part borrows one unit, so the sticky part is always added.
    static func sum(
        _ a: (sign: FloatingPointSign, coefficient: Self, exponent: Decimal.Exponent),
        _ b: (sign: FloatingPointSign, coefficient: Self, exponent: Decimal.Exponent)
    ) -> (sign: FloatingPointSign, coefficient: Self, exponent: Decimal.Exponent, sticky: Bool) {
        let (high, low) = a.exponent >= b.exponent ? (a, b) : (b, a)
        let difference = (high.exponent - low.exponent).rawValue
        let room = Swift.max(76 - high.coefficient.digitCount, 0)
        let scale = Swift.min(difference, room)
        let scaled = multiplied(high.coefficient, byPowerOf10: scale)

        var lowPart = low.coefficient
        var sticky = false
        for _ in 0..<(difference - scale) {
            guard !lowPart.isZero else { break }
            let (quotient, remainder) = lowPart.dividedBy10()
            sticky = sticky || remainder != 0
            lowPart = quotient
        }
        let exponent = high.exponent - scale

        if high.sign == low.sign {
            return (high.sign, scaled.adding(lowPart), exponent, sticky)
        }
        if scaled >= lowPart {
            let difference = scaled.subtracting(lowPart)
            return (high.sign, sticky ? difference.subtracting(Self(1)) : difference, exponent, sticky)
        }
        return (low.sign, lowPart.subtracting(scaled), exponent, sticky)
    }
}
