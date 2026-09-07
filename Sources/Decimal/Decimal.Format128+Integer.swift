extension Decimal.Format128 {

    public init(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive

        self = Self.encode(sign: sign, exponent: 0, coefficient: UInt128(value.magnitude))
    }

    public init(_ value: UInt64) {
        if value == 0 {
            self = .zero()
            return
        }

        self = Self.encode(sign: .positive, exponent: 0, coefficient: UInt128(value))
    }
}
