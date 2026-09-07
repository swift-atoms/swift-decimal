extension Decimal.Exponent: Swift.ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}
