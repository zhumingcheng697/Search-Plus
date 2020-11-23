//
//  Extentions.swift
//  SearchPlus
//
//  Created by McCoy Zhu on 11/21/20.
//

import SwiftUI
import Introspect

extension View {
    func disableSheetDismissGesture(_ disabled: Bool = true) -> some View {
        introspectViewController {
            $0.isModalInPresentation = disabled
        }
    }
}
