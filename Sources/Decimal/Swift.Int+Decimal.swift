extension Swift.Int {

    @inlinable
    public init(_ precision: Decimal.Precision) {
        self = precision.rawValue
    }
}

extension Swift.Int {

    @inlinable
    public init(_ exponent: Decimal.Exponent) {
        self = exponent.rawValue
    }
}
