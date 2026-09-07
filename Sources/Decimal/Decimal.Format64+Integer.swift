extension Decimal.Format64 {

    public init?(_ value: Int64) {
        if value == 0 {
            self = .zero()
            return
        }

        let sign: Decimal.Sign = value < 0 ? .negative : .positive

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
            sign: .positive,
            exponent: Decimal.Exponent(exponent),
            coefficient: coefficient
        )
    }
}
