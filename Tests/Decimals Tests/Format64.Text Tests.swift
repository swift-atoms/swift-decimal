import Rounding
import Testing

@testable import Decimals

extension Decimal.Format64.Test {
    @Suite struct Text {

        @Test func `parse Integer`() throws {
            let value = try Decimal.Format64.text([UInt8]("123".utf8))
            #expect(Int64(exactly: value) == 123)
        }

        @Test func `parse Negative Integer`() throws {
            let value = try Decimal.Format64.text([UInt8]("-456".utf8))
            #expect(Int64(exactly: value) == -456)
        }

        @Test func `parse Decimal`() throws {
            let value = try Decimal.Format64.text([UInt8]("12.5".utf8))

            let doubled = value + value
            #expect(Int64(exactly: doubled) == 25)
        }

        @Test func `parse Scientific`() throws {
            let value = try Decimal.Format64.text([UInt8]("1.5E2".utf8))
            #expect(Int64(exactly: value) == 150)
        }

        @Test func `parse Infinity`() throws {
            let inf = try Decimal.Format64.text([UInt8]("Infinity".utf8))
            #expect(inf.test.infinite)
            #expect(!inf.test.negative)
        }

        @Test func `parse Negative Infinity`() throws {
            let negInf = try Decimal.Format64.text([UInt8]("-Inf".utf8))
            #expect(negInf.test.infinite)
            #expect(negInf.test.negative)
        }

        @Test func `parse NaN`() throws {
            let nan = try Decimal.Format64.text([UInt8]("NaN".utf8))
            #expect(nan.test.nan)
        }

        @Test func `parse Zero`() throws {
            let zero = try Decimal.Format64.text([UInt8]("0".utf8))
            #expect(zero.test.zero)
        }

        @Test func `parse Empty`() {
            #expect(throws: Decimal._TextError.self) {
                _ = try Decimal.Format64.text([UInt8]())
            }
        }

        @Test func `parse exponent digit overflow resolves to high instead of trapping`() {

            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format64.text([UInt8]("1E9999999999999999999999999".utf8))
            }
        }

        @Test func `parse exponent digit underflow resolves to low instead of trapping`() {
            #expect(throws: Decimal._TextError.low) {
                _ = try Decimal.Format64.text([UInt8]("1E-9999999999999999999999999".utf8))
            }
        }

        @Test func `parse NaN rejects trailing garbage`() {

            #expect(throws: Decimal._TextError.self) {
                _ = try Decimal.Format64.text([UInt8]("NaN123garbage".utf8))
            }
        }

        @Test func `parse NaN preserves sign`() throws {

            let value = try Decimal.Format64.text([UInt8]("-NaN".utf8))
            #expect(value.test.nan)
            #expect(value.test.negative)
        }

        @Test func `parse rounds over precision coefficient instead of corrupting encoding`() throws {

            let value = try Decimal.Format64.text([UInt8]("12345678901234567".utf8))
            let expected = Decimal.Format64.encode(
                sign: .plus,
                exponent: Decimal.Exponent(1),
                coefficient: 1_234_567_890_123_457
            )
            #expect(value == expected)
        }

        @Test func `render Integer`() {
            let value: Decimal.Format64 = 42
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "42")
        }

        @Test func `render Negative`() {
            let value: Decimal.Format64 = -123
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "-123")
        }

        @Test func `render Zero`() {
            let value: Decimal.Format64 = 0
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "0")
        }

        @Test func `render Infinity`() {
            let value = Decimal.Format64.infinity()
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "Infinity")
        }

        @Test func `render Negative Infinity`() {
            let value = Decimal.Format64.infinity(sign: .minus)
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "-Infinity")
        }

        @Test func `render NaN`() {
            let value = Decimal.Format64.nan()
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer)
            #expect(String(decoding: buffer, as: UTF8.self) == "NaN")
        }

        @Test
        func
            `render appending does not overflow scratch buffer for large positive exponent plain style`()
        {

            let value = Decimal.Format64.encode(
                sign: .plus,
                exponent: Decimal.Exponent(369),
                coefficient: 1
            )
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .plain)
            let rendered = String(decoding: buffer, as: UTF8.self)
            #expect(rendered.hasPrefix("1"))
            #expect(rendered.count == 1 + 369)
        }

        @Test
        func
            `render appending does not overflow scratch buffer for min negative exponent plain style`()
        {

            let value = Decimal.Format64.encode(
                sign: .minus,
                exponent: Decimal.Exponent.Format64.min,
                coefficient: 1
            )
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .plain)
            let rendered = String(decoding: buffer, as: UTF8.self)
            #expect(rendered.hasPrefix("-0."))
        }

        @Test func `render into traps when buffer is smaller than required capacity`() {
            let value = Decimal.Format64.encode(
                sign: .plus,
                exponent: Decimal.Exponent(369),
                coefficient: 1
            )
            let needed = value.text.requiredCapacity(style: .plain)
            #expect(needed > 64)
        }

        @Test
        func
            `render appending scientific and engineering styles stay within bounds at large exponent`()
        {

            let value = Decimal.Format64.encode(
                sign: .minus,
                exponent: Decimal.Exponent(369),
                coefficient: 9_007_199_254_740_991
            )
            var scientific: [UInt8] = []
            value.text.render(appending: &scientific, style: .scientific)
            #expect(String(decoding: scientific, as: UTF8.self).hasPrefix("-9.007199254740991E"))

            var engineering: [UInt8] = []
            value.text.render(appending: &engineering, style: .engineering)
            #expect(String(decoding: engineering, as: UTF8.self).hasPrefix("-"))
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
                let value = Decimal.Format64.encode(
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
            let value = Decimal.Format64.encode(sign: .minus, exponent: Decimal.Exponent(-2), coefficient: 5)
            var buffer: [UInt8] = []
            value.text.render(appending: &buffer, style: .engineering)
            #expect(String(decoding: buffer, as: UTF8.self) == "-50E-3")
        }

        @Test func `parse rounds using digits past the kept coefficient digits`() throws {
            let value = try Decimal.Format64.text([UInt8]("123456789012345650001".utf8))
            let expected = Decimal.Format64.encode(
                sign: .plus,
                exponent: Decimal.Exponent(5),
                coefficient: 1234567890123457
            )
            #expect(value == expected)
        }

        @Test func `parse rounds toward positive infinity when only dropped digits are nonzero`() throws {
            var context = Decimal.Context.format64
            context.rounding = .up
            let value = try Decimal.Format64.text([UInt8]("1.00000000000000000000001".utf8), context: context)
            let expected = Decimal.Format64.encode(
                sign: .plus,
                exponent: Decimal.Exponent(-15),
                coefficient: 1000000000000001
            )
            #expect(value == expected)
        }

        @Test func `parse zero with an exponent above the range throws high`() {
            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format64.text([UInt8]("0E+999999".utf8))
            }
            #expect(throws: Decimal._TextError.high) {
                _ = try Decimal.Format64.text([UInt8]("-0.000E+999999".utf8))
            }
        }

        @Test func `parse zero with an exponent below the range throws low`() {
            #expect(throws: Decimal._TextError.low) {
                _ = try Decimal.Format64.text([UInt8]("0E-999999".utf8))
            }
        }

        @Test func `parse zero within the range still parses`() throws {
            let value = try Decimal.Format64.text([UInt8]("-0.000E+5".utf8))
            #expect(value.test.zero)
            #expect(value.test.negative)
        }
    }
}
