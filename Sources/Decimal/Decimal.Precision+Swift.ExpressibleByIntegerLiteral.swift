extension Decimal.Precision: Swift.ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: Int) {
        self.rawValue = value
    }
}
