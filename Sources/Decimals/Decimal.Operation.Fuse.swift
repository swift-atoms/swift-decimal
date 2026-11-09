import Rounding

extension Decimal.Operation where Value == Decimal.Format64 {

    public func fuse(
        _ a: Value,
        _ b: Value,
        context: Decimal.Context = .format64
    ) -> Decimal.Outcome<Value> {
        let x = base
        let y = a
        let z = b

        if x.test.signaling || y.test.signaling || z.test.signaling {
            let payload: Decimal.Payload
            payload =
                if x.test.signaling {
                    Decimal.Payload(x.extractCoefficient())
                } else if y.test.signaling {
                    Decimal.Payload(y.extractCoefficient())
                } else {
                    Decimal.Payload(z.extractCoefficient())
                }
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if x.test.nan { return Decimal.Outcome(value: x, status: .none) }
        if y.test.nan { return Decimal.Outcome(value: y, status: .none) }
        if z.test.nan { return Decimal.Outcome(value: z, status: .none) }

        if (x.test.infinite && y.test.zero) || (x.test.zero && y.test.infinite) {
            return Decimal.Outcome(value: .nan(), status: .invalid)
        }

        let productSign: FloatingPointSign = (x.sign == y.sign) ? .plus : .minus

        if x.test.infinite || y.test.infinite {
            if z.test.infinite {

                if productSign != z.sign {
                    return Decimal.Outcome(value: .nan(), status: .invalid)
                }
            }
            return Decimal.Outcome(value: .infinity(sign: productSign), status: .none)
        }

        if z.test.infinite {
            return Decimal.Outcome(value: z, status: .none)
        }

        if x.test.zero || y.test.zero {
            if z.test.zero {
                let resultSign: FloatingPointSign =
                    (productSign == .minus && z.sign == .minus)
                    ? .minus : (context.rounding == .down ? .minus : .plus)
                return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
            }
            return Decimal.Outcome(value: z, status: .none)
        }

        let coeffX = UInt128(x.extractCoefficient())
        let coeffY = UInt128(y.extractCoefficient())
        let product = Decimals.Wide(coeffX * coeffY)
        let productExp = x.extractExponent() + y.extractExponent()

        if z.test.zero {
            return Value.fitted(
                sign: productSign,
                coefficient: product,
                exponent: productExp,
                context: context
            )
        }

        let sum = Decimals.Wide.sum(
            (productSign, product, productExp),
            (z.sign, Decimals.Wide(UInt128(z.extractCoefficient())), z.extractExponent())
        )

        if sum.coefficient.isZero {
            let zeroSign: FloatingPointSign = context.rounding == .down ? .minus : .plus
            return Decimal.Outcome(value: .zero(sign: zeroSign), status: .none)
        }

        return Value.fitted(
            sign: sum.sign,
            coefficient: sum.coefficient,
            exponent: sum.exponent,
            sticky: sum.sticky,
            context: context
        )
    }

    public func fuse(
        _ a: Value,
        _ b: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try fuse(a, b, context: context).trapped(by: context.traps)
    }
}

extension Decimal.Operation where Value == Decimal.Format32 {

