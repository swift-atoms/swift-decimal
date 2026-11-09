extension Decimals.Rounding {

    /// A result fitted into a context: a finite coefficient and exponent, or infinity after overflow.
    enum Fit: Sendable, Hashable {

        case finite(coefficient: UInt128, exponent: Decimal.Exponent)

        case infinite
    }
}
