import Testing

@testable import Decimal

extension Decimal.Format64 {
    @Suite struct `Decimal64 BID encoding preserves finite coefficients` {
        @Suite struct `No Decimal64 BID encoding unit cases are defined` {}
        @Suite struct `Decimal64 BID round trips preserve coefficients across encoding forms` {}
        @Suite struct `No Decimal64 BID encoding integration cases are defined` {}
    }
}

extension Decimal.Format64.`Decimal64 BID encoding preserves finite coefficients`.`Decimal64 BID round trips preserve coefficients across encoding forms` {

    @Test func `Finite form two encodings preserve their coefficient and normal classification`() {

        let exponent = Decimal.Exponent(202)
        let coefficient = Decimal.Format64.coefficientMax()
        let encoded = Decimal.Format64.encode(
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
        let exponent = Decimal.Exponent(17)
        let coefficients: [UInt64] = [
            (1 << 53) - 1,
            1 << 53,
            Decimal.Format64.coefficientMax(),
        ]

        for coefficient in coefficients {
            let encoded = Decimal.Format64.encode(
                sign: .positive,
                exponent: exponent,
                coefficient: coefficient
            )
            #expect(encoded.extractExponent() == exponent)
            #expect(encoded.extractCoefficient() == coefficient)
        }
    }
}
