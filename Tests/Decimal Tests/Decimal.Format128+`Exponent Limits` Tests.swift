import Testing

@testable import Decimal

extension Decimal.Format128 {
    @Suite struct `Decimal128 quantum exponents respect encoding bounds` {
        @Suite struct `No Decimal128 exponent bounds unit cases are defined` {}
        @Suite struct `Decimal128 quantum exponent limits govern normalization and round trips` {}
        @Suite struct `No Decimal128 exponent bounds integration cases are defined` {}
    }
}

extension Decimal.Format128.`Decimal128 quantum exponents respect encoding bounds`.`Decimal128 quantum exponent limits govern normalization and round trips` {

    @Test func `Published exponent limits match the quantum encoding bounds`() {
        #expect(Decimal.Format128.maxExponent == Decimal.Exponent(6111))
        #expect(Decimal.Format128.minExponent == Decimal.Exponent(-6176))
        #expect(Decimal.Exponent.Format128.scientificMax == Decimal.Exponent(6144))
        #expect(Decimal.Exponent.Format128.scientificMin == Decimal.Exponent(-6143))
    }

    @Test func `The quantum maximum excludes exponents within the wider scientific range`() {
        #expect(Decimal.Exponent(6111) <= Decimal.Format128.maxExponent)
        #expect(Decimal.Exponent(6120) > Decimal.Format128.maxExponent)
    }
}
