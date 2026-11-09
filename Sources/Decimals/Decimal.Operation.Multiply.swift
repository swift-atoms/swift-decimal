extension Decimal.Operation where Value == Decimal.Format32 {
    public func multiply(
        _ other: Value,
        context: Decimal.Context = .format32
    ) -> Decimal.Outcome<Value> {
        let a = base
        let b = other

        let resultSign: FloatingPointSign = (a.sign == b.sign) ? .plus : .minus

        if a.test.signaling || b.test.signaling {
            let payload =
                a.test.signaling
                ? Decimal.Payload(UInt64(a.extractCoefficient()))
                : Decimal.Payload(UInt64(b.extractCoefficient()))
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if a.test.nan {
            return Decimal.Outcome(value: a, status: .none)
        }
        if b.test.nan {
            return Decimal.Outcome(value: b, status: .none)
        }

        if a.test.infinite {
            if b.test.zero {
                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }
        if b.test.infinite {
            if a.test.zero {
                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }

        if a.test.zero || b.test.zero {
            return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
        }

        let coeffA = UInt64(a.extractCoefficient())
        let coeffB = UInt64(b.extractCoefficient())
        let expA = a.extractExponent()
        let expB = b.extractExponent()

        return Value.fitted(
            sign: resultSign,
            coefficient: Decimals.Wide(UInt128(coeffA) * UInt128(coeffB)),
            exponent: expA + expB,
            context: context
        )
    }

    public func multiply(
        _ other: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try multiply(other, context: context).trapped(by: context.traps)
    }
}

extension Decimal.Operation where Value == Decimal.Format64 {
    public func multiply(
        _ other: Value,
        context: Decimal.Context = .format64
    ) -> Decimal.Outcome<Value> {
        let a = base
        let b = other

        let resultSign: FloatingPointSign = (a.sign == b.sign) ? .plus : .minus

        if a.test.signaling || b.test.signaling {
            let payload =
                a.test.signaling
                ? Decimal.Payload(a.extractCoefficient()) : Decimal.Payload(b.extractCoefficient())
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if a.test.nan {
            return Decimal.Outcome(value: a, status: .none)
        }
        if b.test.nan {
            return Decimal.Outcome(value: b, status: .none)
        }

        if a.test.infinite {
            if b.test.zero {

                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }
        if b.test.infinite {
            if a.test.zero {

                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }

        if a.test.zero || b.test.zero {
            return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
        }

        let coeffA = UInt128(a.extractCoefficient())
        let coeffB = UInt128(b.extractCoefficient())
        let expA = a.extractExponent()
        let expB = b.extractExponent()

        return Value.fitted(
            sign: resultSign,
            coefficient: Decimals.Wide(coeffA * coeffB),
            exponent: expA + expB,
            context: context
        )
    }

    public func multiply(
        _ other: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try multiply(other, context: context).trapped(by: context.traps)
    }
}

extension Decimal.Operation where Value == Decimal.Format128 {
    public func multiply(
        _ other: Value,
        context: Decimal.Context = .format128
    ) -> Decimal.Outcome<Value> {
        let a = base
        let b = other

        let resultSign: FloatingPointSign = (a.sign == b.sign) ? .plus : .minus

        if a.test.signaling || b.test.signaling {
            let payload =
                a.test.signaling
                ? Decimal.Payload(UInt64(truncatingIfNeeded: a.extractCoefficient()))
                : Decimal.Payload(UInt64(truncatingIfNeeded: b.extractCoefficient()))
            return Decimal.Outcome(value: .nan(kind: .quiet, payload: payload), status: .invalid)
        }

        if a.test.nan {
            return Decimal.Outcome(value: a, status: .none)
        }
        if b.test.nan {
            return Decimal.Outcome(value: b, status: .none)
        }

        if a.test.infinite {
            if b.test.zero {
                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }
        if b.test.infinite {
            if a.test.zero {
                return Decimal.Outcome(value: .nan(), status: .invalid)
            }
            return Decimal.Outcome(value: .infinity(sign: resultSign), status: .none)
        }

        if a.test.zero || b.test.zero {
            return Decimal.Outcome(value: .zero(sign: resultSign), status: .none)
        }

        let coeffA = a.extractCoefficient()
        let coeffB = b.extractCoefficient()
        let expA = a.extractExponent()
        let expB = b.extractExponent()

        return Value.fitted(
            sign: resultSign,
            coefficient: Decimals.Wide(coeffA.multipliedFullWidth(by: coeffB)),
            exponent: expA + expB,
            context: context
        )
    }

    public func multiply(
        _ other: Value,
        trapping context: Decimal.Context
    ) throws(Decimal.Trap<Value>) -> Value {
        try multiply(other, context: context).trapped(by: context.traps)
    }
}
