//
//  Extentions.swift
//  SearchPlus
//
//  Created by McCoy Zhu on 11/21/20.
//

import SwiftUI
import Introspect

extension Array {
    func count(where predicate: (Element) -> Bool) -> Int {
        return reduce(0, {$0 + (predicate($1) ? 1 : 0)})
    }
}

extension View {
    func disableSheetDismissGesture(_ disabled: Bool = true) -> some View {
        introspectViewController {
            $0.isModalInPresentation = disabled
        }
    }
}
