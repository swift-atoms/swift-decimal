import Testing

@testable import Decimal

extension `Decimal.Format64 Tests` {
    @Suite struct `Decimal64 classification distinguishes zero normal and subnormal values` {
    }
}

extension `Decimal.Format64 Tests`.`Decimal64 classification distinguishes zero normal and subnormal values` {
    @Suite struct `No Decimal64 subnormal classification unit cases are defined` {}

    @Suite struct `Decimal64 classification follows coefficient and quantum exponent boundaries` {}

    @Suite struct `No Decimal64 subnormal classification integration cases are defined` {}
}

extension `Decimal.Format64 Tests`.`Decimal64 classification distinguishes zero normal and subnormal values`.`Decimal64 classification follows coefficient and quantum exponent boundaries` {

    @Test func `The normal coefficient threshold remains normal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .plus,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
        #expect(!value.test.subnormal)
    }

    @Test func `Reduced coefficients classify as subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .plus,
            exponent: Decimal.Format64.minExponent,
            coefficient: 999_999_999_999_999
        )
        #expect(value.classification == .subnormal)
        #expect(value.test.subnormal)
    }

    @Test func `A unit coefficient is subnormal at the minimum quantum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .plus,
            exponent: Decimal.Format64.minExponent,
            coefficient: 1
        )
        #expect(value.classification == .subnormal)
    }

    @Test func `The normal coefficient threshold remains normal above the minimum exponent`() {
        let value = Decimal.Format64.encode(
            sign: .plus,
            exponent: Decimal.Format64.minExponent + 1,
            coefficient: 1_000_000_000_000_000
        )
        #expect(value.classification == .normal)
    }
}

extension `Decimal.Format64 Tests` {
    @Suite struct `Non-canonical Classification` {

        @Test func `A coefficient above the maximum classifies as zero, as equality treats it`() {
            let value = Decimal.Format64(bits: 0x6000_0000_0000_0000 | (398 << 51) | 0x0007_FFFF_FFFF_FFFF)
            #expect(value.extractCoefficient() > Decimal.Format64.coefficientMax())
            #expect(value.classification == .zero)
            #expect(value.test.zero)
            #expect(value == .zero())
        }
    }
}
