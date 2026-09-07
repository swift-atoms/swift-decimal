extension Swift.Int32 {

    public init?(exactly value: Decimal.Format32) {

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
            let integerPart = coefficient / divisor
            if value.test.negative {
                if integerPart > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(integerPart)
            } else {
                if integerPart > UInt32(Self.max) {
                    return nil
                }
                self = Int32(integerPart)
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
                if result > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(result)
            } else {
                if result > UInt32(Self.max) {
                    return nil
                }
                self = Int32(result)
            }
        } else {

            if value.test.negative {
                if coefficient > UInt32(Self.max) + 1 {
                    return nil
                }
                self = -Int32(coefficient)
            } else {
                if coefficient > UInt32(Self.max) {
                    return nil
                }
                self = Int32(coefficient)
            }
        }
    }
}
