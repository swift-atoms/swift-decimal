import Testing

@testable import Decimal

extension Decimal.Format64 {
    @Suite struct `Decimal64 quantum exponents respect encoding bounds` {
        @Suite struct `No Decimal64 exponent bounds unit cases are defined` {}
        @Suite struct `Decimal64 quantum exponent limits govern normalization and round trips` {}
        @Suite struct `No Decimal64 exponent bounds integration cases are defined` {}
    }
}

extension Decimal.Format64.`Decimal64 quantum exponents respect encoding bounds`.`Decimal64 quantum exponent limits govern normalization and round trips` {

    @Test func `Published exponent limits match the quantum encoding bounds`() {
        #expect(Decimal.Format64.maxExponent == Decimal.Exponent(369))
        #expect(Decimal.Format64.minExponent == Decimal.Exponent(-398))
        #expect(Decimal.Exponent.Format64.scientificMax == Decimal.Exponent(384))
        #expect(Decimal.Exponent.Format64.scientificMin == Decimal.Exponent(-383))
    }

    @Test func `Decimal64 normalization stops at the maximum quantum exponent`() {
        let coefficient: UInt64 = 10_000_000_000_000_000_000
        let exponent = Decimal.Exponent(365)

        let (normalizedCoefficient, normalizedExponent) = Decimal.Format64.normalize(
            coefficient: coefficient,
            exponent: exponent
        )

        #expect(normalizedExponent == Decimal.Exponent(369))
        #expect(normalizedCoefficient == 1_000_000_000_000_000)
    }
}
