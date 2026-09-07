import Testing

@testable import Decimal

extension Decimal.Format128 {
    @Suite struct `Decimal128 integer conversions preserve representable values` {
        @Suite struct `No Decimal128 integer conversion unit cases are defined` {}
        @Suite struct `Decimal128 integer conversions handle signed boundaries without trapping` {}
        @Suite struct `No Decimal128 integer conversion integration cases are defined` {}
    }
}

extension Decimal.Format128.`Decimal128 integer conversions preserve representable values`.`Decimal128 integer conversions handle signed boundaries without trapping` {

    @Test func `Decimal128 conversion round trips Int64 minimum`() {
        let value = Decimal.Format128(Int64.min)
        #expect(Int64(exactly: value) == Int64.min)
    }

    @Test func `Directly encoded negative coefficients recover Int64 minimum`() {
        let magnitude = UInt128(UInt64(Int64.max)) + 1
        let encoded = Decimal.Format128.encode(sign: .negative, exponent: 0, coefficient: magnitude)
        #expect(Int64(exactly: encoded) == Int64.min)
    }
}
