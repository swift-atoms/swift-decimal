extension Swift.Int64 {

    public init?(exactly value: Decimal.Format64) {

        if value.test.nan || value.test.infinite {
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
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > UInt64(Self.max) + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- integerPart)
            } else {
                if integerPart > UInt64(Self.max) {
                    return nil
                }
                self = Int64(integerPart)
            }
        } else if Int(exponent) > 0 {

            var result = coefficient
            for _ in 0..<Int(exponent) {
                let (newResult, overflow) = result.multipliedReportingOverflow(by: 10)
                if overflow {
                    return nil
                }
                result = newResult
            }
            if value.test.negative {
                if result > UInt64(Self.max) + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- result)
            } else {
                if result > UInt64(Self.max) {
                    return nil
                }
                self = Int64(result)
            }
        } else {

            if value.test.negative {
                if coefficient > UInt64(Self.max) + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- coefficient)
            } else {
                if coefficient > UInt64(Self.max) {
                    return nil
                }
                self = Int64(coefficient)
            }
        }
    }
}

extension Swift.Int64 {

    public init?(exactly value: Decimal.Format128) {

        if value.test.nan || value.test.infinite {
            return nil
        }

        if value.test.zero {
            self = 0
            return
        }

        let coefficient = value.extractCoefficient()
        let exponent = value.extractExponent()

        let maxInt64AsUInt128 = UInt128(UInt64(Self.max))

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
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: integerPart))
            } else {
                if integerPart > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: integerPart))
            }
        } else if Int(exponent) > 0 {

            var result = coefficient
            for _ in 0..<Int(exponent) {
                let newResult = result * 10

                if newResult > maxInt64AsUInt128 + 1 {
                    return nil
                }
                result = newResult
            }
            if value.test.negative {
                if result > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: result))
            } else {
                if result > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: result))
            }
        } else {

            if value.test.negative {
                if coefficient > maxInt64AsUInt128 + 1 {
                    return nil
                }

                self = Int64(bitPattern: 0 &- UInt64(truncatingIfNeeded: coefficient))
            } else {
                if coefficient > maxInt64AsUInt128 {
                    return nil
                }
                self = Int64(UInt64(truncatingIfNeeded: coefficient))
            }
        }
    }
}
