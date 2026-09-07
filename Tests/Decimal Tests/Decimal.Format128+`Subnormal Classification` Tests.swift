import Testing

@testable import Decimal

extension Decimal.Format128 {
    @Suite struct `Decimal128 classification distinguishes zero normal and subnormal values` {
        @Suite struct `No Decimal128 subnormal classification unit cases are defined` {}
        @Suite struct `Decimal128 classification follows coefficient and quantum exponent boundaries` {}
        @Suite struct `No Decimal128 subnormal classification integration cases are defined` {}
    }
}

extension Decimal.Format128.`Decimal128 classification distinguishes zero normal and subnormal values`.`Decimal128 classification follows coefficient and quantum exponent boundaries` {

    @Test func `The normal coefficient threshold remains normal at the minimum quantum exponent`() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(1_000_000_000_000_000)

        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: coefficient
        )
        #expect(value.classification == .normal)
    }

    @Test func `Reduced coefficients classify as subnormal at the minimum quantum exponent`() {
        let coefficient = UInt128(1_000_000_000_000_000_000) * UInt128(100_000_000_000_000)

        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: coefficient
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `A unit coefficient is subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format128.encode(
            sign: .positive,
            exponent: Decimal.Format128.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `Decimal zero retains its zero classification`() {
        let value = Decimal.Format128.zero()
        #expect(value.classification == .zero)
        #expect(!value.test.subnormal)
    }
}
