extension Swift.UInt64 {

    public init?(exactly value: Decimal.Format64) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.negative && !value.test.zero {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        if Int(exponent) < 0 {

            var divisor: UInt64 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            self = coefficient / divisor
        } else if Int(exponent) > 0 {

            var result = coefficient
            for _ in 0..<Int(exponent) {
                let (newResult, overflow) = result.multipliedReportingOverflow(by: 10)
                if overflow {
                    return nil
                }
                result = newResult
            }
            self = result
        } else {
            self = coefficient
        }
    }
}

extension Swift.UInt64 {

    public init?(exactly value: Decimal.Format128) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.negative && !value.test.zero {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()
        let maxUInt64AsUInt128 = UInt128(Self.max)

        if Int(exponent) < 0 {
            var divisor: UInt128 = 1
            for _ in 0..<(-Int(exponent)) {
                divisor *= 10
                if divisor > coefficient {
                    return nil
                }
            }
            if coefficient % divisor != 0 {
                return nil
            }
            let result = coefficient / divisor
            if result > maxUInt64AsUInt128 {
                return nil
            }
            self = UInt64(truncatingIfNeeded: result)
        } else if Int(exponent) > 0 {
            var result = coefficient
            for _ in 0..<Int(exponent) {
                result *= 10
                if result > maxUInt64AsUInt128 {
                    return nil
                }
            }
            self = UInt64(truncatingIfNeeded: result)
        } else {
            if coefficient > maxUInt64AsUInt128 {
                return nil
            }
            self = UInt64(truncatingIfNeeded: coefficient)
        }
    }
}
