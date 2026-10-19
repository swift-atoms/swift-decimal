extension Decimal.Format128 {

    public init(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: FloatingPointSign = value < 0 ? .minus : .plus

        self = Self.encode(sign: sign, exponent: 0, coefficient: UInt128(value.magnitude))
    }

    public init(_ value: UInt64) {
        if value == 0 {
            self = .zero()
            return
        }

        self = Self.encode(sign: .plus, exponent: 0, coefficient: UInt128(value))
    }
}
