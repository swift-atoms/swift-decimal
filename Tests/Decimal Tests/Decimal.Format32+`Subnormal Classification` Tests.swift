import Testing

@testable import Decimal

extension `Decimal.Format32 Tests` {
    @Suite struct `Decimal32 classification distinguishes zero normal and subnormal values` {
    }
}

extension `Decimal.Format32 Tests`.`Decimal32 classification distinguishes zero normal and subnormal values` {
    @Suite struct `No Decimal32 subnormal classification unit cases are defined` {}

    @Suite struct `Decimal32 classification follows coefficient and quantum exponent boundaries` {}

    @Suite struct `No Decimal32 subnormal classification integration cases are defined` {}
}

extension `Decimal.Format32 Tests`.`Decimal32 classification distinguishes zero normal and subnormal values`.`Decimal32 classification follows coefficient and quantum exponent boundaries` {

    @Test func `The normal coefficient threshold remains normal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .plus,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1_000_000
        )
        #expect(value.classification == .normal)
    }

    @Test func `Reduced coefficients classify as subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .plus,
            exponent: Decimal.Format32.minExponent,
            coefficient: 999_999
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `A unit coefficient is subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format32.encode(
            sign: .plus,
            exponent: Decimal.Format32.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `A unit coefficient remains subnormal one exponent step above the minimum`() {
        let value = Decimal.Format32.encode(
            sign: .plus,
            exponent: Decimal.Format32.minExponent + 1,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }
}

extension `Decimal.Format32 Tests` {
    @Suite struct `Non-canonical Classification` {

        @Test func `A coefficient above the maximum classifies as zero, as equality treats it`() {
            let value = Decimal.Format32(bits: 0x6000_0000 | (101 << 21) | 0x001F_FFFF)
            #expect(value.extractCoefficient() > Decimal.Format32.coefficientMax())
            #expect(value.classification == .zero)
            #expect(value.test.zero)
            #expect(value == .zero())
        }
    }
}
