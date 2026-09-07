import Testing

@testable import Decimal

extension Decimal.Format64 {
    @Suite struct `Decimal64 integer conversions preserve representable values` {
        @Suite struct `No Decimal64 integer conversion unit cases are defined` {}
        @Suite struct `Decimal64 integer conversions handle signed boundaries without trapping` {}
        @Suite struct `No Decimal64 integer conversion integration cases are defined` {}
    }
}

extension Decimal.Format64.`Decimal64 integer conversions preserve representable values`.`Decimal64 integer conversions handle signed boundaries without trapping` {

    @Test func `Decimal64 construction rejects an unrepresentable Int64 minimum`() {
        #expect(Decimal.Format64(Int64.min) == nil)
    }

    @Test func `Decimal64 construction rejects an unrepresentable UInt64 maximum`() {
        #expect(Decimal.Format64(UInt64.max) == nil)
    }

    @Test func `Decimal64 construction rejects an unrepresentable Int64 maximum`() {
        #expect(Decimal.Format64(Int64.max) == nil)
    }

    @Test func `Decimal64 construction normalizes trailing zeros of large integers`() {
        let original: Int64 = 1_000_000_000_000_000_000
        let value = Decimal.Format64(original)
        #expect(value != nil)
        #expect(value.flatMap { Int64(exactly: $0) } == original)
    }
}
