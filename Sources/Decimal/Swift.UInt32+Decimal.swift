extension Swift.UInt32 {

    public init?(exactly value: Decimal.Format32) {

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
            var divisor: UInt32 = 1
            for _ in 0..<(-Int(exponent)) {
                let (newDivisor, overflow) = divisor.multipliedReportingOverflow(by: 10)
                if overflow || newDivisor > coefficient {
                    return nil
                }
                divisor = newDivisor
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
