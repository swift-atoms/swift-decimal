import Division
public import Rounding

extension Decimals {

    public enum Rounding {}
}

extension Decimals.Rounding {

    static func digitCount(_ coefficient: UInt64) -> Int {
        var digits = 0
        var temp = coefficient
        while temp > 0 {
            digits += 1
            temp /= 10
        }
        return digits
    }

    static func digitCount(_ coefficient: UInt128) -> Int {
        var digits = 0
        var temp = coefficient
        while temp > 0 {
            digits += 1
            temp /= 10
        }
        return digits
    }
}

extension Decimals.Rounding {

    public static func round(
        coefficient: UInt64,
        exponent: Decimal.Exponent,
        sign: FloatingPointSign,
        rounding: Rounding::Rounding,
        precision: Decimal.Precision,
        sticky: Bool = false
    ) -> (coefficient: UInt32, exponent: Decimal.Exponent, status: Decimal.Status) {
        let c = coefficient
        var e = exponent
        var status: Decimal.Status = .none

        var digits = 0
        var temp = c
        while temp > 0 {
            digits += 1
            temp /= 10
        }

        if digits <= precision.rawValue {
            return (UInt32(truncatingIfNeeded: c), e, sticky ? .inexact : status)
        }

        let roundDigits = digits - precision.rawValue

        var divisor: UInt64 = 1
        for _ in 0..<roundDigits {
            divisor *= 10
        }

        let quotient = c / divisor
        let remainder = c % divisor
        let halfDivisor = divisor / 2

        let remainderPositive = remainder > 0 || sticky
        let isAboveHalf = remainder > halfDivisor || (sticky && remainder == halfDivisor)
        let isExactHalf = remainder == halfDivisor && !sticky

        let comparison: Order.Comparison? =
            remainderPositive ? (isAboveHalf ? .greater : (isExactHalf ? .equal : .less)) : nil
        let roundUp =
            (try? rounding.incrementsMagnitude(
                isNegative: sign == .minus,
                integralPartIsOdd: quotient % 2 != 0,
                fractionComparedToHalf: comparison
            )) ?? false

        var result = quotient
        if roundUp {
            result += 1
        }

        if remainderPositive {
            status = .inexact
        }

        e += roundDigits

        if result > UInt64(Decimal.Format32.coefficientMax()) {
            result /= 10

            e += 1
        }

        return (UInt32(truncatingIfNeeded: result), e, status)
    }

    public static func round(
        coefficient: UInt128,
        exponent: Decimal.Exponent,
        sign: FloatingPointSign,
        rounding: Rounding::Rounding,
        precision: Decimal.Precision,
        sticky: Bool = false
    ) -> (coefficient: UInt64, exponent: Decimal.Exponent, status: Decimal.Status) {
        let c = coefficient
        var e = exponent
        var status: Decimal.Status = .none

        var digits = 0
        var temp = c
        while temp > 0 {
            digits += 1
            temp /= 10
        }

        if digits <= precision.rawValue {
            return (UInt64(truncatingIfNeeded: c), e, sticky ? .inexact : status)
        }

        let roundDigits = digits - precision.rawValue

        var divisor: UInt128 = 1
        for _ in 0..<roundDigits {
            divisor *= 10
        }

        let quotient = c / divisor
        let remainder = c % divisor
        let halfDivisor = divisor / 2

        let remainderPositive = remainder > 0 || sticky
        let isAboveHalf = remainder > halfDivisor || (sticky && remainder == halfDivisor)
        let isExactHalf = remainder == halfDivisor && !sticky

        let comparison: Order.Comparison? =
            remainderPositive ? (isAboveHalf ? .greater : (isExactHalf ? .equal : .less)) : nil
        let roundUp =
            (try? rounding.incrementsMagnitude(
                isNegative: sign == .minus,
                integralPartIsOdd: quotient % 2 != 0,
                fractionComparedToHalf: comparison
            )) ?? false

        var result = quotient
        if roundUp {
            result += 1
        }

        if remainderPositive {
            status = .inexact
        }

        e += roundDigits

        if result > UInt128(Decimal.Format64.coefficientMax()) {
            result /= 10

            e += 1
        }

        return (UInt64(truncatingIfNeeded: result), e, status)
    }

    public static func round128(
        coefficient: UInt128,
        exponent: Decimal.Exponent,
        sign: FloatingPointSign,
        rounding: Rounding::Rounding,
        precision: Decimal.Precision,
        sticky: Bool = false
    ) -> (coefficient: UInt128, exponent: Decimal.Exponent, status: Decimal.Status) {
        let c = coefficient
        var e = exponent
        var status: Decimal.Status = .none

        var digits = 0
        var temp = c
        while temp > 0 {
            digits += 1
            temp /= 10
        }

        if digits <= precision.rawValue {
            return (c, e, sticky ? .inexact : status)
        }

        let roundDigits = digits - precision.rawValue

        var divisor: UInt128 = 1
        for _ in 0..<roundDigits {
            divisor *= 10
        }

        let quotient = c / divisor
        let remainder = c % divisor
        let halfDivisor = divisor / 2

        let remainderPositive = remainder > 0 || sticky
        let isAboveHalf = remainder > halfDivisor || (sticky && remainder == halfDivisor)
        let isExactHalf = remainder == halfDivisor && !sticky

        let comparison: Order.Comparison? =
            remainderPositive ? (isAboveHalf ? .greater : (isExactHalf ? .equal : .less)) : nil
        let roundUp =
            (try? rounding.incrementsMagnitude(
                isNegative: sign == .minus,
                integralPartIsOdd: quotient % 2 != 0,
                fractionComparedToHalf: comparison
            )) ?? false

        var result = quotient
        if roundUp {
            result += 1
        }

        if remainderPositive {
            status = .inexact
        }

        e += roundDigits

        if result > Decimal.Format128.coefficientMax() {
            result /= 10

            e += 1
        }

        return (result, e, status)
    }
}

