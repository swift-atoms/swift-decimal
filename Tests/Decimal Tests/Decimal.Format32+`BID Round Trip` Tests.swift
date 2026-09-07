import Testing

@testable import Decimal

extension Decimal.Format32 {
    @Suite struct `Decimal32 BID encoding preserves finite coefficients` {
        @Suite struct `No Decimal32 BID encoding unit cases are defined` {}
        @Suite struct `Decimal32 BID round trips preserve coefficients across encoding forms` {}
        @Suite struct `No Decimal32 BID encoding integration cases are defined` {}
    }
}

extension Decimal.Format32.`Decimal32 BID encoding preserves finite coefficients`.`Decimal32 BID round trips preserve coefficients across encoding forms` {

    @Test func `Finite form two encodings preserve their coefficient and normal classification`() {

        let exponent = Decimal.Exponent(49)
        let coefficient = Decimal.Format32.coefficientMax()
        let encoded = Decimal.Format32.encode(
            sign: .positive,
            exponent: exponent,
            coefficient: coefficient
        )

        #expect(encoded.classification == .normal)
        #expect(!encoded.test.infinite)
        #expect(!encoded.test.nan)
        #expect(encoded.extractExponent() == exponent)
        #expect(encoded.extractCoefficient() == coefficient)
    }

    @Test func `Decimal coefficients round trip across BID encoding forms`() {
        let exponent = Decimal.Exponent(13)
        let coefficients: [UInt32] = [
            (1 << 23) - 1,
            1 << 23,
            Decimal.Format32.coefficientMax(),
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format32.encode(
                sign: .positive,
                exponent: exponent,
                coefficient: coefficient
            )
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
