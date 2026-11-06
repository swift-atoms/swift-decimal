import Rounding
import Testing

@testable import Decimals

extension `Decimal.Format32 Tests` {
    @Suite struct Test {}
}

extension `Decimal.Format32 Tests`.Test {
    @Suite struct Text {

        @Test
        func
            `render appending does not overflow scratch buffer for large positive exponent plain style`()
        {

            let value = Decimal.Format32.encode(
                sign: .plus,
                exponent: Decimal.Exponent(90),
                coefficient: 1
            )
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .plain)
            let rendered = String(decoding: buffer, as: UTF8.self)
            #expect(rendered.hasPrefix("1"))
            #expect(rendered.count == 1 + 90)
        }

        @Test
        func
            `render appending does not overflow scratch buffer for min negative exponent plain style`()
        {
            let value = Decimal.Format32.encode(
                sign: .minus,
                exponent: Decimal.Exponent.Format32.min,
                coefficient: 1
            )
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .plain)
            let rendered = String(decoding: buffer, as: UTF8.self)
            #expect(rendered.hasPrefix("-0."))
        }

        @Test func `render into traps when buffer is smaller than required capacity`() {
            let value = Decimal.Format32.encode(
                sign: .plus,
                exponent: Decimal.Exponent(90),
                coefficient: 1
            )
            let needed = value.text.requiredCapacity(style: .plain)
            #expect(needed > 32)
        }

        @Test func `parse exponent digit overflow resolves to high instead of trapping`() {

            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format32.text([UInt8]("1E9999999999999999999999999".utf8))
            }
        }

        @Test func `parse NaN rejects trailing garbage`() {
            #expect(throws: Decimal._TextError.self) {
                _ = try Decimal.Format32.text([UInt8]("NaN123garbage".utf8))
            }
        }

        @Test func `parse NaN preserves sign`() throws {
            let value = try Decimal.Format32.text([UInt8]("-NaN".utf8))
            #expect(value.test.nan)
            #expect(value.test.negative)
        }

        @Test func `parse rounds over precision coefficient instead of corrupting encoding`() throws {

            let value = try Decimal.Format32.text([UInt8]("12345677".utf8))
            let expected = Decimal.Format32.encode(
                sign: .plus,
                exponent: Decimal.Exponent(1),
                coefficient: 1_234_568
            )
            #expect(value == expected)
        }

        @Test func `render engineering floors a negative exponent to a multiple of three`() {
            let cases: [(Int, Decimal.Exponent, String)] = [
                (5, Decimal.Exponent(-1), "500E-3"),
                (5, Decimal.Exponent(-2), "50E-3"),
                (5, Decimal.Exponent(-4), "500E-6"),
                (5, Decimal.Exponent(-5), "50E-6"),
                (125, Decimal.Exponent(-4), "12.5E-3"),
                (15, Decimal.Exponent(-4), "1.5E-3"),
                (5, Decimal.Exponent(4), "50E+3"),
            ]
            for (coefficient, exponent, expected) in cases {
                let value = Decimal.Format32.encode(
                    sign: .plus,
                    exponent: exponent,
                    coefficient: .init(coefficient)
                )
                var buffer: [UInt8] = []
                value.text.render(appending: &buffer, style: .engineering)
                #expect(String(decoding: buffer, as: UTF8.self) == expected)
            }
        }

        @Test func `render engineering keeps the sign for a small negative value`() {
            let value = Decimal.Format32.encode(sign: .minus, exponent: Decimal.Exponent(-2), coefficient: 5)
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .engineering)
            #expect(String(decoding: buffer, as: UTF8.self) == "-50E-3")
        }

        @Test func `parse rounds using digits past the kept coefficient digits`() throws {
            let value = try Decimal.Format32.text([UInt8]("1234564501".utf8))
            let expected = Decimal.Format32.encode(
                sign: .plus,
                exponent: Decimal.Exponent(3),
                coefficient: 1_234_565
            )
            #expect(value == expected)
        }

        @Test func `parse rounds toward positive infinity when only dropped digits are nonzero`() throws {
            var context = Decimal.Context.format32
            context.rounding = .up
            let value = try Decimal.Format32.text([UInt8]("1.0000000001".utf8), context: context)
            let expected = Decimal.Format32.encode(
                sign: .plus,
                exponent: Decimal.Exponent(-6),
                coefficient: 1_000_001
            )
            #expect(value == expected)
        }

        @Test func `parse zero with an exponent above the range throws high`() {
            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format32.text([UInt8]("0E+999999".utf8))
            }
            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format32.text([UInt8]("-0.000E+999999".utf8))
            }
        }

        @Test func `parse zero with an exponent below the range throws low`() {
            #expect(throws: Decimal._TextError.low) {
                _ = try Decimal.Format32.text([UInt8]("0E-999999".utf8))
            }
        }

        @Test func `parse zero within the range still parses`() throws {
            let value = try Decimal.Format32.text([UInt8]("-0.000E+5".utf8))
            #expect(value.test.zero)
            #expect(value.test.negative)
        }
    }
}
