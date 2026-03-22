//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftAndroidNative open source project
//
// Copyright (c) 2024-2026 Skip.dev and SwiftAndroidNative project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftAndroidNative project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

extension OptionSet {
    // Helper method for building up a comma-separated list of options
    //
    // Taking an array of descriptions reduces code size vs
    // a series of calls due to avoiding register copies. Make sure
    // to pass an array literal and not an array built up from a series of
    // append calls, else that will massively bloat code size. This takes
    // StaticStrings because otherwise we get a warning about getting evicted
    // from the shared cache.
    @inline(never)
    internal func _buildDescription(
        _ descriptions: [(Element, StaticString)]
    ) -> String {
        var copy = self
        var result = "["

        for (option, name) in descriptions {
            if _slowPath(copy.contains(option)) {
                result += name.description
                copy.remove(option)
                if !copy.isEmpty { result += ", " }
            }
        }

        if _slowPath(!copy.isEmpty) {
            result += "\(Self.self)(rawValue: \(copy.rawValue))"
        }
        result += "]"
        return result
    }
}
