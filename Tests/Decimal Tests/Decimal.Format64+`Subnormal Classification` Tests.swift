import Testing

@testable import Decimal

extension Decimal.Format64 {
    @Suite struct `Decimal64 classification distinguishes zero normal and subnormal values` {
        @Suite struct `No Decimal64 subnormal classification unit cases are defined` {}
        @Suite struct `Decimal64 classification follows coefficient and quantum exponent boundaries` {}
        @Suite struct `No Decimal64 subnormal classification integration cases are defined` {}
    }
}

extension Decimal.Format64.`Decimal64 classification distinguishes zero normal and subnormal values`.`Decimal64 classification follows coefficient and quantum exponent boundaries` {

    @Test func `The normal coefficient threshold remains normal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
        #expect(!value.test.subnormal)
    }

    @Test func `Reduced coefficients classify as subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 999_999_999_999_999
        )
        #expect(value.classification == .subnormal)
        #expect(value.test.subnormal)
    }

    @Test func `A unit coefficient is subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `The normal coefficient threshold remains normal above the minimum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .positive,
            exponent: Decimal.Format64.minExponent + 1,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
    }
}