    public func fuse(
        _ a: Value,
        _ b: Value,
        context: Decimal.Context = .format32
    ) -> Decimal.Outcome<Value> {
        let x = base
        let y = a
        let z = b

        if x.test.signaling || y.test.signaling || z.test.signaling {
            let payload: Decimal.Payload
            payload =
                if x.test.signaling {
                    Decimal.Payload(UInt64(x.extractCoefficient()))
                } else if y.test.signaling {
                    Decimal.Payload(UInt64(y.extractCoefficient()))
                } else {
                    Decimal.Payload(UInt64(z.extractCoefficient()))
                }
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if x.test.nan { return Decimal.Outcome(value: x, status: .none) }
        if y.test.nan { return Decimal.Outcome(value: y, status: .none) }
        if z.test.nan { return Decimal.Outcome(value: z, status: .none) }

        if (x.test.infinite && y.test.zero) || (x.test.zero && y.test.infinite) {
            return Decimal.Outcome(value: .nan(), status: .invalid)
        }

        let productSign: FloatingPointSign = (x.sign == y.sign) ? .plus : .minus

        if x.test.infinite || y.test.infinite {
            if z.test.infinite {
                if productSign != z.sign {
                    return Decimal.Outcome(value: .nan(), status: .invalid)
                }
            }
            return Decimal.Outcome(value: .infinity(sign: productSign), status: .none)
        }

        if z.test.infinite {
            return Decimal.Outcome(value: z, status: .none)
        }

        if x.test.zero || y.test.zero {
            if z.test.zero {
                let resultSign: FloatingPointSign =
                    (productSign == .minus && z.sign == .minus)
                    ? .minus : (context.rounding == .down ? .minus : .plus)
                return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
            }
            return Decimal.Outcome(value: z, status: .none)
        }

        let coeffX = x.extractCoefficient()
        let coeffY = y.extractCoefficient()
        let product = Decimals.Wide(UInt128(coeffX) * UInt128(coeffY))
        let productExp = x.extractExponent() + y.extractExponent()

        if z.test.zero {
            return Value.fitted(
                sign: productSign,
                coefficient: product,
                exponent: productExp,
                context: context
            )
        }

        let sum = Decimals.Wide.sum(
            (productSign, product, productExp),
            (z.sign, Decimals.Wide(UInt128(z.extractCoefficient())), z.extractExponent())
        )

        if sum.coefficient.isZero {
            let zeroSign: FloatingPointSign = context.rounding == .down ? .minus : .plus
            return Decimal.Outcome(value: .zero(sign: zeroSign), status: .none)
        }

        return Value.fitted(
            sign: sum.sign,
            coefficient: sum.coefficient,
            exponent: sum.exponent,
            sticky: sum.sticky,
            context: context
        )
    }

    public func fuse(
        _ a: Value,
        _ b: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try fuse(a, b, context: context).trapped(by: context.traps)
    }
}

extension Decimal.Operation where Value == Decimal.Format128 {

    public func fuse(
        _ a: Value,
        _ b: Value,
        context: Decimal.Context = .format128
    ) -> Decimal.Outcome<Value> {
        let x = base
        let y = a
        let z = b

        if x.test.signaling || y.test.signaling || z.test.signaling {
            let payload: Decimal.Payload
            payload =
                if x.test.signaling {
                    Decimal.Payload(UInt64(truncatingIfNeeded: x.extractCoefficient()))
                } else if y.test.signaling {
                    Decimal.Payload(UInt64(truncatingIfNeeded: y.extractCoefficient()))
                } else {
                    Decimal.Payload(UInt64(truncatingIfNeeded: z.extractCoefficient()))
                }
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if x.test.nan { return Decimal.Outcome(value: x, status: .none) }
        if y.test.nan { return Decimal.Outcome(value: y, status: .none) }
        if z.test.nan { return Decimal.Outcome(value: z, status: .none) }

        if (x.test.infinite && y.test.zero) || (x.test.zero && y.test.infinite) {
            return Decimal.Outcome(value: .nan(), status: .invalid)
        }

        let productSign: FloatingPointSign = (x.sign == y.sign) ? .plus : .minus

        if x.test.infinite || y.test.infinite {
            if z.test.infinite {
                if productSign != z.sign {
                    return Decimal.Outcome(value: .nan(), status: .invalid)
                }
            }
            return Decimal.Outcome(value: .infinity(sign: productSign), status: .none)
        }

        if z.test.infinite {
            return Decimal.Outcome(value: z, status: .none)
        }

        if x.test.zero || y.test.zero {
            if z.test.zero {
                let resultSign: FloatingPointSign =
                    (productSign == .minus && z.sign == .minus)
                    ? .minus : (context.rounding == .down ? .minus : .plus)
                return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
            }
            return Decimal.Outcome(value: z, status: .none)
        }

        let coeffX = x.extractCoefficient()
        let coeffY = y.extractCoefficient()
        let product = Decimals.Wide(coeffX.multipliedFullWidth(by: coeffY))
        let productExp = x.extractExponent() + y.extractExponent()

        if z.test.zero {
            return Value.fitted(
                sign: productSign,
                coefficient: product,
                exponent: productExp,
                context: context
            )
        }

        let sum = Decimals.Wide.sum(
            (productSign, product, productExp),
            (z.sign, Decimals.Wide(z.extractCoefficient()), z.extractExponent())
        )

        if sum.coefficient.isZero {
            let zeroSign: FloatingPointSign = context.rounding == .down ? .minus : .plus
            return Decimal.Outcome(value: .zero(sign: zeroSign), status: .none)
        }

        return Value.fitted(
            sign: sum.sign,
            coefficient: sum.coefficient,
            exponent: sum.exponent,
            sticky: sum.sticky,
            context: context
        )
    }

    public func fuse(
        _ a: Value,
        _ b: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try fuse(a, b, context: context).trapped(by: context.traps)
    }
}
