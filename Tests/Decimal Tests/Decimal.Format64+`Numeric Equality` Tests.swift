import Testing

@testable import Decimal

@Suite struct `Decimal64 equality compares values, not encodings` {
    @Test func `members of one cohort are equal and hash alike`() {
        let one = Decimal.Format64.encode(sign: .plus, exponent: Decimal.Exponent(0), coefficient: 1)
        let onePointZeroZero = Decimal.Format64.encode(sign: .plus, exponent: Decimal.Exponent(-2), coefficient: 100)
        #expect(one.bits != onePointZeroZero.bits)
        #expect(one == onePointZeroZero)
        #expect(one.hashValue == onePointZeroZero.hashValue)
    }

    @Test func `different values are unequal`() {
        let one = Decimal.Format64.encode(sign: .plus, exponent: Decimal.Exponent(0), coefficient: 1)
        let ten = Decimal.Format64.encode(sign: .plus, exponent: Decimal.Exponent(1), coefficient: 1)
        let minusOne = Decimal.Format64.encode(sign: .minus, exponent: Decimal.Exponent(0), coefficient: 1)
        #expect(one != ten)
        #expect(one != minusOne)
    }

    @Test func `zeros of either sign and any exponent are equal`() {
        let zero = Decimal.Format64.zero()
        let negativeZero = Decimal.Format64.zero(sign: .minus)
        let scaledZero = Decimal.Format64.encode(sign: .plus, exponent: Decimal.Exponent(5), coefficient: 0)
        #expect(zero == negativeZero)
        #expect(zero == scaledZero)
        #expect(zero.hashValue == negativeZero.hashValue)
    }

    @Test func `NaN is unequal to everything, itself included`() {
        let nan = Decimal.Format64.nan()
        #expect(nan != nan)
        #expect(nan != Decimal.Format64.zero())
    }

    @Test func `infinities are equal only with the same sign`() {
        #expect(Decimal.Format64.infinity() == Decimal.Format64.infinity())
        #expect(Decimal.Format64.infinity() != Decimal.Format64.infinity(sign: .minus))
    }
}