extension Decimals.Rounding {

    static func dropping<Coefficient: FixedWidthInteger & UnsignedInteger>(
        _ digits: Int,
        from coefficient: Coefficient,
        sign: FloatingPointSign,
        rounding: Rounding::Rounding
    ) -> Coefficient {
        guard digits > 0 else {
            return coefficient
        }
        guard digits <= 37 else {
            let increments = try? rounding.incrementsMagnitude(
                isNegative: sign == .minus,
                integralPartIsOdd: false,
                fractionComparedToHalf: coefficient == 0 ? nil : .less
            )
            return increments == true ? 1 : 0
        }
        var divisor: Int128 = 1
        for _ in 0..<digits {
            divisor *= 10
        }
        let dividend = sign == .minus ? -Int128(coefficient) : Int128(coefficient)
        let quotient = (try? Division.rounded(dividend, by: divisor, rounding: rounding).quotient) ?? dividend / divisor
        return Coefficient(quotient.magnitude)
    }
}

extension Decimals.Rounding {

    /// Whether a result that overflows `context` becomes infinity rather than the greatest finite value.
    ///
    /// IEEE 754 §7.4: rounding to nearest and rounding away from zero overflow to infinity; rounding toward zero,
    /// or toward the infinity of the opposite sign, gives the greatest finite magnitude.
    static func overflowsToInfinity(sign: FloatingPointSign, rounding: Rounding::Rounding) -> Bool {
        (try? rounding.incrementsMagnitude(
            isNegative: sign == .minus,
            integralPartIsOdd: true,
            fractionComparedToHalf: .greater
        )) ?? true
    }

    /// The greatest finite coefficient at `precision`, `10^precision - 1`.
    static func greatestCoefficient(precision: Decimal.Precision) -> UInt128 {
        var power: UInt128 = 1
        for _ in 0..<precision.rawValue {
            power *= 10
        }
        return power - 1
    }

    /// Rounds the exact value `coefficient × 10^exponent` (plus a nonzero part below it when `sticky`) into
    /// `context`, with gradual underflow and IEEE 754 overflow.
    ///
    /// The coefficient is rounded to `context.precision` digits. An exponent that would fall below
    /// `context.minExponent` rounds the coefficient further, to a subnormal or zero, instead of flushing it to
    /// zero. Underflow is raised when the exact result is tiny (detected before rounding, IEEE 754 §7.5) and
    /// inexact. An exponent above `context.maxExponent` overflows to infinity or to the greatest finite value,
    /// as `context.rounding` decides.
    static func fit(
        coefficient: Decimals.Wide,
        exponent: Decimal.Exponent,
        sign: FloatingPointSign,
        sticky: Bool = false,
        context: Decimal.Context
    ) -> (fit: Fit, status: Decimal.Status) {
        let precision = context.precision.rawValue
        guard !coefficient.isZero || sticky else {
            let clamped = Swift.min(Swift.max(exponent, context.minExponent), context.maxExponent)
            return (.finite(coefficient: 0, exponent: clamped), .none)
        }

        let digits = Swift.max(coefficient.digitCount, 1)
        let leastNormalAdjusted = context.minExponent.rawValue + precision - 1
        let tiny = exponent.rawValue + digits - 1 < leastNormalAdjusted
        let drop = Swift.max(digits - precision, context.minExponent.rawValue - exponent.rawValue, 0)

        let (quotient, comparison) = coefficient.droppingDigits(drop, sticky: sticky)
        var result = quotient
        var resultExponent = exponent + drop
        let roundUp =
            (try? context.rounding.incrementsMagnitude(
                isNegative: sign == .minus,
                integralPartIsOdd: quotient.low & 1 == 1,
                fractionComparedToHalf: comparison
            )) ?? false
        if roundUp {
            result = result.adding(Decimals.Wide(1))
            if result > Decimals.Wide(greatestCoefficient(precision: context.precision)) {
                result = result.dividedBy10().quotient
                resultExponent += 1
            }
        }

        var status: Decimal.Status = comparison == nil ? .none : .inexact
        if resultExponent > context.maxExponent {
            status.formUnion([.overflow, .inexact])
            guard overflowsToInfinity(sign: sign, rounding: context.rounding) else {
                return (
                    .finite(
                        coefficient: greatestCoefficient(precision: context.precision),
                        exponent: context.maxExponent
                    ),
                    status
                )
            }
            return (.infinite, status)
        }
        if tiny, status.contains(.inexact) {
            status.formUnion(.underflow)
        }
        return (.finite(coefficient: result.low, exponent: resultExponent), status)
    }
}
