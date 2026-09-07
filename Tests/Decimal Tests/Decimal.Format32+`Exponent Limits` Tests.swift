import Testing

@testable import Decimal

extension Decimal.Format32 {
    @Suite struct `Decimal32 quantum exponents respect encoding bounds` {
        @Suite struct `No Decimal32 exponent bounds unit cases are defined` {}
        @Suite struct `Decimal32 quantum exponent limits govern normalization and round trips` {}
        @Suite struct `No Decimal32 exponent bounds integration cases are defined` {}
    }
}

extension Decimal.Format32.`Decimal32 quantum exponents respect encoding bounds`.`Decimal32 quantum exponent limits govern normalization and round trips` {

    @Test func `Published exponent limits match the quantum encoding bounds`() {
        #expect(Decimal.Format32.maxExponent == Decimal.Exponent(90))
        #expect(Decimal.Format32.minExponent == Decimal.Exponent(-101))
        #expect(Decimal.Exponent.Format32.scientificMax == Decimal.Exponent(96))
        #expect(Decimal.Exponent.Format32.scientificMin == Decimal.Exponent(-95))
    }

    @Test func `Decimal32 values round trip at the maximum quantum exponent`() {
        let exponent = Decimal.Exponent(90)
        let coefficient: UInt32 = 1234
        let encoded = Decimal.Format32.encode(
            sign: .positive,
            exponent: exponent,
            coefficient: coefficient
        )

        #expect(encoded.extractExponent() == exponent)
        #expect(exponent <= Decimal.Format32.maxExponent)
        #expect(Decimal.Exponent(91) > Decimal.Format32.maxExponent)
    }
}
