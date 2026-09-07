import Testing

@testable import Decimal

extension Decimal.Format32 {
    @Suite struct `Decimal32 classification distinguishes zero normal and subnormal values` {
        @Suite struct `No Decimal32 subnormal classification unit cases are defined` {}
        @Suite struct `Decimal32 classification follows coefficient and quantum exponent boundaries` {}
        @Suite struct `No Decimal32 subnormal classification integration cases are defined` {}
    }
}

extension Decimal.Format32.`Decimal32 classification distinguishes zero normal and subnormal values`.`Decimal32 classification follows coefficient and quantum exponent boundaries` {

    @Test func `The normal coefficient threshold remains normal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1_000_000
        )
        #expect(value.classification == .normal)
    }

    @Test func `Reduced coefficients classify as subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 999_999
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `A unit coefficient is subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `A unit coefficient remains subnormal one exponent step above the minimum`() {
        let value = Decimal.Format32.encode(
            sign: .positive,
            exponent: Decimal.Format32.minExponent + 1,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }
}
