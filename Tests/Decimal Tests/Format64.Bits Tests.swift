import Testing

@testable import Decimal

@Suite struct `Decimal64 bit representations preserve sign and special classifications` {
    @Test func `Decimal64 positive zero preserves its zero classification and sign`() {
        let zero = Decimal.Format64.zero()
        #expect(zero.test.zero)
        #expect(!zero.test.negative)
    }

    @Test func `Decimal64 negative zero preserves its zero classification and sign`() {
        let negZero = Decimal.Format64.zero(sign: .negative)
        #expect(negZero.test.zero)
        #expect(negZero.test.negative)
    }

    @Test func `Decimal64 positive infinity preserves its infinite classification and sign`() {
        let inf = Decimal.Format64.infinity()
        #expect(inf.test.infinite)
        #expect(!inf.test.negative)
    }

    @Test func `Decimal64 negative infinity preserves its infinite classification and sign`() {
        let negInf = Decimal.Format64.infinity(sign: .negative)
        #expect(negInf.test.infinite)
        #expect(negInf.test.negative)
    }

    @Test func `Decimal64 quiet NaN remains nonsignaling`() {
        let qnan = Decimal.Format64.nan()
        #expect(qnan.test.nan)
        #expect(!qnan.test.signaling)
    }

    @Test func `Decimal64 signaling NaN retains its signaling classification`() {
        let snan = Decimal.Format64.nan(kind: .signaling)
        #expect(snan.test.nan)
        #expect(snan.test.signaling)
    }

    @Test func `Decimal64 negation reverses the sign and restores zero after two applications`() {
        let pos = Decimal.Format64.zero()
        let neg = pos.negated
        #expect(neg.test.negative)
        #expect(neg.negated.test.zero)
        #expect(!neg.negated.test.negative)
    }
}
