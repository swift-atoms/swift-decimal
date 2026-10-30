extension Decimal.Format64: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        let sign: FloatingPointSign = value < 0 ? .minus : .plus
        let context = Decimal.Context.format64
        let (coefficient, exponent, _) = Decimals.Rounding.round(
            coefficient: UInt128(value.magnitude),
            exponent: Decimal.Exponent(0),
            sign: sign,
            rounding: context.rounding,
            precision: context.precision
        )
        self = .encode(sign: sign, exponent: exponent, coefficient: coefficient)
    }
}

extension Decimal.Format64: AdditiveArithmetic {
    public static var zero: Self { .zero() }

    public static func + (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs).value
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs.negated).value
    }
}

extension Decimal.Format64: Swift::Numeric {
    public typealias Magnitude = Self

    public var magnitude: Magnitude {
        sign == .minus ? negated : self
    }

    public init?<T: BinaryInteger>(exactly source: T) {
        guard let int64 = Int64(exactly: source) else {
            return nil
        }
        self.init(int64)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        lhs.operation.multiply(rhs).value
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

extension Decimal.Format64: SignedNumeric {
    public mutating func negate() {
        self = negated
    }

    public static prefix func - (value: Self) -> Self {
        value.negated
    }
}

extension Decimal.Format32: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int32) {
        self.init(rounding: value)
    }
}

extension Decimal.Format32: AdditiveArithmetic {
    public static var zero: Self { .zero() }

    public static func + (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs).value
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs.negated).value
    }
}

extension Decimal.Format32: Swift::Numeric {
    public typealias Magnitude = Self

    public var magnitude: Magnitude {
        sign == .minus ? negated : self
    }

    public init?<T: BinaryInteger>(exactly source: T) {
        guard let int32 = Int32(exactly: source) else {
            return nil
        }
        self.init(int32)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        lhs.operation.multiply(rhs).value
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

extension Decimal.Format32: SignedNumeric {
    public mutating func negate() {
        self = negated
    }

    public static prefix func - (value: Self) -> Self {
        value.negated
    }
}

extension Decimal.Format128: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self.init(rounding: value)
    }
}

extension Decimal.Format128: AdditiveArithmetic {
    public static var zero: Self { .zero() }

    public static func + (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs).value
    }

    public static func - (lhs: Self, rhs: Self) -> Self {
        lhs.operation.add(rhs.negated).value
    }
}

extension Decimal.Format128: Swift::Numeric {
    public typealias Magnitude = Self

    public var magnitude: Magnitude {
        sign == .minus ? negated : self
    }

    public init?<T: BinaryInteger>(exactly source: T) {
        guard let int64 = Int64(exactly: source) else {
            return nil
        }
        self.init(integerLiteral: int64)
    }

    public static func * (lhs: Self, rhs: Self) -> Self {
        lhs.operation.multiply(rhs).value
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
}

extension Decimal.Format128: SignedNumeric {
    public mutating func negate() {
        self = negated
    }

    public static prefix func - (value: Self) -> Self {
        value.negated
    }
}
